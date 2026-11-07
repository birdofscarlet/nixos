;;; graphite-mono-theme.el --- Monochrome UI, muted syntax accents -*- lexical-binding: t; -*-

;;; Commentary:
;; Pure-black grayscale UI meant for translucent frames.  Layer it over
;; modus-vivendi so faces it doesn't define (magit, diagnostics) stay sane:
;;   (load-theme 'modus-vivendi t)
;;   (load-theme 'graphite-mono t)

;;; Code:

(deftheme graphite-mono "Pure-black monochrome UI with muted syntax accents.")

(let ((bg   "#000000") (bg-1 "#111111") (bg-2 "#222222") (bg-3 "#333333")
      (dim  "#444444") (mid  "#777777") (sub  "#999999") (soft "#cccccc")
      (fg   "#ffffff"))
  (custom-theme-set-faces
   'graphite-mono
   ;; chrome
   `(default ((t (:foreground ,fg :background ,bg))))
   `(cursor ((t (:background ,fg))))
   `(region ((t (:background ,bg-3 :extend t))))
   `(highlight ((t (:background ,bg-2))))
   `(hl-line ((t (:background ,bg-1))))
   `(fringe ((t (:background ,bg))))
   `(vertical-border ((t (:foreground ,bg-3))))
   `(window-divider ((t (:foreground ,bg-3))))
   `(window-divider-first-pixel ((t (:foreground ,bg-3))))
   `(window-divider-last-pixel ((t (:foreground ,bg-3))))
   `(line-number ((t (:foreground ,dim :background ,bg))))
   `(line-number-current-line ((t (:foreground ,soft :background ,bg-1))))
   `(minibuffer-prompt ((t (:foreground ,fg :weight bold))))
   `(shadow ((t (:foreground ,sub))))
   `(link ((t (:foreground ,soft :underline t))))
   `(show-paren-match ((t (:foreground ,fg :background ,bg-3 :weight bold))))
   `(isearch ((t (:foreground ,bg :background ,fg))))
   `(lazy-highlight ((t (:foreground ,fg :background ,bg-3))))
   `(mode-line ((t (:foreground ,fg :background ,bg-1 :box nil))))
   `(mode-line-inactive ((t (:foreground ,mid :background ,bg :box nil))))
   ;; code (muted accents)
   `(font-lock-comment-face ((t (:foreground ,mid :slant italic))))
   `(font-lock-doc-face ((t (:foreground ,mid))))
   `(font-lock-string-face ((t (:foreground "#a3be8c"))))
   `(font-lock-keyword-face ((t (:foreground "#c4a7e7" :weight bold))))
   `(font-lock-builtin-face ((t (:foreground "#c4a7e7"))))
   `(font-lock-function-name-face ((t (:foreground "#8fbcbb"))))
   `(font-lock-variable-name-face ((t (:foreground ,soft))))
   `(font-lock-type-face ((t (:foreground "#e5c07b"))))
   `(font-lock-constant-face ((t (:foreground "#d08770"))))
   `(font-lock-preprocessor-face ((t (:foreground "#7aa2f7"))))
   ;; completion
   `(vertico-current ((t (:background ,bg-2 :extend t))))
   `(corfu-default ((t (:foreground ,fg :background ,bg-1))))
   `(corfu-current ((t (:background ,bg-2))))
   `(corfu-border ((t (:background ,bg-3))))
   `(orderless-match-face-0 ((t (:foreground ,fg :weight bold :underline t))))
   `(orderless-match-face-1 ((t (:foreground ,soft :weight bold :underline t))))
   `(orderless-match-face-2 ((t (:foreground ,sub :weight bold :underline t))))
   `(orderless-match-face-3 ((t (:foreground ,mid :weight bold :underline t))))
   ;; org
   `(org-level-1 ((t (:foreground ,fg :weight bold))))
   `(org-level-2 ((t (:foreground ,soft :weight bold))))
   `(org-level-3 ((t (:foreground ,sub :weight bold))))
   `(org-block ((t (:background ,bg-1 :extend t))))
   `(org-block-begin-line ((t (:foreground ,dim :background ,bg-1 :extend t))))
   `(org-block-end-line ((t (:foreground ,dim :background ,bg-1 :extend t))))))

(provide-theme 'graphite-mono)

;;; graphite-mono-theme.el ends here
