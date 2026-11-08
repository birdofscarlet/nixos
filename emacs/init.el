;;; init.el --- BIRDMACS -*- lexical-binding: t; -*-

;;; Code:

(defvar birdmacs-jangling-keys t
  "Non-nil enables cosmetic extras like the dashboard and modeline.")

;; ---------------------------------- ;;
;;         CORE CONFIGURATION         ;;
;; ---------------------------------- ;;

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
      read-process-output-max (* 1024 1024)
      gc-cons-threshold (* 100 1024 1024)
      byte-compile-warnings '(not free-vars unresolved)
      tab-always-indent 'complete)

(let ((backup-dir (expand-file-name "backups/" user-emacs-directory)))
  (make-directory backup-dir t)
  (setq backup-directory-alist `((".*" . ,backup-dir))))

;; ---------------------------------- ;;
;;            APPEARANCE              ;;
;; ---------------------------------- ;;

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

(add-to-list 'custom-theme-load-path
             (expand-file-name "themes/" user-emacs-directory))
(load-theme 'modus-vivendi t)
(condition-case err
    (load-theme 'graphite-mono t)
  (error (message "graphite-mono theme not loaded: %s"
                  (error-message-string err))))

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

(dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook))
  (add-hook hook #'display-line-numbers-mode))

(add-hook 'prog-mode-hook
          (lambda ()
            (add-hook 'before-save-hook #'delete-trailing-whitespace nil t)))

(global-set-key (kbd "<escape>") #'keyboard-escape-quit)
(global-set-key (kbd "M-/") #'completion-at-point)

;; ---------------------------------- ;;
;;        PACKAGE MANAGEMENT          ;;
;; ---------------------------------- ;;

(require 'use-package)
(setq use-package-always-ensure nil)

(use-package which-key
  :config
  (which-key-mode))

;; ---------------------------------- ;;
;;            COMPLETION              ;;
;; ---------------------------------- ;;

(use-package vertico
  :init
  (vertico-mode)
  :custom
  (vertico-cycle t))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides
   '((file (styles partial-completion))
     (eglot (styles orderless)))))

(use-package marginalia
  :init
  (marginalia-mode)
  :custom
  (marginalia-align 'right))

(use-package consult
  :bind (("C-s"   . consult-line)
         ("C-x b" . consult-buffer)
         ("C-c b" . consult-buffer)
         ("C-c k" . consult-ripgrep))
  :custom
  (consult-preview-key '(:debounce 0.2 any)))

(use-package embark
  :bind (("C-."   . embark-act)
         ("C-;"   . embark-dwim)
         ("C-h B" . embark-bindings))
  :init
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package avy
  :bind (("C-c j" . avy-goto-char-timer)
         ("M-g l" . avy-goto-line)
         ("M-g w" . avy-goto-word-1))
  :custom
  (avy-all-windows t)
  (avy-timeout-seconds 0.3))

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
  (corfu-preselect 'prompt)
  :config
  (add-hook 'minibuffer-setup-hook (lambda () (corfu-mode -1)))
  (corfu-popupinfo-mode)
  (define-key corfu-map (kbd "M-SPC") #'corfu-insert-separator))

(use-package cape
  :init
  (add-hook 'prog-mode-hook
            (lambda ()
              (add-hook 'completion-at-point-functions #'cape-file -10 t)))
  (add-hook 'text-mode-hook
            (lambda ()
              (add-hook 'completion-at-point-functions #'cape-dabbrev nil t))))

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
  :hook (python-mode . (lambda ()
                         (setq-local tab-width 4)
                         (setq-local indent-tabs-mode nil))))

(use-package powershell
  :mode ("\\.ps1\\'" . powershell-mode))

;; ---------------------------------- ;;
;;        ASSEMBLY + REVERSING        ;;
;; ---------------------------------- ;;

;; .asm/.nasm -> nasm-mode (Intel syntax); .s/.S stay in built-in asm-mode (GAS).
;; In nasm-mode:  C-c C-c build   C-c C-r run in vterm
;;                C-c C-d gdb (many-windows)   C-c C-g gef in vterm
;; A Makefile next to the file wins over the default nasm+ld command.

(defun birdmacs/asm-binary ()
  "Executable name for the current assembly buffer."
  (file-name-sans-extension (file-name-nondirectory buffer-file-name)))

(defun birdmacs/asm-compile-command ()
  "nasm + ld for the current file: 64-bit ELF with DWARF debug info."
  (let ((src (shell-quote-argument (file-name-nondirectory buffer-file-name)))
        (bin (shell-quote-argument (birdmacs/asm-binary))))
    (format "nasm -f elf64 -g -F dwarf %s -o %s.o && ld %s.o -o %s"
            src bin bin bin)))

(defun birdmacs/asm-setup ()
  "Buffer-local setup for assembly buffers."
  (setq-local indent-tabs-mode nil
              tab-width 8)
  (when (and buffer-file-name
             (not (file-exists-p (expand-file-name "Makefile"))))
    (setq-local compile-command (birdmacs/asm-compile-command))))

(defun birdmacs/asm-run ()
  "Run the built binary for this buffer in vterm."
  (interactive)
  (birdmacs/vterm-run
   (format "cd %s && ./%s"
           (shell-quote-argument default-directory)
           (shell-quote-argument (birdmacs/asm-binary)))))

(defun birdmacs/asm-gdb ()
  "Debug the built binary with Emacs' gdb UI."
  (interactive)
  (gdb (format "gdb -i=mi %s"
               (shell-quote-argument
                (expand-file-name (birdmacs/asm-binary))))))

(defun birdmacs/asm-gef ()
  "Debug the built binary with gef in vterm."
  (interactive)
  (birdmacs/vterm-run
   (format "cd %s && gef ./%s"
           (shell-quote-argument default-directory)
           (shell-quote-argument (birdmacs/asm-binary)))))

(use-package nasm-mode
  :mode ("\\.\\(nasm\\|asm\\)\\'" . nasm-mode)
  :hook (nasm-mode . birdmacs/asm-setup)
  :bind (:map nasm-mode-map
              ("C-c C-c" . compile)
              ("C-c C-r" . birdmacs/asm-run)
              ("C-c C-d" . birdmacs/asm-gdb)
              ("C-c C-g" . birdmacs/asm-gef)))

(add-hook 'asm-mode-hook #'birdmacs/asm-setup)

;; asm-lsp: hover docs for instructions/registers + nasm diagnostics.
;; Global config in ~/.config/asm-lsp (from modules/home/security.nix).
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '((nasm-mode asm-mode) . ("asm-lsp"))))
(add-hook 'nasm-mode-hook #'eglot-ensure)
(add-hook 'asm-mode-hook #'eglot-ensure)

(use-package gdb-mi
  :custom
  (gdb-many-windows t)
  (gdb-show-main t)
  (gdb-restore-window-configuration-after-quit t))

;; C -> assembly. disaster: objdump of the object for the line at point.
;; rmsbolt: live compiler-explorer view (M-x rmsbolt in a C buffer).
(use-package disaster
  :bind ("C-c d" . disaster)
  :custom
  (disaster-objdump "objdump -d -M intel -Sl --no-show-raw-insn"))

(use-package rmsbolt
  :commands rmsbolt
  :custom (rmsbolt-asm-format "intel"))

(use-package x86-lookup
  :bind ("C-c x" . x86-lookup)
  :custom (x86-lookup-pdf (expand-file-name "~/docs/intel-sdm.pdf")))

;; binaries: hex view and readelf-style view
(use-package nhexl-mode :commands nhexl-mode)
(use-package elf-mode
  :commands elf-mode
  :magic ("\dELF" . elf-mode))

(use-package subword
  :hook (prog-mode . subword-mode))

(use-package magit
  :bind ("C-x g" . magit-status))

(use-package envrc
  :hook (after-init . envrc-global-mode))

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
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t) (shell . t) (C . t) (emacs-lisp . t)))
  (setq org-confirm-babel-evaluate
        (lambda (_lang _body)
          (not (string-prefix-p (expand-file-name "~/org/")
                                (or buffer-file-name ""))))))

(dolist (d '("courses" "htb" "attachments"))
  (make-directory (expand-file-name d "~/org/roam/") t))

(use-package org-roam
  :custom
  (org-roam-directory (file-truename "~/org/roam"))
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

(use-package pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config
  (pdf-tools-install :no-query))

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
          initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
    :config
    (dashboard-setup-startup-hook)))

(provide 'init)
;;; init.el ends here
