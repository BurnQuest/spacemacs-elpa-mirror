;;; mosey.el --- Mosey around your buffers

;; Author: Adam Porter <adam@alphapapa.net>
;; Url: http://github.com/alphapapa/mosey.el
;; Package-Version: 0.1
;; Version: 0.1
;; Package-Requires: ((emacs "24.4"))
;; Keywords: convenience

;;; Commentary:

;; Howdy.  Why don't ya mosey on in here.  Have yourself a sit-down.

;; `mosey' makes it easy to mosey back and forth in your buffers.
;; Just pass `mosey' a list of functions that move the point to
;; certain places, and it'll mosey the point between those places.
;; Tell it `:backward' if you want to mosey on back, otherwise it'll
;; mosey on ahead.  Tell it to `:cycle' if you want it to loop around
;; when it gets to one end or the other.

;; To make it easier for ya, just pass a list of point-moving
;; functions to `defmosey', and it'll cook up four functions:
;; `mosey-forward', `mosey-backward', `mosey-forward-cycle', and
;; `mosey-backward-cycle'.

;;; Installation

;; Best thing to do is just mosey on over to http://melpa.org/ and
;; install the package called `mosey'.

;; But if you like gettin' your hands dirty, all you need to do is put
;; mosey.el in your `load-path' and then put this in your init file:

;; (require 'mosey)

;; ...and then you can start moseying around.

;;; Usage

;; You can use these commands right off the bat to move within the
;; current line:

;; + mosey-forward
;; + mosey-backward
;; + mosey-forward-cycle
;; + mosey-backward-cycle

;; You might even want to rebind your keys to 'em, maybe like this:

;; (global-set-key (kbd "C-a") 'mosey-backward)
;; (global-set-key (kbd "C-e") 'mosey-forward)

;; ...but that'd be even easier with `use-package' and its handy-dandy
;; `:bind*' form:

;; (use-package mosey
;;   :bind* (
;;           ("C-a" . mosey-backward)
;;           ("C-e" . mosey-forward)
;;           ))

;;;; Make your own moseys

;; It's easy to make your own moseys with defmosey, somethin' like
;; this (this example uses functions from smartparens):

;; (defmosey '(beginning-of-line
;;             back-to-indentation
;;             sp-backward-sexp  ; Moves across lines
;;             sp-forward-sexp   ; Moves across lines
;;             mosey-goto-end-of-code
;;             mosey-goto-beginning-of-comment-text)
;;   :prefix "lisp")

;; That'll cook up four functions for ya:

;; + mosey-lisp-forward
;; + mosey-lisp-backward
;; + mosey-lisp-forward-cycle
;; + mosey-lisp-backward-cycle

;; Then maybe you'd want to use 'em in your `emacs-lisp-mode',
;; somethin' like this:

;; (bind-keys :map emacs-lisp-mode-map
;;            ("C-a" . mosey-lisp-backward)
;;            ("C-e" . mosey-lisp-forward))

;;; Credits

;; This package was inspired by Alex Kost's fantastic `mwim' package.
;; It has even more features, so check it out!
;; https://github.com/alezost/mwim.el

;;; License:

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

;;; Code:

;;;; Require

(require 'cl-lib)

;;;; Mosey function and macro

;;;###autoload
(cl-defun mosey (move-funcs &key (backward nil backward-set) (cycle nil cycle-set))
  "Move the point according to the list of MOVE-FUNCS.

Each function in MOVE-FUNCS should move the point to a
significant position, usually on the current line, but
potentially across lines.

If BACKWARD is set, move backwards.

If CYCLE is set, cycle around when the beginning/end of line is
hit.  Otherwise, stop at beginning/end of line."
  (interactive)
  (let* ((compare-func (if backward-set '< '>))
         (cycle cycle-set)
         (current-pos (point))

         ;; Make list of positions on current line, one per position-func
         (positions (sort
                     (delete-dups
                      (mapcar (lambda (func)
                                (save-excursion
                                  (funcall func)
                                  (point)))
                              move-funcs))
                     '<))
         ;; Reverse list if :backward is set (is there a more elegant way to do this?)
         (positions (if backward
                        (nreverse positions)
                      positions))
         ;; Determine next target position
         (target (cl-loop for p in positions
                          if (funcall compare-func p current-pos)
                          return p
                          finally return (if cycle
                                             (car positions)
                                           current-pos))))
    ;; Goto the target position
    (goto-char target)))

;;;###autoload
(cl-defmacro defmosey (move-funcs &key prefix)
  "Define `mosey-forward' and `mosey-backward' functions, with
`-cycle' variants.

MOVE-FUNCS is a list of functions that should should move the
point to a significant position, usually on the current line, but
potentially across lines.

PREFIX, if set, appends a prefix to the function names, like
`mosey-prefix-forward', useful for defining different sets of
moseys for different modes."
  (when prefix
    (setq prefix (concat prefix "-")))
  `(progn
     (defun ,(intern (concat "mosey-" prefix "forward")) ()
       (interactive)
       (mosey ,move-funcs))
     (defun ,(intern (concat "mosey-" prefix "backward")) ()
       (interactive)
       (mosey ,move-funcs :backward))
     (defun ,(intern (concat "mosey-" prefix "forward-cycle")) ()
       (interactive)
       (mosey ,move-funcs :cycle))
     (defun ,(intern (concat "mosey-" prefix "backward-cycle")) ()
       (interactive)
       (mosey ,move-funcs :backward :cycle))))

;;;; Helper functions

(defun mosey-goto-beginning-of-comment-text ()
  "Move point to beginning of comment text on current line."
  (let (target)
    (save-excursion
      (end-of-line)
      (when (re-search-backward (rx (syntax comment-start) (* space)) (line-beginning-position) t)
        (setq target (match-end 0))))
    (when target
      (goto-char target))))

(defun mosey-goto-end-of-code ()
  "Move point to end of code on current line."
  (let (target)
    (save-excursion
      (beginning-of-line)
      (when (re-search-forward (rx (or (and (1+ space) (syntax comment-start))
                                       (and (* space) eol)))
                               (line-end-position)
                               t)
        (setq target (match-beginning 0))))
    (when target
      (goto-char target))))

;;;; Default mosey

;;;###autoload
(defmosey '(beginning-of-line
            back-to-indentation
            mosey-goto-end-of-code
            mosey-goto-beginning-of-comment-text
            end-of-line))

(provide 'mosey)

;;; mosey.el ends here
