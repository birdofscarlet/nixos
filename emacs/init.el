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

(defun birdmacs/eglot-format-maybe ()
  "Format through the language server when eglot manages this buffer."
  (when (eglot-managed-p)
    (eglot-format-buffer)))

(defun birdmacs/eglot-format-on-save ()
  "Format the buffer through the language server when saving."
  (add-hook 'before-save-hook #'birdmacs/eglot-format-maybe nil t))

(use-package nix-mode
  :mode "\\.nix\\'"
  :hook (nix-mode . birdmacs/eglot-format-on-save))

(use-package eglot
  :hook ((nix-mode
          python-mode
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

;; ---------------------------------- ;;
;;        ASSEMBLY + REVERSING        ;;
;; ---------------------------------- ;;

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

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '((nasm-mode asm-mode) . ("asm-lsp"))))
(add-hook 'nasm-mode-hook #'eglot-ensure)
(add-hook 'asm-mode-hook #'eglot-ensure)

(use-package gdb-mi
  :custom
  (gdb-many-windows t)
  (gdb-show-main t)
  (gdb-restore-window-configuration-after-quit t))

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

(add-to-list 'display-buffer-alist
             '("\\*vterm-run\\*"
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . bottom)
               (window-height . 0.35)))

(defun birdmacs/vterm-run (cmd)
  "Run CMD in a fresh *vterm-run* buffer, replacing the previous run."
  (when-let* ((old (get-buffer "*vterm-run*")))
    (let ((kill-buffer-query-functions nil))
      (kill-buffer old)))
  (let ((buf (save-window-excursion (vterm "*vterm-run*"))))
    (pop-to-buffer buf)
    (with-current-buffer buf
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
  :custom
  (org-directory "~/org")
  (org-startup-indented t)
  (org-startup-with-inline-images t)
  (org-image-actual-width '(600))
  (org-hide-emphasis-markers t)
  (org-pretty-entities t)
  (org-ellipsis " …")
  (org-log-done 'time)
  (org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAIT(w)" "|" "DONE(d)" "DROP(x)")))
  (org-agenda-span 'week)
  (org-agenda-start-on-weekday nil)
  (org-agenda-skip-scheduled-if-done t)
  (org-agenda-skip-deadline-if-done t)
  (org-deadline-warning-days 7)
  :bind ("C-c a" . org-agenda)
  :hook ((org-mode . visual-line-mode)
         (org-mode . (lambda () (display-line-numbers-mode -1))))
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t) (shell . t) (C . t) (emacs-lisp . t)))
  (setq org-confirm-babel-evaluate
        (lambda (_lang _body)
          (not (string-prefix-p (expand-file-name "~/org/")
                                (or buffer-file-name ""))))))

(dolist (d '("courses" "htb" "attachments" "daily"))
  (make-directory (expand-file-name d "~/org/roam/") t))
(make-directory (expand-file-name "~/docs/courses/") t)

(defun birdmacs/pick-pdf ()
  "Ask for a PDF, starting in ~/docs/courses/."
  (abbreviate-file-name
   (expand-file-name
    (read-file-name "PDF: " "~/docs/courses/" nil t nil
                    (lambda (f) (or (file-directory-p f)
                                    (string-suffix-p ".pdf" f t)))))))

(defun birdmacs/org-agenda-refresh-files (&rest _)
  "Point the agenda at every org file under ~/org."
  (setq org-agenda-files
        (directory-files-recursively (expand-file-name "~/org/") "\\.org\\'")))
(advice-add 'org-agenda-prepare :before #'birdmacs/org-agenda-refresh-files)

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
     ("p" "course pdf (org-noter)" plain
      "* Notes\n:PROPERTIES:\n:NOTER_DOCUMENT: %(birdmacs/pick-pdf)\n:END:\n%?\n\n* Questions\n- Q: \n  A: \n"
      :target (file+head "courses/%<%Y%m%d>-${slug}.org"
                         "#+title: ${title}\n#+filetags: :course:\n")
      :unnarrowed t)
     ("h" "HTB box" plain
      "* Recon\n#+begin_src shell :dir /ssh:kali:~\nmkdir -p htb/${slug}\n#+end_src\n%?\n* Enumeration\n* Foothold\n* Privesc\n* Loot / flags\n* Lessons\n"
      :target (file+head "htb/${slug}.org"
                         "#+title: ${title}\n#+filetags: :htb:\n#+property: header-args:shell :dir /ssh:kali:~/htb/${slug} :results output\n")
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
        ("g" . org-roam-graph)
        ("d" . org-roam-dailies-capture-today)
        ("t" . org-roam-dailies-goto-today)
        ("y" . org-roam-dailies-goto-yesterday)
        ("D" . org-roam-dailies-goto-date)
        ("n" . org-noter))
  :config
  (setq org-roam-dailies-directory "daily/"
        org-roam-dailies-capture-templates
        '(("d" "default" entry "* %<%H:%M> %?"
           :target (file+head "%<%Y-%m-%d>.org" "#+title: %<%A, %B %d %Y>\n"))))
  (org-roam-db-autosync-mode))

(use-package consult-org-roam
  :init
  (with-eval-after-load 'org-roam
    (consult-org-roam-mode 1))
  :custom
  (consult-org-roam-grep-func #'consult-ripgrep)
  (consult-org-roam-buffer-narrow-key ?r)
  :bind
  (:map birdmacs/org-roam-map
        ("r" . consult-org-roam-search)
        ("b" . consult-org-roam-backlinks)
        ("o" . consult-org-roam-forward-links)))

(use-package org-download
  :custom
  (org-download-method 'directory)
  (org-download-image-dir (expand-file-name "~/org/roam/attachments/"))
  (org-download-heading-lvl nil)
  (org-download-timestamp "%Y%m%d-%H%M%S_")
  (org-download-screenshot-method "grim -g \"$(slurp)\" %s")
  :bind
  (:map birdmacs/org-roam-map
        ("s" . org-download-screenshot)
        ("p" . org-download-clipboard))
  :hook ((org-mode dired-mode) . org-download-enable))

(use-package org-modern
  :after org
  :custom
  (org-modern-star 'replace)
  (org-modern-replace-stars "◉○◈◇")
  (org-modern-hide-stars nil)
  (org-modern-table-vertical 1)
  (org-modern-block-fringe nil)
  :config
  (global-org-modern-mode))

(use-package olivetti
  :custom (olivetti-body-width 100)
  :hook (org-mode . olivetti-mode))

(use-package pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config
  (pdf-tools-install :no-query))

(use-package org-noter
  :commands org-noter
  :custom
  (org-noter-notes-search-path (list (expand-file-name "~/org/roam/")))
  (org-noter-always-create-frame nil))

;; ---------------------------------- ;;
;;           OOOH SHINY               ;;
;; ---------------------------------- ;;

(when birdmacs-jangling-keys
  (use-package mood-line
    :config
    (setq mood-line-glyph-alist mood-line-glyphs-unicode)
    (mood-line-mode))

  (use-package dashboard
    :init
    (setq dashboard-startup-banner 'official
          dashboard-center-content t
          dashboard-vertically-center-content t
          dashboard-items '((recents . 5))
          initial-buffer-choice (lambda ()
                                  (dashboard-open)
                                  (get-buffer dashboard-buffer-name)))
    :config
    (dashboard-setup-startup-hook)))

(provide 'init)
;;; init.el ends here
