;;; kaolin-theme.el --- A dark jade theme inspired by Sierra.vim

;; Copyright (C) 2017 0rdy

;; Author: 0rdy <mail@0rdy.com>
;; URL: https://github.com/0rdy/kaolin-theme
;; Package-Version: 20170222.2352
;; Package-Requires: ((emacs "24"))
;; Version: 0.2.0

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;;; Commentary:

;;; Code:

(deftheme kaolin "A dark jade theme")

(defgroup kaolin-theme nil
  "Kaolin theme properties"
  :prefix "kaolin-"
  :group 'faces)

(defcustom kaolin-bold t
  "If nil, disable bold style."
  :group 'kaolin-theme)

;; Kaolin color palette
(let ((class '((class color) (min-colors 89)))
      (black        "#1b1b1b")
      (alt-black    "#181818")
      (dark-gray    "#2a2a2a")
      (dim-gray     "#353535")
      (gray         "#545c5e")
      ;; (light-gray   "#788486")
      (light-gray   "#859092")
      (white        "#c5c8c6")
      (brown        "#7d6360")
      (alt-brown    "#604c4a")
      (light-red    "#d66e75")
      (red          "#d75f5f")
      (alt-red      "#c93232")
      ;; (deep-pink    "#d75f91")
      (deep-pink    "#d24b83")
      (orange       "#d2ab5d")
      (light-orange "#ddc085")
      (dark-yellow  "#555a2f")
      (yellow       "#acb370")
      ;; (light-yellow "#c1b175")
      (light-yellow "#c9bb87")
      ;; (deep-green   "#30555a")
      (deep-green   "#39656b")
      (green        "#4a858c")
      (light-green  "#54b685")
      (lime         "#85b654")
      (teal         "#80b6bc")
      (teal-blue    "#91b9c7")
      (dark-blue    "#2a4661")
      (blue         "#5485b6")
      (cyan         "#54b6b6")
      (deep-blue    "#857f96")
      (dark-purple  "#563d56")
      (purple       "#835d83")
      (magenta      "#5454b6")
      ;; (light-purple "#9d769d")
      (light-purple "#cea2ca")
      (alt-purple   "#8c4a64")

      ;; Face options
      (bold         kaolin-bold))

  ;; Theme colors
  (let* ((fg1  white)
         (fg2  "#b8bcb9")
         (fg3  "#abafac")
         (fg4  "#9ea39f")
         (bg1   black)
         (bg2  "#282828")
         (bg3  "#353535")
         (bg4  "#414141")
         (key2 "#5f9298")
         (key3 "#41757b")
         (dim-buffer alt-black)

         (rb1 blue)
         (rb2 light-yellow)
         (rb3 lime)
         (rb4 light-red)
         (rb5 teal)
         (rb6 fg3)
         (rb7 green)
         (rb8 orange)

         (line-fg           fg4)
         (line-bg           bg2)
         (line-border       bg3)
         (segment-active    gray)
         (segment-inactive  gray)
         (evil-normal       green)
         (evil-insert       light-green)
         (evil-visual       orange)
         (evil-replace      red)
         (evil-motion       yellow)
         (evil-operator     evil-normal)
         (evil-emacs        light-yellow)

         (cursor     light-gray)
         (keyword    green)
         (hl         cyan)
         (hl-indent  gray)
         (builtin    teal)
         (const      deep-blue)
         (comment    gray)
         (win-border dark-gray)
         (functions  teal)
         (str        teal-blue)
         (str-alt    light-yellow)
         (doc        str-alt)
         (type       orange)
         (var        deep-blue)
         (num        red)
         (warning    orange)
         (err        red))

    (custom-theme-set-faces
     'kaolin
     ;; Font-lock
     `(font-lock-builtin-face ((,class (:foreground ,builtin))))
     `(font-lock-comment-face ((,class (:foreground ,comment))))
     `(font-lock-constant-face ((,class (:foreground ,const))))
     `(font-lock-reference-face ((,class (:foreground ,const))))
     `(font-lock-string-face ((,class (:foreground ,str))))
     `(font-lock-doc-face ((,class (:foreground ,doc))))
     `(font-lock-function-name-face ((,class (:foreground ,functions :bold ,bold))))
     `(font-lock-keyword-face ((,class (:foreground ,keyword :bold ,bold))))
     `(font-lock-negation-char-face ((,class (:foreground ,const))))
     `(font-lock-type-face ((,class (:foreground ,type))))
     `(font-lock-variable-name-face ((,class (:foreground ,var))))
     `(font-lock-warning-face ((,class (:background nil :foreground ,warning))))
     `(font-lock-preprocessor-face ((,class (:foreground ,deep-pink :bold nil))))

     ;; General
     `(default ((,class (:background ,bg1 :foreground ,fg1))))
     `(warning ((,class (:foreground ,warning))))
     `(error ((,class (:foreground ,err))))
     `(region ((,class (:background ,bg3))))
     `(secondary-selection ((,class (:background ,green :foreground ,bg1))))
     `(fringe ((,class (:background ,bg1 :foreground ,fg1))))
     `(cursor ((,class (:background ,cursor))))
     `(isearch ((,class (:background ,hl :foreground ,bg3 :bold ,bold))))
     `(vertical-border ((,class (:foreground ,win-border))))
     `(minibuffer-prompt ((,class (:foreground ,keyword :bold ,bold))))
     `(default-italic ((,class (:italic t))))
     `(link ((,class (:foreground ,const :underline t))))
     `(success ((,class (:background nil :foreground ,yellow))))

     ;; Dashboard
     `(widget-button ((,class (:background nil :foreground ,green :bold ,bold))))

     ;; Additional highlighting
     `(highlight ((,class (:background ,bg2 :foreground ,hl))))
     `(lazy-highlight ((,class (:background ,bg3 :foreground ,fg2))))
     `(hl-line ((,class (:background ,bg2))))
     `(highlight-numbers-number ((,class (:foreground ,num))))
     `(highlight-quoted-quote ((t (:foreground ,teal)))) ; Face to highlight Lisp quotes
     `(highlight-quoted-symbol ((t (:foreground ,green)))) ; Face to highlight quoted Lisp symbols

     ;; Highlight indent guides
     `(highlight-indent-guides-odd-face  ((t (:background ,hl-indent))))
     `(highlight-indent-guides-even-face  ((t (:background ,hl-indent))))
     `(highlight-indent-guides-character-face  ((t (:foreground ,hl-indent))))

     ;; Linum & nlinum
     `(linum ((t (:background ,bg1 :foreground ,gray))))
     `(nlinum-current-line ((t (:background ,bg1 :foreground ,green))))

     ;; Auto-dim-other-buffers
     `(auto-dim-other-buffers-face  ((t (:background ,dim-buffer))))

     ;; Fic-mode
     `(fic-face  ((t (:background nil :foreground ,red :bold ,bold))))
     `(fic-author-face  ((t (:background nil :foreground ,red :bold ,bold))))

     ;; Modeline
     ;; `(mode-line ((,class (:box (:line-width 1 :color ,line-border) :bold ,bold :background ,line-bg :foreground ,line-fg))))
     `(mode-line ((,class (:box (:line-width 2 :color ,dim-gray) :background ,line-bg :foreground ,deep-blue :bold ,bold))))
     `(mode-line-buffer-id ((,class (:background nil :foreground ,teal :bold ,bold))))
     `(mode-line-highlight ((,class (:foreground ,keyword :box nil :bold ,bold))))
     ;; `(mode-line-inactive ((,class (:box (:line-width 1 :color ,bg2 :style pressed-button) :background ,bg2 :foreground ,light-gray :weight normal))))
     `(mode-line-inactive ((,class (:box (:line-width 2 :color ,line-bg) :background ,line-bg :foreground ,light-gray :bold ,bold))))
     `(mode-line-emphasis ((,class (:foreground ,fg1))))

     ;; Telephone-line
     `(telephone-line-accent-active ((t (:inherit mode-line :background ,dim-gray :foreground ,line-fg))))
     `(telephone-line-accent-inactive ((t (:background ,line-bg :foreground ,light-gray :inherit mode-line-inactive))))
     `(telephone-line-evil ((t (:inherit mode-line))))
     `(telephone-line-evil-normal ((t (:background ,dim-gray :foreground ,evil-normal :inherit telephone-line-evil))))
     `(telephone-line-evil-insert ((t (:background ,dim-gray :foreground ,evil-insert :inherit telephone-line-evil))))
     `(telephone-line-evil-visual ((t (:background ,dim-gray :foreground ,evil-visual :inherit telephone-line-evil))))
     `(telephone-line-evil-replace ((t (:background ,dim-gray :foreground ,evil-replace :inherit telephone-line-evil))))
     `(telephone-line-evil-motion ((t (:background ,dim-gray :foreground ,evil-motion :inherit telephone-line-evil))))
     `(telephone-line-evil-operator ((t (:background ,dim-gray :foreground ,evil-operator :inherit telephone-line-evil))))
     `(telephone-line-evil-emacs ((t (:background ,dim-gray :foreground ,evil-emacs :inherit telephone-line-evil))))

     ;; Flycheck
     `(flycheck-warning ((,class (:underline (:style wave :color ,orange)))))

     ;; Org-mode
     `(org-level-1 ((,class (:foreground ,purple :bold ,bold :height 1.1))))
     `(org-level-2 ((,class (:foreground ,teal-blue :bold nil))))
     `(org-level-3 ((,class (:inherit org-level-2))))
     `(org-level-4 ((,class (:inherit org-level-2))))
     `(org-tag ((,class (:foreground ,orange :bold ,bold))))
     `(org-checkbox ((,class (:foreground ,deep-blue :bold ,bold))))
     `(org-todo ((,class (:foreground ,red :bold ,bold))))
     `(org-done ((,class (:foreground ,lime  :bold ,bold))))
     `(org-checkbox-statistics-todo ((,class (:foreground ,deep-blue :bold ,bold))))
     `(org-checkbox-statistics-done ((,class (:foreground ,lime :bold ,bold))))
     `(org-code ((,class (:foreground ,green))))
     `(org-verbatim ((,class (:foreground ,light-yellow))))
     `(org-hide ((,class (:foreground ,bg2))))
     `(org-date ((,class (:foreground ,light-yellow :underline t))))
     `(org-document-title ((,class (:foreground ,teal :bold ,bold))))
     `(org-document-info-keyword ((,class (:foreground ,deep-green))))
     `(org-meta-line ((,class (:inherit org-document-info-keyword))))
     `(org-document-info ((,class (:foreground ,teal))))
     `(org-footnote  ((,class (:foreground ,fg4 :underline t))))
     `(org-link ((,class (:foreground ,blue :underline t))))
     `(org-special-keyword ((,class (:foreground ,functions))))
     `(org-block ((,class (:foreground ,fg3))))
     `(org-block-begin-line ((,class (:foreground ,deep-green))))
     `(org-block-end-line ((,class (:inherit org-block-begin-line))))
     `(org-table ((,class (:foreground ,deep-blue :bold ,bold))))
     `(org-formula ((,class (:foreground ,orange))))
     `(org-quote ((,class (:inherit org-block :slant italic))))
     `(org-verse ((,class (:inherit org-block :slant italic))))
     `(org-warning ((,class (:foreground ,warning :underline t))))
     `(org-agenda-structure ((,class (:background ,bg3 :foreground ,fg3 :bold ,bold))))
     `(org-agenda-date ((,class (:foreground ,light-yellow :height 1.1))))
     `(org-agenda-date-weekend ((,class (:weight normal :foreground ,fg4))))
     `(org-agenda-date-today ((,class (:foreground ,purple :height 1.2 :bold ,bold))))
     `(org-agenda-done ((,class (:foreground ,bg4))))
     `(org-scheduled ((,class (:foreground ,type))))
     `(org-scheduled-today ((,class (:foreground ,functions :height 1.2 :bold ,bold))))
     `(org-ellipsis ((,class (:foreground ,builtin))))
     `(org-sexp-date ((,class (:foreground ,fg4))))

     ;; Latex
     `(font-latex-bold-face ((,class (:foreground ,type))))
     `(font-latex-italic-face ((,class (:foreground ,key3 :italic t))))
     `(font-latex-string-face ((,class (:foreground ,str))))
     `(font-latex-match-reference-keywords ((,class (:foreground ,const))))
     `(font-latex-match-variable-keywords ((,class (:foreground ,var))))

     ;; Ido
     `(ido-only-match ((,class (:foreground ,hl))))
     `(ido-first-match ((,class (:foreground ,keyword :bold ,bold))))

     ;; Gnus
     `(gnus-header-content ((,class (:foreground ,keyword))))
     `(gnus-header-from ((,class (:foreground ,var))))
     `(gnus-header-name ((,class (:foreground ,type))))
     `(gnus-header-subject ((,class (:foreground ,functions :bold ,bold))))

     ;; Mu4e
     `(mu4e-header-marks-face ((,class (:foreground ,type))))
     `(mu4e-view-url-number-face ((,class (:foreground ,type))))
     `(mu4e-cited-1-face ((,class (:foreground ,fg2))))
     `(mu4e-cited-7-face ((,class (:foreground ,fg3))))

     `(ffap ((,class (:foreground ,fg4))))

     ;; Js-mode
     `(js2-private-function-call ((,class (:foreground ,const))))
     `(js2-jsdoc-html-tag-delimiter ((,class (:foreground ,str))))
     `(js2-jsdoc-html-tag-name ((,class (:foreground ,key2))))
     `(js2-external-variable ((,class (:foreground ,type))))
     `(js2-function-param ((,class (:foreground ,const))))
     `(js2-error ((,class (:underline (:color ,alt-red :style wave)))))
     `(js2-function-call ((,class (:foreground ,yellow))))
     `(js2-jsdoc-value ((,class (:foreground ,str))))
     `(js2-private-member ((,class (:foreground ,fg3))))
     `(js3-function-param-face ((,class (:foreground ,key3))))
     `(js3-instance-member-face ((,class (:foreground ,const))))
     `(js3-external-variable-face ((,class (:foreground ,var))))
     `(js3-jsdoc-tag-face ((,class (:foreground ,keyword))))
     `(js3-warning-face ((,class (:underline ,keyword))))
     `(js3-error-face ((,class (:underline ,err))))

     `(ac-completion-face ((,class (:foreground ,keyword :underline t))))
     `(info-quoted-name ((,class (:foreground ,builtin))))
     `(info-string ((,class (:foreground ,str))))
     `(icompletep-determined ((,class :foreground ,builtin)))

     ;; Undo-tree
     `(undo-tree-visualizer-current-face ((,class :foreground ,builtin)))
     `(undo-tree-visualizer-default-face ((,class :foreground ,fg2)))
     `(undo-tree-visualizer-unmodified-face ((,class :foreground ,var)))
     `(undo-tree-visualizer-register-face ((,class :foreground ,type)))

     ;; Slime
     `(slime-repl-inputed-output-face ((,class (:foreground ,type))))

     ;; Rainbow delimeters
     `(show-paren-match-face ((,class (:background ,green :foreground ,bg2))))
     `(show-paren-mismatch-face ((,class (:background ,red :foreground ,bg2))))
     `(rainbow-delimiters-unmatched-face ((,class :foreground ,warning)))
     `(rainbow-delimiters-depth-1-face ((,class (:foreground ,rb1))))
     `(rainbow-delimiters-depth-2-face ((,class :foreground ,rb2)))
     `(rainbow-delimiters-depth-3-face ((,class :foreground ,rb3)))
     `(rainbow-delimiters-depth-4-face ((,class :foreground ,rb4)))
     `(rainbow-delimiters-depth-5-face ((,class :foreground ,rb5)))
     `(rainbow-delimiters-depth-6-face ((,class :foreground ,rb6)))
     `(rainbow-delimiters-depth-7-face ((,class :foreground ,rb7)))
     `(rainbow-delimiters-depth-8-face ((,class :foreground ,rb8)))

     ;; Magit
     `(magit-section-highlight      ((,class (:background ,bg2))))
     `(magit-diff-file-header ((,class (:background ,bg3 :foreground ,fg2))))
     `(magit-item-highlight ((,class :background ,bg3)))
     `(magit-section-heading        ((,class (:foreground ,keyword :bold ,bold))))
     `(magit-hunk-heading           ((,class (:background ,bg3))))
     `(magit-hunk-heading-highlight ((,class (:background ,bg3))))
     `(magit-diff-context-highlight ((,class (:background ,bg3 :foreground ,fg3))))
     `(magit-diffstat-added   ((,class (:foreground ,type))))
     `(magit-diffstat-removed ((,class (:foreground ,var))))
     `(magit-process-ok ((,class (:foreground ,functions :bold ,bold))))
     `(magit-process-ng ((,class (:foreground ,warning :bold ,bold))))
     `(magit-branch ((,class (:foreground ,const :bold ,bold))))
     `(magit-log-author ((,class (:foreground ,fg3))))
     `(magit-hash ((,class (:foreground ,fg2))))

     ;; Git gutter
     `(git-gutter:unchanged ((,class (:background ,bg1 :foreground nil))))
     `(git-gutter:added ((,class (:background ,bg1 :foreground ,light-green :bold ,bold))))
     `(git-gutter:modified ((,class (:background ,bg1 :foreground ,yellow :bold ,bold))))
     `(git-gutter:deleted ((,class (:background ,bg1 :foreground ,red :bold ,bold))))

     ;; Terminal
     `(term ((t (:foreground ,fg1))))
     `(term-color-black ((t (:foreground ,bg1))))
     `(term-color-blue ((t (:foreground ,blue))))
     `(term-color-red ((t (:foreground ,red))))
     `(term-color-green ((t (:foreground ,green))))
     `(term-color-yellow ((t (:foreground ,yellow))))
     `(term-color-magenta ((,t (:foreground ,purple))))
     `(term-color-cyan ((t (:foreground ,cyan))))
     `(term-color-white ((t (:foreground ,fg2))))

     ;; EShell
     `(eshell-prompt ((t (:foreground ,green :bold ,bold))))
     `(eshell-ls-directory ((t (:foreground ,magenta :bold ,bold))))
     `(eshell-ls-symlink ((t (:foreground ,blue :bold ,bold))))
     `(eshell-ls-executable ((t (:foreground ,lime :bold ,bold))))
     `(eshell-ls-archive ((t (:foreground ,red))))
     `(eshell-ls-backup ((t (:foreground ,purple))))
     `(eshell-ls-clutter ((t (:foreground ,deep-pink))))
     `(eshell-ls-missing ((t (:background ,bg3 :foreground ,red))))
     `(eshell-ls-product ((t (:foreground ,yellow))))
     `(eshell-ls-readonly ((t (:foreground ,fg2))))
     `(eshell-ls-special ((t (:foreground ,light-green))))
     `(eshell-ls-unreadable ((t (:foreground ,deep-blue))))

     ;; Whitespace
     `(whitespace-empty            ((t (:foreground ,red))))
     `(whitespace-line             ((t (:background ,bg2))))
     `(whitespace-space            ((t (:background ,bg2))))
     `(whitespace-tab              ((t (:foreground ,gray))))
     `(whitespace-newline          ((t (:foreground ,gray))))
     `(whitespace-hspace           ((t (:foreground ,orange))))
     `(whitespace-trailing         ((t (:background ,bg1))))

     ;; Helm
     `(helm-header ((,class (:background ,bg1 :foreground ,fg2 :underline nil :box nil))))
     `(helm-source-header ((,class (:background ,bg1 :foreground ,keyword :underline nil :bold ,bold))))
     `(helm-match ((,class (:inherit default :foreground ,orange :bold ,bold))))
     `(helm-header-line-left-margin ((t (:background ,blue :foreground ,bg1))))
     `(helm-selection ((,class (:background ,bg2 :foreground ,orange :bold ,bold))))
     `(helm-selection-line ((,class (:background ,bg2 :foreground ,orange :bold ,bold))))
     `(helm-visible-mark ((,class (:background ,bg1 :foreground ,blue))))
     `(helm-candidate-number ((,class (:foreground ,lime))))
     `(helm-separator ((,class (:background ,bg1 :foreground ,type))))
     `(helm-time-zone-current ((,class (:background ,bg1 :foreground ,builtin))))
     `(helm-time-zone-home ((,class (:background ,bg1 :foreground ,type))))
     `(helm-buffer-not-saved ((,class (:background ,bg1 :foreground ,type))))
     `(helm-buffer-process ((,class (:background ,bg1 :foreground ,builtin))))
     `(helm-buffer-saved-out ((,class (:background ,bg1 :foreground ,fg1))))
     `(helm-buffer-size ((,class (:background ,bg1 :foreground ,fg1))))
     `(helm-ff-directory ((,class (:background ,bg1 :foreground ,functions :bold ,bold))))
     `(helm-buffer-directory ((,class (:background ,bg1 :foreground ,purple))))
     `(helm-ff-dotted-directory ((,class (:background ,bg1 :foreground ,functions :bold ,bold))))
     `(helm-ff-dotted-symlink-directory ((,class (:background ,bg1 :foreground ,blue :bold ,bold))))
     `(helm-ff-file ((,class (:background ,bg1 :foreground ,fg1 :weight normal))))
     `(helm-ff-executable ((,class (:background ,bg1 :foreground ,key2 :weight normal))))
     `(helm-ff-invalid-symlink ((,class (:background ,bg1 :foreground ,warning :bold ,bold))))
     `(helm-resume-need-update ((,class (:background ,alt-red :foreground nil))))
     `(helm-ff-symlink ((,class (:background ,bg1 :foreground ,keyword :bold ,bold))))
     `(helm-ff-prefix ((,class (:background ,keyword :foreground ,bg1 :weight normal))))
     `(helm-grep-cmd-line ((,class (:background ,bg1 :foreground ,fg1))))
     `(helm-grep-file ((,class (:background ,bg1 :foreground ,fg1))))
     `(helm-grep-finish ((,class (:background ,bg1 :foreground ,fg2))))
     `(helm-grep-lineno ((,class (:background ,bg1 :foreground ,fg1))))
     `(helm-grep-match ((,class (:background nil :foreground nil :inherit helm-match))))
     `(helm-grep-running ((,class (:background ,bg1 :foreground ,functions))))
     `(helm-moccur-buffer ((,class (:background ,bg1 :foreground ,functions))))
     `(helm-source-go-package-godoc-description ((,class (:foreground ,str))))
     `(helm-bookmark-w3m ((,class (:foreground ,type))))

     ;; Company
     `(company-tooltip ((,class (:background ,bg1 :foreground ,fg2 :bold ,bold))))
     `(company-tooltip-common ((,class ( :foreground ,fg3))))
     `(company-tooltip-common-selection ((,class (:foreground ,str))))
     `(company-tooltip-selection ((,class (:background ,bg3 :foreground ,teal))))
     `(company-tooltip-annotation ((,class (:foreground ,const))))
     `(company-scrollbar-bg ((,class (:background ,bg1))))
     `(company-scrollbar-fg ((,class (:foreground ,keyword))))
     `(company-template-field ((,class (:inherit region))))
     `(company-echo-common ((,class (:background ,fg1 :foreground ,bg1))))
     `(company-preview ((,class (:background ,bg1 :foreground ,key2))))
     `(company-preview-common ((,class (:foreground ,bg2 :foreground ,fg3))))
     `(company-preview-search ((,class (:background ,bg1 :foreground ,type))))
     `(company-tooltip-mouse ((,class (:background ,bg3 :foreground ,fg3))))

     ;; Web
     `(css-selector ((,class (:foreground ,teal))))
     `(web-mode-type-face ((,class (:inherit ,font-lock-type-face))))
     `(web-mode-html-tag-face ((,class (:inherit font-lock-keyword-face))))
     `(web-mode-html-tag-bracket-face ((,class (:inherit web-mode-html-tag-face))))
     `(web-mode-html-attr-name-face ((,class (:inherit ,font-lock-function-name-face))))
     `(web-mode-html-attr-value-face ((,class (:inherit ,font-lock-doc-face))))
     `(web-mode-builtin-face ((,class (:inherit ,font-lock-builtin-face))))
     `(web-mode-keyword-face ((,class (:foreground ,keyword))))
     `(web-mode-constant-face ((,class (:inherit ,font-lock-constant-face))))
     `(web-mode-comment-face ((,class (:inherit ,font-lock-comment-face))))
     `(web-mode-doctype-face ((,class (:foreground ,purple :bold ,bold))))
     `(web-mode-function-name-face ((,class (:inherit ,font-lock-function-name-face))))
     `(web-mode-string-face ((,class (:foreground ,str))))
     `(web-mode-warning-face ((,class (:inherit ,font-lock-warning-face))))

     ;; Haskell mode
     ;; `(haskell-operator-face ((,class (:foreground ,lime))))
     ;; `(haskell-type-face ((,class (:foreground ,light-yellow))))
     ;; `(haskell-constructor-face ((,class (:foreground ,orange))))

     ;; Perl6
     ;; `(perl6-identifier ((,class (:foreground ,cyan))))

     ;; Shell
     `(sh-quoted-exec ((,class (:foreground ,light-red))))

     ;; Evil ex
     `(evil-ex-info ((,class (:foreground ,orange))))
     `(evil-ex-substitute-matches ((,class (:background ,bg3 :underline t))))
     `(evil-ex-substitute-replacement ((,class (:background ,bg1 :foreground ,red))))
     '(evil-ex-lazy-highlight ((t (:inherit lazy-highlight))))

     ;; Ivy & Swiper
     `(ivy-current-match ((,class (:background nil :foreground ,light-green :bold nil))))
     `(ivy-minibuffer-match-face-1 ((,class (:background ,bg3 :foreground ,fg1))))
     `(ivy-minibuffer-match-face-2 ((,class (:background ,dark-blue :foreground ,teal-blue :bold ,bold))))
     `(ivy-minibuffer-match-face-3 ((,class (:background ,dark-yellow :foreground ,light-orange :bold ,bold))))
     `(ivy-minibuffer-match-face-4 ((,class (:background ,dark-purple :foreground ,light-purple :bold ,bold))))
     ;; `(ivy-current-match ((,class (:inherit hl-line :foreground ,hl))))
     `(swiper-match-face-1 ((,class (:background ,bg3 :foreground ,fg1))))
     `(swiper-match-face-2 ((,class (:background ,dark-blue :foreground ,teal-blue :bold ,bold))))
     `(swiper-match-face-3 ((,class (:background ,dark-yellow :foreground ,light-orange :bold ,bold))))
     `(swiper-match-face-4 ((,class (:background ,dark-purple :foreground ,light-purple :bold ,bold))))
     `(swiper-line-face ((,class (:inherit hl-line)))))))

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'kaolin)

;; Local Variables:
;; no-byte-compile: t
;; End:

;;; kaolin-theme.el ends here
