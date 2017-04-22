;;; symbol-overlay.el --- Highlight symbols with keymap-enabled overlays

;; Copyright (C) 2017 wolray

;; Author: wolray <wolray@foxmail.com>
;; Version: 3.2
;; Package-Version: 20170422.101
;; URL: https://github.com/wolray/symbol-overlay/
;; Keywords: faces, matching
;; Package-Requires: ((emacs "24.3"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Highlighting symbols with overlays while providing a keymap for various
;; operations about highlighted symbols.  It was originally inspired by the
;; package `highlight-symbol'.  The fundamental difference is that in
;; `symbol-overlay' every symbol is highlighted by the Emacs built-in function
;; `overlay-put' rather than the `font-lock' mechanism used in
;; `highlight-symbol'.

;; Advantages

;; When highlighting symbols in a buffer of regular size and language,
;; `overlay-put' behaves as fast as the traditional Highlighting method
;; `font-lock'.  However, for a buffer of major-mode with complicated keywords
;; syntax, like haskell-mode, `font-lock' is quite slow even the buffer is less
;; than 100 lines.  Besides, when counting the number of highlighted
;; occurrences, `highlight-symbol' will call the function `how-many' twice,
;; which could also result in an unpleasant delay in a large buffer.  Those
;; problems don't exist in `symbol-overlay'.

;; When putting overlays on symbols, an auto-activated overlay-inside keymap
;; will enable you to call various useful commands with a single keystroke.

;; Toggle all overlays of symbol at point: `symbol-overlay-put'
;; Copy symbol at point: `symbol-overlay-save-symbol'
;; Jump back to the position before a recent jump: `symbol-overlay-echo-mark'
;; Remove all highlighted symbols in the buffer: `symbol-overlay-remove-all'
;; Jump between locations of symbol at point: `symbol-overlay-jump-next' &
;; `symbol-overlay-jump-prev'
;; Jump to the definition of symbol at point: `symbol-overlay-jump-to-definition'
;; Switch to the closest symbol highlighted nearby:
;; `symbol-overlay-switch-forward' & `symbol-overlay-switch-backward'
;; Toggle overlays to be showed in buffer or only in scope:
;; `symbol-overlay-toggle-in-scope'
;; Query replace symbol at point: `symbol-overlay-query-replace'
;; Rename symbol at point on all its occurrences: `symbol-overlay-rename'

;; Usage

;; To use `symbol-overlay' in your Emacs, you need only to bind three keys:
;; (require 'symbol-overlay)
;; (global-set-key (kbd "M-i") 'symbol-overlay-put)
;; (global-set-key (kbd "M-u") 'symbol-overlay-switch-backward)
;; (global-set-key (kbd "M-o") 'symbol-overlay-switch-forward)

;; Default key-bindings are defined in `symbol-overlay-map'.
;; You can re-bind the commands to any keys you prefer by simply writing
;; (define-key symbol-overlay-map (kbd "your-prefer-key") 'any-command)

;;; Code:

(require 'thingatpt)
(require 'seq)

(defvar symbol-overlay-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "i") 'symbol-overlay-put)
    (define-key map (kbd "u") 'symbol-overlay-jump-prev)
    (define-key map (kbd "o") 'symbol-overlay-jump-next)
    (define-key map (kbd "k") 'symbol-overlay-remove-all)
    (define-key map (kbd "w") 'symbol-overlay-save-symbol)
    (define-key map (kbd "e") 'symbol-overlay-echo-mark)
    (define-key map (kbd "d") 'symbol-overlay-jump-to-definition)
    (define-key map (kbd "t") 'symbol-overlay-toggle-in-scope)
    (define-key map (kbd "q") 'symbol-overlay-query-replace)
    (define-key map (kbd "SPC") 'symbol-overlay-rename)
    map)
  "Keymap automatically activated inside overlays.
You can re-bind the commands to any keys you prefer.")

(defvar symbol-overlay-keywords-alist)
(make-variable-buffer-local 'symbol-overlay-keywords-alist)

(defvar symbol-overlay-colors '("dodger blue"
				"hot pink"
				"orange"
				"orchid"
				"red"
				"salmon"
				"spring green"
				"turquoise")
  "Colors used for overlays' background.
You can add more colors whatever you like.")

(defun symbol-overlay-get-list (&optional symbol car-or-cdr exclude)
  "Get all highlighted overlays in the buffer.
If SYMBOL is non-nil, get the overlays that belong to it.
CAR-OR-CDR must a symbol whose value is 'car or 'cdr, if not nil.
If EXCLUDE is non-nil, get all overlays excluding those belong to SYMBOL."
  (let ((lists (or (overlay-recenter (point)) (overlay-lists))))
    (seq-filter
     '(lambda (overlay)
	(let ((value (overlay-get overlay 'symbol)))
	  (and value
	       (or (not symbol)
		   (if (string= value symbol) (not exclude) exclude)))))
     (if car-or-cdr (funcall car-or-cdr lists)
       (append (car lists) (cdr lists))))))

(defun symbol-overlay-get-symbol (&optional string noerror)
  "Get the symbol at point.
If STRING is non-nil, `regexp-quote' STRING rather than the symbol.
If NOERROR is non-nil, just return nil when no symbol is found."
  (let ((symbol (or string (thing-at-point 'symbol))))
    (if symbol (concat "\\_<" (regexp-quote symbol) "\\_>")
      (unless noerror (user-error "No symbol at point")))))

(defun symbol-overlay-assoc (symbol &optional noerror)
  "Get SYMBOL's associated list in `symbol-overlay-keywords-alist'.
If NOERROR is non-nil, just return nil when keyword is not found."
  (let ((keyword (assoc symbol symbol-overlay-keywords-alist)))
    (if keyword keyword
      (unless noerror (user-error "Symbol is not highlighted")))))

(defun symbol-overlay-remove (keyword)
  "Delete the KEYWORD list and all its overlays."
  (when keyword
    (mapc 'delete-overlay (symbol-overlay-get-list (car keyword)))
    (setq symbol-overlay-keywords-alist
	  (delq keyword symbol-overlay-keywords-alist))
    (cddr keyword)))

(defvar symbol-overlay-narrow-function nil
  "Nil or a function that returns a cons of region beginning and end.")
(make-variable-buffer-local 'symbol-overlay-narrow-function)

(defun symbol-overlay-narrow (scope)
  "Narrow to a specific region when SCOPE is non-nil.
Use default method `narrow-to-defun' or
`symbol-overlay-narrow-function' if defined."
  (when scope
    (let ((f symbol-overlay-narrow-function)
	  region)
      (if (not f) (narrow-to-defun)
	(setq region (funcall f))
	(narrow-to-region (car region) (cdr region))))))

(defun symbol-overlay-put-one (symbol color)
  "Put overlay on current occurrence of SYMBOL after a match.
Use COLOR as the overlay's background color."
  (let ((overlay (make-overlay (match-beginning 0) (match-end 0)))
	(face `((background-color . ,color)
		(foreground-color . "black"))))
    (overlay-put overlay 'face face)
    (overlay-put overlay 'keymap symbol-overlay-map)
    (overlay-put overlay 'evaporate t)
    (overlay-put overlay 'symbol symbol)))

(defun symbol-overlay-put-all (symbol &optional scope keyword)
  "Put overlays on all occurrences of SYMBOL in the buffer.
The background color is randomly picked from `symbol-overlay-colors'.
If SCOPE is non-nil, put overlays only on occurrences in scope.
If KEYWORD is non-nil, remove it and use its color for new overlays."
  (let* ((case-fold-search nil)
	 (limit (length symbol-overlay-colors))
	 (color (or (symbol-overlay-remove keyword)
		    (elt symbol-overlay-colors (random limit))))
	 (colors (mapcar 'cddr symbol-overlay-keywords-alist))
	 p)
    (if (< (length symbol-overlay-keywords-alist) limit)
	(while (seq-position colors color)
	  (setq color (elt symbol-overlay-colors (random limit))))
      (setq color (symbol-overlay-remove
		   (car (last symbol-overlay-keywords-alist)))))
    (save-excursion
      (save-restriction
	(symbol-overlay-narrow scope)
	(goto-char (point-min))
	(while (re-search-forward symbol nil t)
	  (symbol-overlay-put-one symbol color)
	  (or p (setq p t)))))
    (setq keyword `(,symbol ,scope . ,color))
    (when p
      (push keyword symbol-overlay-keywords-alist)
      keyword)))

(defun symbol-overlay-count (keyword &optional show-color)
  "Show the number of KEYWORD's occurrences.
If SCOPE is non-nil, display an \"in scope\" message.
If SHOW-COLOR is non-nil, display the color used by current overlay."
  (let* ((symbol (car keyword))
	 (before (symbol-overlay-get-list symbol 'car))
	 (after (symbol-overlay-get-list symbol 'cdr))
	 (count (length before)))
    (message (concat (substring symbol 3 -3) ": %d/%d"
		     (and (cadr keyword) " in scope")
		     (and show-color (format " (%s)" (cddr keyword))))
	     (+ count 1)
	     (+ count (length after)))))

;;;###autoload
(defun symbol-overlay-put ()
  "Toggle all overlays of symbol at point."
  (interactive)
  (unless (minibufferp)
    (let ((symbol (symbol-overlay-get-symbol)))
      (or (symbol-overlay-remove (symbol-overlay-assoc symbol t))
	  (and (looking-at-p "\\_>") (backward-char))
	  (symbol-overlay-count (symbol-overlay-put-all symbol) t)))))

;;;###autoload
(defun symbol-overlay-toggle-in-scope ()
  "Toggle overlays to be showed in buffer or only in scope."
  (interactive)
  (unless (minibufferp)
    (let* ((symbol (symbol-overlay-get-symbol))
	   (keyword (symbol-overlay-assoc symbol))
	   (scope (not (cadr keyword)))
	   (pt (point)))
      (save-excursion
	(save-restriction
	  (symbol-overlay-narrow scope)
	  (and scope (/= pt (point)) (user-error "Wrong scope"))
	  (symbol-overlay-count
	   (symbol-overlay-put-all symbol scope keyword)))))))

;;;###autoload
(defun symbol-overlay-remove-all ()
  "Remove all highlighted symbols in the buffer."
  (interactive)
  (unless (minibufferp)
    (mapc 'delete-overlay (symbol-overlay-get-list))
    (setq symbol-overlay-keywords-alist nil)))

;;;###autoload
(defun symbol-overlay-save-symbol ()
  "Copy symbol at point."
  (interactive)
  (let ((symbol (symbol-overlay-get-symbol))
	(bounds (bounds-of-thing-at-point 'symbol)))
    (kill-ring-save (car bounds) (cdr bounds))
    (message (concat "Current symbol saved"))))

(defvar symbol-overlay-mark nil
  "A mark used for jumping back to the point saved befored.")
(make-variable-buffer-local 'symbol-overlay-mark)

;;;###autoload
(defun symbol-overlay-echo-mark ()
  "Jump back to the mark `symbol-overlay-mark'."
  (interactive)
  (and symbol-overlay-mark (goto-char symbol-overlay-mark)))

(defun symbol-overlay-jump-call (jump-function dir)
  "A general jumping process during which JUMP-FUNCTION is called to jump.
DIR must be 1 or -1."
  (unless (minibufferp)
    (let* ((symbol (symbol-overlay-get-symbol))
	   (keyword (symbol-overlay-assoc symbol)))
      (setq symbol-overlay-mark (point))
      (save-restriction
	(symbol-overlay-narrow (cadr keyword))
	(funcall jump-function symbol dir)
	(symbol-overlay-count keyword)))))

(defun symbol-overlay-basic-jump (symbol dir)
  "Jump to SYMBOL's next location in the direction DIR.  DIR must be 1 or -1."
  (let* ((case-fold-search nil)
	 (bounds (bounds-of-thing-at-point 'symbol))
	 (offset (- (point) (if (> dir 0) (cdr bounds) (car bounds))))
	 target)
    (goto-char (- (point) offset))
    (setq target (re-search-forward symbol nil t dir))
    (unless target
      (goto-char (if (> dir 0) (point-min) (point-max)))
      (setq target (re-search-forward symbol nil nil dir)))
    (goto-char (+ target offset))))

;;;###autoload
(defun symbol-overlay-jump-next ()
  "Jump to the next location of symbol at point."
  (interactive)
  (symbol-overlay-jump-call 'symbol-overlay-basic-jump 1))

;;;###autoload
(defun symbol-overlay-jump-prev ()
  "Jump to the previous location of symbol at point."
  (interactive)
  (symbol-overlay-jump-call 'symbol-overlay-basic-jump -1))

(defvar symbol-overlay-definition-function
  '(lambda (symbol) (concat "(?def[a-z-]* " symbol))
  "An one-argument function that returns a regexp.")
(make-variable-buffer-local 'symbol-overlay-definition-function)

;;;###autoload
(defun symbol-overlay-jump-to-definition ()
  "Jump to the definition of symbol at point.
The definition syntax should be defined in a function stored in
`symbol-overlay-definition-function' that returns the definition's regexp
with the input symbol."
  (interactive)
  (symbol-overlay-jump-call
   '(lambda (symbol dir)
      (let ((pt (point)) p)
	(symbol-overlay-basic-jump symbol dir)
	(while (not (or p (save-excursion
			    (beginning-of-line)
			    (skip-chars-forward " \t")
			    (looking-at-p
			     (funcall symbol-overlay-definition-function
				      symbol)))))
	  (symbol-overlay-basic-jump symbol dir)
	  (and (= pt (point)) (setq p t)))))
   1))

(defun symbol-overlay-switch-symbol (dir)
  "Switch to the closest symbol highlighted nearby, in the direction DIR.
DIR must be 1 or -1."
  (unless (minibufferp)
    (let* ((symbol (symbol-overlay-get-symbol nil t))
	   (list (symbol-overlay-get-list symbol (if (> dir 0) 'cdr 'car) t)))
      (unless list
	(user-error (concat "No more "
			    (if (> dir 0) "forward" "backward")
			    " symbols")))
      (setq symbol-overlay-mark (point))
      (goto-char (overlay-start (car list)))
      (symbol-overlay-count
       (symbol-overlay-assoc (symbol-overlay-get-symbol))))))

;;;###autoload
(defun symbol-overlay-switch-forward ()
  "Switch forward to another symbol."
  (interactive)
  (symbol-overlay-switch-symbol 1))

;;;###autoload
(defun symbol-overlay-switch-backward ()
  "Switch backward to another symbol."
  (interactive)
  (symbol-overlay-switch-symbol -1))

(defun symbol-overlay-replace-call (replace-function)
  "Replace symbol using REPLACE-FUNCTION.
If COUNT is non-nil, count at the end."
  (unless (minibufferp)
    (let* ((case-fold-search nil)
	   (symbol (symbol-overlay-get-symbol))
	   (keyword (symbol-overlay-assoc symbol))
	   (scope (cadr keyword))
	   (new (substring symbol 3 -3)))
      (beginning-of-thing 'symbol)
      (setq symbol-overlay-mark (point)
	    new (funcall replace-function symbol new scope))
      (unless (string= new symbol)
	(symbol-overlay-remove (symbol-overlay-assoc new t))
	(setq keyword (symbol-overlay-put-all
		       new scope (symbol-overlay-assoc symbol))))
      (when (string= new (symbol-overlay-get-symbol nil t))
	(beginning-of-thing 'symbol)
	(symbol-overlay-count keyword)))))

;;;###autoload
(defun symbol-overlay-query-replace ()
  "Query replace symbol at point."
  (interactive)
  (symbol-overlay-replace-call
   '(lambda (symbol new scope)
      (and scope (user-error "Query replace is invalid in scope"))
      (setq new (read-string "Replacement: "))
      (let ((inhibit-modification-hooks t)
	    (defaults (cons symbol new)))
	(query-replace-regexp symbol new)
	(setq query-replace-defaults
	      (if (< emacs-major-version 25) `,defaults `(,defaults))))
      (symbol-overlay-get-symbol new))))

;;;###autoload
(defun symbol-overlay-rename ()
  "Rename symbol at point on all its occurrences."
  (interactive)
  (symbol-overlay-replace-call
   '(lambda (symbol new scope)
      (setq new (read-string (concat (format "Rename (%s)" new)
				     (and scope " in scope")
				     ": ")))
      (save-excursion
	(save-restriction
	  (symbol-overlay-narrow scope)
	  (goto-char (point-min))
	  (let ((inhibit-modification-hooks t))
	    (while (re-search-forward symbol nil t) (replace-match new)))))
      (symbol-overlay-get-symbol new))))

(defun symbol-overlay-refresh (beg end len)
  "Refresh overlays.  Installed on `after-change-functions'.
BEG, END and LEN are the beginning, end and length of changed text."
  (unless (or (minibufferp) (not symbol-overlay-keywords-alist))
    (let ((case-fold-search nil)
	  (re "\\(\\sw\\|\\s_\\)+"))
      (save-excursion
	(goto-char end)
	(and (looking-at-p re)
	     (setq end (re-search-forward "\\_>")))
	(goto-char beg)
	(and (looking-at-p (concat "\\(" re "\\|\\_>\\)"))
	     (setq beg (re-search-backward "\\_<")))
	(mapc #'(lambda (overlay)
		  (and (overlay-get overlay 'symbol) (delete-overlay overlay)))
	      (overlays-in beg end))
	(mapc #'(lambda (keyword)
		  (let ((symbol (car keyword)))
		    (goto-char beg)
		    (while (re-search-forward symbol end t)
		      (symbol-overlay-put-one symbol (cddr keyword)))))
	      symbol-overlay-keywords-alist)))))

(add-hook 'after-change-functions 'symbol-overlay-refresh)

(provide 'symbol-overlay)

;;; symbol-overlay.el ends here
