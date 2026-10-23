;;; -*- lexical-binding: t -*-

(setq user-emacs-directory (expand-file-name "~/.local/share/emacs/")
      package-user-dir (expand-file-name "elpa" user-emacs-directory)
      custom-file (expand-file-name "custom.el" user-emacs-directory))
(startup-redirect-eln-cache (expand-file-name "eln-cache" user-emacs-directory))

(setq gc-cons-threshold (* 64 1024 1024)
      read-process-output-max (* 1024 1024)
      inhibit-startup-screen t
      inhibit-startup-echo-area-message user-login-name
      initial-scratch-message nil
      frame-resize-pixelwise t
      frame-inhibit-implied-resize t)

(defvar dots-palette-file (expand-file-name "~/.cache/theme/emacs.el"))
(defvar dots-palette nil)
(load dots-palette-file t t)

(setq default-frame-alist
      `((menu-bar-lines . 0)
        (tool-bar-lines . 0)
        (vertical-scroll-bars)
        (horizontal-scroll-bars)
        (internal-border-width . 12)
        ,@(when dots-palette
            `((background-color . ,(alist-get 'bg dots-palette))
              (foreground-color . ,(alist-get 'fg dots-palette))))))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
