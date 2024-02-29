;;; init.el --- Load the full configuration -*- lexical-binding: t -*-
;;; Commentary:

;; This file bootstraps the configuration, which is divided into
;; a number of other files.

;;; Code:

;; Produce backtraces when errors occur: can be helpful to diagnose startup issues

(let ((minver "26.1"))
  (when (version< emacs-version minver)
    (error "Your Emacs is too old -- this config requires v%s or higher" minver)))
(when (version< emacs-version "27.1")
  (message "Your Emacs is old, and some functionality in this config will be disabled. Please upgrade if possible."))

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))


;; Adjust garbage collection thresholds during startup, and thereafter

(let ((normal-gc-cons-threshold (* 20 1024 1024))
      (init-gc-cons-threshold (* 128 1024 1024)))
  (setq gc-cons-threshold init-gc-cons-threshold)
  (add-hook 'emacs-startup-hook
            (lambda () (setq gc-cons-threshold normal-gc-cons-threshold))))


;; Adjust some functions of native emacs

(electric-pair-mode t)                           ; Completion for parentheses
(add-hook 'prog-mode-hook #'show-paren-mode)     ; When the cursor is on a parenthesis, highlight the other one
(column-number-mode t)                           ; Show column number in mode line
(global-auto-revert-mode t)                      ; When file is changed by other program, emacs can refresh the buffer
(delete-selection-mode t)                        ; When select some words, type to replace, not just insert
(setq inhibit-startup-message t)                 ; Close emacs's welcome
(setq make-backup-files nil)                     ; Close the auto backup
(add-hook 'prog-mode-hook #'hs-minor-mode)       ; Be able to fold the code blocks
(global-display-line-numbers-mode 1)             ; Show the line numbers
(tool-bar-mode -1)                               ; Close the tool bar
(when (display-graphic-p) (toggle-scroll-bar -1)); Close the scroll bar
;(savehist-mode 1)                               ; Open buffer history
;(setq display-line-numbers-type 'relative)      ; Show relative line number
(add-to-list 'default-frame-alist '(width . 70)) ; Set default width
(add-to-list 'default-frame-alist '(height . 35)); Set default height
(setq-default tab-width 4)                       ; Set tab width to 4
(setq-default indent-tabs-mode nil)              ; Use spaces instead of tabs
(defvaralias 'c-basic-offset 'tab-width)         ; Set tab width in c or c-like language like c++, java


;; Key bind

(global-set-key (kbd "RET") 'newline-and-indent)

(defun next-ten-lines()
  "Move cursor to next 10 lines."
  (interactive)
  (forward-line 10))

(defun previous-ten-lines()
  "Move cursor to previous 10 lines."
  (interactive)
  (forward-line -10))

(defun type-four-spaces()
  "In Emacs,<tab> is bound to 'indent-for-tab-command',I use this to type 4 spaces."
  (interactive)
  (insert "    "))

(global-set-key (kbd "M-n") 'next-ten-lines)
(global-set-key (kbd "M-p") 'previous-ten-lines)
(global-set-key (kbd "C-j") nil)
(global-set-key (kbd "C-<tab>") 'type-four-spaces)

;; Font, coding system setting

(cond ((display-graphic-p)
  ; When using graphical emacs
  (set-face-attribute 'default nil :font "Jetbrains Mono-16")
  (set-fontset-font "fontset-default" 'unicode "Jetbrains Mono-16")
  (set-fontset-font "fontset-startup" 'unicode "Jetbrains Mono-16")
  (set-fontset-font "fontset-standard" 'unicode "Jetbrains Mono-16")
  (set-fontset-font "fontset-default" 'unicode "Noto Sans Mono CJK SC-16" nil 'append)
  (set-fontset-font "fontset-startup" 'unicode "Noto Sans Mono CJK SC-16" nil 'append)
  (set-fontset-font "fontset-standard" 'unicode "Noto Sans Mono CJK SC-16" nil 'append)
  ; this means when jetbrains mono doesn't have the character, noto mono will be the fallback font
  ; in this way we can display chinese character
  ; https://github.com/notofonts/noto-cjk/releases/tag/Sans2.004/  use the monospace version
  ; https://www.jetbrains.com/lp/mono/
  )
  (t
  ; When using console emacs
  ))

(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)
(set-keyboard-coding-system 'utf-8-unix)

(set-terminal-coding-system 'utf-8-unix) ; do this especially on Windows, else python output problem


;; ELPA,MELPA setting

(require 'package)
(setq package-archives '(("gnu" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("melpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")
                         ("nongnu" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")))
(package-initialize)


;; Settings for ICPC

(defun file-name-only ()
  "Get the current buffer file name without directory."
  (file-name-nondirectory (buffer-name)))

(defun file-name-only-noext ()
  "Get the currennt buffer file name without directory and extension."
  (file-name-sans-extension (file-name-only)))

(defun icpc-compile ()
  "Compile only one C++ file.  Just like code-runner in vscode."
  (interactive)
  (compile (concat "g++ "
				  (file-name-only)
                                  " -o "
				  (file-name-only-noext))))

(global-set-key (kbd "C-c c") 'icpc-compile)


;; Package

(eval-when-compile
  (require 'use-package))

(use-package good-scroll
  :ensure t
  :if window-system
  :init (good-scroll-mode))

(use-package mwim
  :ensure t
  :bind
  ("C-a" . mwim-beginning-of-code-or-line)
  ("C-e" . mwim-end-of-code-or-line))

(use-package all-the-icons
  :if (display-graphic-p)) ; After installion, restart emacs and use M-x all-the-icons-install-fonts.
                           ; And you need to install the fonts manually in Windows.

(use-package counsel
  :ensure t)

(use-package ivy
  :ensure t
  :init
  (ivy-mode 1)
  (counsel-mode 1)
  :config
  (setq ivy-use-virtual-buffers t)
  (setq search-default-mode #'char-fold-to-regexp)
  (setq ivy-count-format "(%d/%d) ")
  :bind
  (("C-s" . 'swiper)
   ("C-x b" . 'ivy-switch-buffer)
   ("C-c v" . 'ivy-push-view)
   ("C-c s" . 'ivy-switch-view)
   ("C-c V" . 'ivy-pop-view)
   ("C-x C-@" . 'counsel-mark-ring)
   ("C-x C-SPC" . 'counsel-mark-ring)
   :map minibuffer-local-map
   ("C-r" . counsel-minibuffer-history)))

(use-package amx
  :ensure t
  :init (amx-mode))

(use-package ace-window
  :ensure t
  :bind (("C-x o" . 'ace-window)))

(use-package undo-tree
  :ensure t
  :init (global-undo-tree-mode))

(use-package which-key
  :ensure t
  :init (which-key-mode))

(use-package flycheck
  :ensure t
  :config
  (setq truncate-lines nil)
  :hook
  (prog-mode . flycheck-mode))

(use-package solarized-theme
  :ensure t
  :config
  (setq solarized-use-more-italic t))

(use-package ayu-theme
  :ensure t)

(use-package dashboard
  :ensure t
  :config
  (setq dashboard-banner-logo-title "Welcome to Emacs!")
  (setq dashboard-projects-backend 'projectile)
  (setq dashboard-startup-banner 'official)
  (setq dashboard-items '((recents  . 5)
			  (bookmarks . 5)
			  (projects . 7)))
  (dashboard-setup-startup-hook))

(use-package yasnippet
  :ensure t
  :init (yas-global-mode 1))

(use-package highlight-symbol
  :ensure t
  :init (highlight-symbol-mode)
  :bind ("<f3>" . highlight-symbol))

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package avy
  :ensure t
  :bind
  (("C-j C-SPC" . avy-goto-char-timer)))

(use-package company
  :ensure t
  :init (global-company-mode)
  :config
  (setq company-minimum-prefix-length 1)
  (setq company-tooltip-align-annotations t)
  (setq company-idle-delay 0.0)
  (setq company-show-numbers t)
  (setq company-selection-wrap-around t)
  (setq company-transformers '(company-sort-by-occurrence))
  (setq company-text-icons-add-background 1)
  (setq company-format-margin-function 'company-text-icons-margin))

;(use-package company-box
;  :ensure t
;  :if window-system
;  :hook (company-mode . company-box-mode)
;  :init
;  (setq company-box-icons-alist 'company-box-icons-all-the-icons))

(use-package lsp-mode
  :ensure t
  :init
  (setq lsp-keymap-prefix "C-c l"
	lsp-file-watch-threshold 500)
  :hook
  (lsp-mode . lsp-enable-which-key-integration)
  :commands (lsp lsp-deferred)
  :config
  (setq lsp-headerline-breadcrumb-enable t)
  (setq lsp-idle-delay 0.0))

(use-package lsp-ui
  :ensure t
  :config
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions) ; M-.
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)   ; M-?
  (setq lsp-ui-doc-position 'top))

(use-package lsp-ivy
  :ensure t
  :after (lsp-mode))

(use-package projectile
  :ensure t
  :bind (("C-c p" . projectile-command-map))
  :config
  (setq projectile-mode-line "Projectile")
  (setq projectile-track-known-projects-automatically nil))

(use-package counsel-projectile
  :ensure t
  :after (projectile)
  :init (counsel-projectile-mode))

(use-package magit
  :ensure t)

(use-package neotree
  :ensure t
  :bind ("<f8>" . 'neotree-toggle)
  :config
  (setq projectile-switch-project-action 'neotree-projectile-action)
  (setq neo-theme (if (display-graphic-p) 'icons 'arrow))
  (setq neo-autorefresh 1))

(use-package c++-mode
  :functions
  c-toggle-hungry-state
  :hook
  (c-mode . lsp-deferred) ; when using lsp for c++, clangd is needed.
  (c++-mode . lsp-deferred)
  (c++-mode . c-toggle-hungry-state))

(use-package lsp-pyright ; pip install pyright
  :ensure t
  :config
  :hook
  (python-mode . (lambda ()
                 (require 'lsp-pyright
                 (lsp-deferred)))))

(use-package powerline
  :ensure t
  :init (powerline-default-theme))

(use-package yasnippet-snippets
  :ensure t)

(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)     ; GitHub Flavored Markdown
  :init (setq markdown-command "pandoc")) ; pandoc installation is needed

(use-package markdown-preview-mode
  :ensure t)

(add-to-list 'markdown-preview-javascript "http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML")

(use-package nasm-mode
  :ensure t)

(use-package cmake-mode
  :ensure t)

(use-package texfrag
  :ensure t)

(use-package goto-chg
  :ensure t)

(use-package evil
  :ensure t
  :init (evil-mode))

;; Theme

(cond ((display-graphic-p)
  ; When using graphical emacs
  ; (load-theme 'solarized-light t)
  (load-theme 'ayu-light t)
  )
  (t
  ; When using console emacs
  ; Better to use the terminal's theme
  ))


;; Other

(defun my/disable-line-numbers (&optional dummy)
    (display-line-numbers-mode -1))

(add-hook 'neo-after-create-hook 'my/disable-line-numbers) ; disable the line numbers in neotree

(setq custom-file (locate-user-emacs-file "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))

(provide 'init)

;;; init.el ends here
