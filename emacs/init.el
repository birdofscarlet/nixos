;;; init.el --- BIRDMACS -*- lexical-binding: t; -*-

;;; Commentary:
;; Sections: core, appearance, behavior, package management, completion,
;; programming, notes, shiny.

;;; Code:

(defvar birdmacs-jangling-keys t
  "Non-nil enables cosmetic extras like the dashboard and modeline.")

;; ---------------------------------- ;;
;;         CORE CONFIGURATION         ;;
;; ---------------------------------- ;;

;; Keep Customize output out of this file.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror 'nomessage)

(setq image-dired-external-viewer "imv"
      inhibit-startup-screen t
      ring-bell-function 'ignore
      use-short-answers t
      scroll-step 1
      scroll-conservatively 101
      display-line-numbers-type 'relative
      create-lockfiles nil
      read-process-output-max (* 1024 1024) ; faster LSP I/O
      gc-cons-threshold (* 100 1024 1024)
      byte-compile-warnings '(not free-vars unresolved)
      tab-always-indent 'complete
      user-emacs-directory "~/nixconfig/emacs/")

;; Backups live in one folder instead of next to the files.
(let ((backup-dir (expand-file-name "backups/" user-emacs-directory)))
  (make-directory backup-dir t)
  (setq backup-directory-alist `((".*" . ,backup-dir))))


;; ---------------------------------- ;;
;;            APPEARANCE              ;;
;; ---------------------------------- ;;

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;; graphite-mono sits on top of Modus: Modus supplies sane defaults for faces
;; the overlay doesn't touch (magit diffs, diagnostics, ...).
(add-to-list 'custom-theme-load-path
             (expand-file-name "themes/" user-emacs-directory))
(load-theme 'modus-vivendi t)
(condition-case err
    (load-theme 'graphite-mono t)
  (error (message "graphite-mono theme not loaded: %s"
                  (error-message-string err))))

;; Translucent frames. The alist covers daemon/client frames, the
;; frame parameter covers an already-open first frame.
(add-to-list 'default-frame-alist '(alpha-background . 75))
(set-frame-parameter nil 'alpha-background 75)

;; ---------------------------------- ;;
;;             BEHAVIOR               ;;
;; ---------------------------------- ;;

(electric-pair-mode 1)
(global-hl-line-mode 1)
(show-paren-mode 1)
(global-eldoc-mode 1)
(global-auto-revert-mode 1)

(recentf-mode 1)
(savehist-mode 1)
(save-place-mode 1)
(delete-selection-mode 1)

;; Line numbers only where they help (not in terminals, PDFs, dashboard...).
(dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook))
  (add-hook hook #'display-line-numbers-mode))

;; Strip trailing whitespace in code only, so patches, diffs and
;; Markdown hard line breaks stay intact.
(add-hook 'prog-mode-hook
          (lambda ()
            (add-hook 'before-save-hook #'delete-trailing-whitespace nil t)))

(global-set-key (kbd "<escape>") #'keyboard-escape-quit)
(global-set-key (kbd "M-/") #'completion-at-point)

;; ---------------------------------- ;;
;;        PACKAGE MANAGEMENT          ;;
;; ---------------------------------- ;;

(require 'package)
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/")))

(package-initialize)

(unless (package-installed-p 'use-package)
  (unless package-archive-contents
    (package-refresh-contents))
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure nil)

(use-package which-key
  :config
  (which-key-mode))

;; ---------------------------------- ;;
;;         COMPLETION STUFF           ;;
;; ---------------------------------- ;;

;; vertico - minibuffer UI
(use-package vertico
  :init
  (vertico-mode)
  :custom
  (vertico-cycle t))

;; orderless - fuzzy matching
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides
   '((file (styles partial-completion))
     (eglot (styles orderless)))))

;; marginalia - annotations
(use-package marginalia
  :init
  (marginalia-mode)
  :custom
  (marginalia-align 'right))

;; consult - search/navigation
(use-package consult
  :bind (("C-s"   . consult-line)
         ("C-x b" . consult-buffer)
         ("C-c b" . consult-buffer)
         ("C-c k" . consult-ripgrep))
  :custom
  (consult-preview-key '(:debounce 0.2 any)))

;; embark - act on whatever is at point / in a completion list
(use-package embark
  :bind (("C-."   . embark-act)
         ("C-;"   . embark-dwim)
         ("C-h B" . embark-bindings))
  :init
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; avy - jump to any visible text
(use-package avy
  :bind (("C-c j" . avy-goto-char-timer)
         ("M-g l" . avy-goto-line)
         ("M-g w" . avy-goto-word-1))
  :custom
  (avy-all-windows t)
  (avy-timeout-seconds 0.3))

;; corfu - in-buffer completion
(use-package corfu
  :init
  (global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.08)
  (corfu-auto-prefix 1)
  (corfu-cycle t)
  (corfu-separator ?\s)
  (corfu-popupinfo-delay 0.2)
  (corfu-preselect 'prompt)             ; don't auto-select the first candidate
  :config
  ;; Corfu stays out of the minibuffer (Vertico owns it).
  (add-hook 'minibuffer-setup-hook (lambda () (corfu-mode -1)))
  (corfu-popupinfo-mode)
  (define-key corfu-map (kbd "M-SPC") #'corfu-insert-separator))

;; cape - extra completion sources
(use-package cape
  :init
  (add-hook 'prog-mode-hook
            (lambda ()
              (add-hook 'completion-at-point-functions #'cape-file -10 t)))
  (add-hook 'text-mode-hook
            (lambda ()
              (add-hook 'completion-at-point-functions #'cape-dabbrev nil t))))

;; shiny icons in the completion popup
(use-package kind-icon
  :after corfu
  :custom
  (kind-icon-blend-background t)
  (kind-icon-default-face 'corfu-default)
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;; ---------------------------------- ;;
;;            PROGRAMMING             ;;
;; ---------------------------------- ;;

(defun birdmacs/eglot-format-on-save ()
  "Format the buffer through the language server when saving."
  (add-hook 'before-save-hook #'eglot-format-buffer nil t))

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package eglot
  :ensure nil
  :hook ((nix-mode
          python-mode
          powershell-mode
          scheme-mode
          c-mode
          c++-mode) . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs '(nix-mode . ("nixd")))
  (setq-default eglot-workspace-configuration
                '(:nixd (:formatting (:command ["nixfmt"])))))


(use-package python
  :ensure nil
  :hook (python-mode . (lambda ()
                         (setq-local tab-width 4)
                         (setq-local indent-tabs-mode nil))))

(use-package powershell
  :mode ("\\.ps1\\'" . powershell-mode))

;; assembly / reversing helpers
(use-package nasm-mode :mode "\\.nasm\\'")
(use-package disaster :bind ("C-c d" . disaster))
(use-package x86-lookup
  :bind ("C-c x" . x86-lookup)
  :custom (x86-lookup-pdf "~/docs/intel-sdm.pdf"))

;; better word navigation (camelCase, etc.)
(use-package subword
  :ensure nil
  :hook (prog-mode . subword-mode))

(use-package magit
  :bind ("C-x g" . magit-status))

;; per-project environments from direnv / nix flakes
(use-package envrc
  :hook (after-init . envrc-global-mode))

;; vterm
(use-package vterm
  :commands vterm
  :custom
  (vterm-max-scrollback 5000)
  (vterm-kill-buffer-on-exit t)
  :config
  (define-key vterm-mode-map (kbd "C-c C-j") #'vterm-copy-mode)
  (define-key vterm-copy-mode-map (kbd "C-c C-k") #'vterm-copy-mode))

(defun birdmacs/toggle-vterm ()
  "Show the *vterm* buffer, or bury it when already in it."
  (interactive)
  (let ((buf (get-buffer "*vterm*")))
    (cond ((null buf) (vterm))
          ((eq (current-buffer) buf) (bury-buffer))
          (t (switch-to-buffer buf)))))

(defun birdmacs/vterm-project ()
  "Open vterm in the current project's root."
  (interactive)
  (let ((default-directory
         (if-let* ((proj (project-current)))
             (project-root proj)
           default-directory)))
    (vterm)))

(defun birdmacs/vterm-run (cmd)
  "Send CMD to the *vterm* buffer, creating it if needed."
  (let ((buf (or (get-buffer "*vterm*") (vterm))))
    (with-current-buffer buf
      (goto-char (point-max))
      (vterm-send-string cmd)
      (vterm-send-return))))

(defun birdmacs/run-python-file ()
  "Run the current file with python in the vterm buffer."
  (interactive)
  (birdmacs/vterm-run
   (format "python %s" (shell-quote-argument (buffer-file-name)))))

(global-set-key (kbd "C-c t") #'vterm)
(global-set-key (kbd "C-c T") #'birdmacs/vterm-project)
(global-set-key (kbd "C-`")   #'birdmacs/toggle-vterm)
(global-set-key (kbd "C-c r") #'birdmacs/run-python-file)
(global-set-key (kbd "C-c m") #'project-compile)

;; ---------------------------------- ;;
;;      NOTES: COURSES + HTB          ;;
;; ---------------------------------- ;;

(use-package org
  :ensure nil
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t) (shell . t) (C . t) (emacs-lisp . t)))

  ;; Only run babel blocks without asking inside ~/org/ (your own notes).
  ;; Org files from anywhere else prompt first.
  (setq org-confirm-babel-evaluate
        (lambda (_lang _body)
          (not (string-prefix-p (expand-file-name "~/org/")
                                (or buffer-file-name ""))))))

(dolist (d '("courses" "htb" "attachments"))
  (make-directory (expand-file-name d "~/org/roam/") t))

(use-package org-roam
  :custom
  (org-roam-directory (file-truename "~/org/roam"))
  ;; templates: default, course note, HTB box
  (org-roam-capture-templates
   '(("d" "default" plain "%?"
      :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n")
      :unnarrowed t)
     ("c" "course note" plain
      "* Summary (own words)\n%?\n\n* Diagrams / source\n\n* Questions\n- Q: \n  A: \n"
      :target (file+head "courses/%<%Y%m%d>-${slug}.org"
                         "#+title: ${title}\n#+filetags: :course:\n")
      :unnarrowed t)
     ("h" "HTB box" plain
      "* Recon\n%?\n* Enumeration\n* Foothold\n* Privesc\n* Loot / flags\n* Lessons\n"
      :target (file+head "htb/${slug}.org"
                         "#+title: ${title}\n#+filetags: :htb:\n#+property: header-args:shell :dir /ssh:kali:~/htb/${slug}\n")
      :unnarrowed t)))
  :init
  (define-prefix-command 'birdmacs/org-roam-map)
  (global-set-key (kbd "C-c n") 'birdmacs/org-roam-map)
  :bind
  (:map birdmacs/org-roam-map
        ("l" . org-roam-buffer-toggle)
        ("f" . org-roam-node-find)
        ("i" . org-roam-node-insert)
        ("c" . org-roam-capture)
        ("g" . org-roam-graph))
  :config
  (org-roam-db-autosync-mode))

;; pdf-tools - read PDFs (Boox exports, docs) inside Emacs
(use-package pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config
  (pdf-tools-install :no-query))

;; org-noter - typed notes beside a PDF, linked to pages
(use-package org-noter
  :custom
  (org-noter-notes-search-path (list (expand-file-name "~/org/roam/")))
  (org-noter-always-create-frame nil))

;; ---------------------------------- ;;
;;           OOOH SHINY               ;;
;; ---------------------------------- ;;

(when birdmacs-jangling-keys
  (use-package mood-line
    :config (mood-line-mode))

  (use-package dashboard
    :init
    (setq dashboard-startup-banner 'official
          dashboard-center-content t
          dashboard-vertically-center-content t
          dashboard-items '((recents . 5))
          ;; works for emacsclient frames too
          initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
    :config
    (dashboard-setup-startup-hook)))

(provide 'init)
;;; init.el ends here
