;;; mwim.el --- Move to the beginning/end of line or code  -*- lexical-binding: t -*-

;; Copyright © 2015, 2016 Alex Kost

;; Author: Alex Kost <alezost@gmail.com>
;; Created: 9 Jan 2015
;; Version: 0.3
;; Package-Version: 0.3
;; URL: https://github.com/alezost/mwim.el
;; Keywords: convenience

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

;; MWIM stands for "Move Where I Mean".  This package is inspired by
;; <http://www.emacswiki.org/emacs/BackToIndentationOrBeginning>.  It
;; provides commands for moving to the beginning/end of code or line.

;; To install the package manually, add the following to your init file:
;;
;;   (add-to-list 'load-path "/path/to/mwim-dir")
;;   (autoload 'mwim-beginning-of-code-or-line "mwim" nil t)
;;   (autoload 'mwim-beginning-of-line-or-code "mwim" nil t)
;;   (autoload 'mwim-end-of-code-or-line "mwim" nil t)
;;   (autoload 'mwim-end-of-line-or-code "mwim" nil t)

;; Then you can bind some keys to some of those commands and start
;; moving.

;;; Code:

(defgroup mwim nil
  "Move Where I Mean.
Move the point to the beginning/end of code or line."
  :group 'convenience)

(defcustom mwim-beginning-of-line-function #'beginning-of-visual-line
  "Function used to move the point to the beginning of line."
  :type '(choice (function-item beginning-of-visual-line)
                 (function-item beginning-of-line)
                 (function :tag "Another function"))
  :group 'mwim)

(defcustom mwim-end-of-line-function #'end-of-visual-line
  "Function used to move the point to the end of line."
  :type '(choice (function-item end-of-visual-line)
                 (function-item end-of-line)
                 (function :tag "Another function"))
  :group 'mwim)

(defmacro mwim-point-at (&rest body)
  "Return point after evaluating BODY in `save-excursion'."
  `(save-excursion ,@body (point)))

(defmacro mwim-goto-non-current-position (exp1 exp2)
  "Move point to position defined after evaluating EXP1.
If the point is already there, move to position defined after
evaluating EXP2."
  (let ((p1-var (make-symbol "p1")))
    `(goto-char
      (let ((,p1-var (mwim-point-at ,exp1)))
        (if (= (point) ,p1-var)
            (mwim-point-at ,exp2)
          ,p1-var)))))

(defun mwim-comment-beginning ()
  "Return position of the beginning of the current comment.
Return nil, if not inside a comment."
  (let ((syn (syntax-ppss)))
    (and (nth 4 syn)
         (nth 8 syn))))

(defun mwim-beginning-of-line ()
  "Move point to the beginning of line.
Use `mwim-beginning-of-line-function'."
  (interactive "^")
  (if (functionp mwim-beginning-of-line-function)
      (funcall mwim-beginning-of-line-function)
    (beginning-of-line)))

(defun mwim-end-of-line ()
  "Move point to the end of line.
Use `mwim-end-of-line-function'."
  (interactive "^")
  (if (functionp mwim-end-of-line-function)
      (funcall mwim-end-of-line-function)
    (end-of-line)))

(defun mwim-beginning-of-code ()
  "Move point to the first non-whitespace character on the current line."
  (interactive "^")
  (mwim-beginning-of-line)
  (skip-syntax-forward " " (line-end-position)))

(defun mwim-end-of-code ()
  "Move point to the end of code.

'End of code' means before a possible comment and trailing
whitespaces.  Comments are recognized in any mode that sets
`syntax-ppss' properly.

If current line is fully commented (contains only comment), move
to the end of line."
  (interactive "^")
  (mwim-end-of-line)
  (let ((comment-beg (mwim-comment-beginning)))
    (when comment-beg
      (let ((eoc (save-excursion
                   (goto-char comment-beg)
                   (skip-chars-backward " \t")
                   (point))))
        (when (< (line-beginning-position) eoc)
          (goto-char eoc)))))
  (skip-chars-backward " \t"))

(defmacro mwim-define-command (position object1 object2)
  "Define `mwim-POSITION-of-OBJECT1-or-OBJECT2' command.
POSITION is either `beginning' or `end'.
OBJECT1 and OBJECT2 can be `line' or `code'."
  (let* ((format-str  "mwim-%S-of-%S")
         (direct-fun  (intern (format format-str position object1)))
         (inverse-fun (intern (format format-str position object2)))
         (fun-name    (intern (format "mwim-%S-of-%S-or-%S"
                                      position object1 object2))))
    `(defun ,fun-name (&optional arg)
       ,(format "Move point to the %S of %S.
If the point is already there, move to the %S of %S.

If ARG is specified, move forward (or backward) this many lines.
See `forward-line' for details."
                position object1 position object2)
       (interactive
        (progn
          (handle-shift-selection)
          (when current-prefix-arg
            (list (prefix-numeric-value current-prefix-arg)))))
       (if (or (null arg) (= 0 arg))
           (mwim-goto-non-current-position
            (,direct-fun)
            (,inverse-fun))
         (forward-line arg)
         (,direct-fun)))))

(mwim-define-command beginning line code)
(mwim-define-command beginning code line)
(mwim-define-command end line code)
(mwim-define-command end code line)

;;;###autoload (autoload 'mwim-beginning-of-line-or-code "mwim" nil t)
;;;###autoload (autoload 'mwim-beginning-of-code-or-line "mwim" nil t)
;;;###autoload (autoload 'mwim-end-of-line-or-code "mwim" nil t)
;;;###autoload (autoload 'mwim-end-of-code-or-line "mwim" nil t)

(provide 'mwim)

;;; mwim.el ends here
