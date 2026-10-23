;;; -*- lexical-binding: t -*-

(load custom-file t t)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(setq package-archive-priorities '(("gnu" . 3) ("nongnu" . 2) ("melpa" . 1))
      native-comp-async-report-warnings-errors 'silent)

(use-package magit
  :ensure t
  :defer t)

(use-package vundo
  :ensure t
  :bind ("C-x u" . vundo))

(use-package avy
  :ensure t
  :bind ("M-j" . avy-goto-char-timer))

(use-package apheleia
  :ensure t
  :hook (prog-mode . apheleia-mode))

(use-package emmet-mode
  :ensure t
  :hook ((html-ts-mode mhtml-ts-mode css-ts-mode tsx-ts-mode) . emmet-mode))

(use-package vterm
  :ensure t
  :bind ("C-c t" . vterm)
  :custom (vterm-always-compile-module t))

(use-package denote
  :ensure t
  :bind (("C-c n n" . denote)
         ("C-c n f" . denote-open-or-create)
         ("C-c n l" . denote-link)
         ("C-c n d" . denote-dired))
  :custom
  (denote-directory (expand-file-name "~/notes"))
  (denote-file-type 'markdown-yaml))

(use-package auctex
  :ensure t
  :defer t
  :hook (LaTeX-mode . eglot-ensure)
  :custom
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-PDF-mode t)
  (TeX-source-correlate-mode t)
  (TeX-source-correlate-start-server t)
  (TeX-view-program-selection '((output-pdf "Zathura")))
  (font-latex-fontify-script nil)
  (font-latex-fontify-sectioning 1.0))

(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 80
              display-line-numbers-width 3)

(setq ring-bell-function #'ignore
      use-short-answers t
      vc-follow-symlinks t
      create-lockfiles nil
      backup-directory-alist `(("." . ,(locate-user-emacs-file "backups")))
      auto-save-file-name-transforms `((".*" ,(locate-user-emacs-file "auto-save/") t))
      require-final-newline t
      sentence-end-double-space nil
      kill-do-not-save-duplicates t
      save-interprogram-paste-before-kill t
      help-window-select t
      enable-recursive-minibuffers t
      completions-detailed t
      tab-always-indent 'complete
      scroll-conservatively 101
      scroll-margin 2
      mouse-wheel-progressive-speed nil
      show-paren-delay 0
      frame-title-format "%b"
      window-divider-default-places t
      window-divider-default-right-width 1
      window-divider-default-bottom-width 1
      which-key-idle-delay 0.5
      recentf-max-saved-items 200
      global-auto-revert-non-file-buffers t
      auto-revert-verbose nil
      dired-listing-switches "-alh --group-directories-first"
      dired-dwim-target t
      dired-kill-when-opening-new-dired-buffer t
      xref-search-program 'ripgrep
      treesit-auto-install-grammar 'always
      warning-suppress-types '((eglot))
      eglot-autoshutdown t
      eglot-ignored-server-capabilities '(:inlayHintProvider)
      eglot-events-buffer-config '(:size 0))

(setopt treesit-enabled-modes t)

(make-directory (locate-user-emacs-file "auto-save") t)

(set-face-attribute 'default nil :family "0xProto Nerd Font" :height 100)

(fido-vertical-mode 1)
(global-completion-preview-mode 1)
(which-key-mode 1)
(savehist-mode 1)
(save-place-mode 1)
(recentf-mode 1)
(global-auto-revert-mode 1)
(delete-selection-mode 1)
(electric-pair-mode 1)
(repeat-mode 1)
(column-number-mode 1)
(window-divider-mode 1)
(pixel-scroll-precision-mode 1)
(blink-cursor-mode -1)

(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'prog-mode-hook #'hl-line-mode)
(add-hook 'text-mode-hook #'visual-line-mode)

(autoload 'markdown-ts-mode "markdown-ts-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-ts-mode))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '(markdown-ts-mode "marksman")))

(dolist (hook '(c-ts-mode-hook c++-ts-mode-hook html-ts-mode-hook css-ts-mode-hook
                js-ts-mode-hook typescript-ts-mode-hook tsx-ts-mode-hook
                markdown-ts-mode-hook))
  (add-hook hook #'eglot-ensure))

(keymap-global-set "C-x C-b" #'ibuffer)

(setq-default mode-line-format
              '("%e" mode-line-front-space
                (:eval (if (and buffer-file-name (buffer-modified-p)) "* " "  "))
                mode-line-buffer-identification "  "
                mode-line-position
                (vc-mode vc-mode) "  "
                mode-name
                (flymake-mode (" " flymake-mode-line-counters))
                mode-line-format-right-align
                mode-line-misc-info "  "))

(add-to-list 'custom-theme-load-path
             (file-name-directory (file-truename load-file-name)))

(defun dots-theme-reload ()
  (interactive)
  (when (load dots-palette-file t t)
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme 'dots t)))

(dots-theme-reload)

(require 'server)
(unless (or (daemonp) (server-running-p))
  (server-start))
