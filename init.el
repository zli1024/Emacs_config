;;; init.el --- Load the full configuration -*- lexical-binding: t -*-
;;; Commentary:

;; This file bootstraps the configuration, which is divided into
;; a number of other files.

;;; Code:

;; Produce backtraces when errors occur: can be helpful to diagnose startup issues
;;(setq debug-on-error t)

(let ((minver "27.1"))
  (when (version< emacs-version minver)
    (error "Your Emacs is too old -- this config requires v%s or higher" minver)))
(when (version< emacs-version "28.1")
  (message "Your Emacs is old, and some functionality in this config will be disabled. Please upgrade if possible."))

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory)) ; 设定源码加载路径

(defconst *spell-check-support-enabled* nil) ;; Enable with t if you prefer
(defconst *is-a-mac* (eq system-type 'darwin))

;; Fundamental configuration
;(setq confirm-kill-emacs #'yes-or-no-p) ; 在关闭 Emacs 前询问是否确认关闭，防止误触
(electric-pair-mode t) ; 自动补全括号
(add-hook 'prog-mode-hook #'show-paren-mode) ; 编程模式下，光标在括号上时高亮另一个括号
(column-number-mode t)                       ; 在 Mode line 上显示列号
(global-auto-revert-mode t)                  ; 当另一程序修改了文件时，让 Emacs 及时刷新 Buffer
(delete-selection-mode t)                    ; 选中文本后输入文本会替换文本（更符合我们习惯了的其它编辑器的逻辑）
(setq inhibit-startup-message t)             ; 关闭启动 Emacs 时的欢迎界面
(setq make-backup-files nil)                 ; 关闭文件自动备份
(add-hook 'prog-mode-hook #'hs-minor-mode)   ; 编程模式下，可以折叠代码块
(global-display-line-numbers-mode 1)         ; 在 Window 显示行号
(tool-bar-mode -1)                           ;（熟练后可选）关闭 Tool bar
(when (display-graphic-p) (toggle-scroll-bar -1)) ; 图形界面时关闭滚动条

(savehist-mode 1)                            ;（可选）打开 Buffer 历史记录保存
(setq display-line-numbers-type 'relative)   ;（可选）显示相对行号
(add-to-list 'default-frame-alist '(width . 190))  ; （可选）设定启动图形界面时的初始 Frame 宽度（字符数）
(add-to-list 'default-frame-alist '(height . 155)) ; （可选）设定启动图形界面时的初始 Frame 高度（字符数）
(set-face-attribute 'default nil :height 130)

(setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))



;; Keyboard shortcut
(global-set-key (kbd "RET") 'newline-and-indent)
(global-set-key (kbd "M-w") 'kill-region)              ; 交换 M-w 和 C-w，M-w 为剪切
(global-set-key (kbd "C-w") 'kill-ring-save)           ; 交换 M-w 和 C-w，C-w 为复制
(global-set-key (kbd "C-a") 'back-to-indentation)      ; 交换 C-a 和 M-m，C-a 为到缩进后的行首
(global-set-key (kbd "M-m") 'move-beginning-of-line)   ; 交换 C-a 和 M-m，M-m 为到真正的行首
(global-set-key (kbd "C-c '") 'comment-or-uncomment-region) ; 为选中的代码加注释/去注释
(global-set-key (kbd "C-j") nil)
;; ----删去光标所在行（在图形界面时可以用 "C-S-<DEL>"，终端常会拦截这个按法) ----
(global-set-key (kbd "C-j C-k") 'kill-whole-line)
;; 自定义两个函数
;; Faster move cursor
(defun next-ten-lines()
  "Move cursor to next 10 lines."
  (interactive)
  (next-line 10))

(defun previous-ten-lines()
  "Move cursor to previous 10 lines."
  (interactive)
  (previous-line 10))
;; 绑定到快捷键
(global-set-key (kbd "M-n") 'next-ten-lines)            ; 光标向下移动 10 行
(global-set-key (kbd "M-p") 'previous-ten-lines)        ; 光标向上移动 10 行


;; Package-archives
(require 'package)
;(setq package-archives '(("gnu"    . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
;                        ("nongnu" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
;                        ("melpa"  . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)

(package-initialize) ;; You might already have this line


;; use-package
(eval-when-compile
  (require 'use-package))

;; ---- ivy ----
(use-package counsel
  :ensure t)

(use-package ivy
  :ensure t
  :config
  (ivy-mode 1)
  (counsel-mode 1)
  :config
  (setq ivy-use-virtual-buffers t)
  (setq search-default-mode #'char-fold-to-regexp)
  (setq ivy-count-format "(%d/%d) ")
  :bind
  ("C-s" . 'swiper-isearch)
  ("C-x b" . 'ivy-switch-buffer)
  ("C-c v" . 'ivy-push-view)
  ("C-c s" . 'ivy-switch-view)
  ("C-c V" . 'ivy-pop-view)
  ("C-x C-@" . 'counsel-mark-ring)
  ("C-x C-SPC" . 'counsel-mark-ring))


;; ---- hydra ----
(use-package hydra
  :ensure t)

(use-package use-package-hydra
  :ensure t
  :after hydra)


;; ---- amx ----
(use-package amx
  :ensure t
  :init (amx-mode))


;; ---- ace-window ----
(use-package ace-window
  :ensure t
  :bind ("C-x o" . 'ace-window))

;; ---- mwim ----
(use-package mwim
  :ensure t
  :bind
  ("C-a" . mwim-beginning-of-code-or-line)
  ("C-e" . mwim-end-of-code-or-line))


;; ---- undo-tree ----
(use-package undo-tree
  :ensure t
  :init (global-undo-tree-mode)
  :after hydra
  :custom (undo-tree-auto-save-history nil)
  :bind("C-x C-h u" . hydra-undo-tree/body)
  :hydra (hydra-undo-tree (:hint nil)
  "
  _p_: undo _n_: redo _s_: save _l_: load  "
  ("p"  undo-tree-undo)
  ("n"  undo-tree-redo)
  ("s"  undo-tree-save-history)
  ("l"  undo-tree-load-history)
  ("u"  undo-tree-visualize "visualize" :color blue)
  ("q"  nil "quit" :color blue)))


;;; Themes
;; ---- Dracula-theme ----
;(load-theme 'dracula t)

;; ---- Doom-themes ----
(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-challenger-deep t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

;; ---- all-the-icons ----
(when (display-graphic-p)
  (require 'all-the-icons))
;; or
;(use-package all-the-icons
;  :if (display-graphic-p))


;; ---- powerline ----
(require 'powerline)
(powerline-center-theme)

;; ---- smart-mode-line ----
;; An atom-one-dark theme for smart-mode-line
;; (use-package smart-mode-line-atom-one-dark-theme
;;   :ensure t)

;; ;; smart-mode-line
;; (use-package smart-mode-line
;;   :config
;;   (setq sml/theme 'atom-one-dark)
;;   (sml/setup)
;;   (sml/apply-theme 'powerline)
;;   (setq rm-blacklist
;;        (format "^ \\(%s\\)$"
;;    	   (mapconcat #'identity
;; 		      '("Projectile.*" "company.*" "Google"
;; 			"Undo-Tree" "counsel" "ivy" "yas" "WK"
;; 		      "\\|")))))

;; ---- doom-modeline ----
(add-hook 'after-init-hook #'doom-modeline-mode)

;(use-package smart-mode-line-powerline-theme
;  :ensure t
;  :after powerline
;  :after smart-mode-line
;  :config
;  (sml/setup)
;  (sml/apply-theme 'powerline)
;  (setq rm-blacklist
;	(format "^ \\(%s\\)$"
;	    (mapconcat #'identity
;		       '("Projectile.*" "company.*" "Google"
;			 "Undo-Tree" "counsel" "ivy" "yas" "WK")
;		       "\\|"))))


;; ---- which key ----
(use-package which-key
  :ensure t
  :init (which-key-mode))


;; ---- avy ----
(use-package avy
  :ensure t
  :bind
  ("C-j C-SPC" . avy-goto-char-timer))

;; ---- marginalia ----
(use-package marginalia
  :ensure t
  :init (marginalia-mode)
  :bind (:map minibuffer-local-map
			  ("M-A" . marginalia-cycle)))


;; ---- multiple-cursors ----
(use-package multiple-cursors
  :ensure t
  :after hydra
  :bind
  (("C-x C-h m" . hydra-multiple-cursors/body)
   ("C-S-<mouse-1>" . mc/toggle-cursor-on-click))
  :hydra (hydra-multiple-cursors
		  (:hint nil)
		  "
Up^^             Down^^           Miscellaneous           % 2(mc/num-cursors) cursor%s(if (> (mc/num-cursors) 1) \"s\" \"\")
------------------------------------------------------------------
 [_p_]   Prev     [_n_]   Next     [_l_] Edit lines  [_0_] Insert numbers
 [_P_]   Skip     [_N_]   Skip     [_a_] Mark all    [_A_] Insert letters
 [_M-p_] Unmark   [_M-n_] Unmark   [_s_] Search      [_q_] Quit
 [_|_] Align with input CHAR       [Click] Cursor at point"
		  ("l" mc/edit-lines :exit t)
		  ("a" mc/mark-all-like-this :exit t)
		  ("n" mc/mark-next-like-this)
		  ("N" mc/skip-to-next-like-this)
		  ("M-n" mc/unmark-next-like-this)
		  ("p" mc/mark-previous-like-this)
		  ("P" mc/skip-to-previous-like-this)
		  ("M-p" mc/unmark-previous-like-this)
		  ("|" mc/vertical-align)
		  ("s" mc/mark-all-in-region-regexp :exit t)
		  ("0" mc/insert-numbers :exit t)
		  ("A" mc/insert-letters :exit t)
		  ("<mouse-1>" mc/add-cursor-on-click)
		  ;; Help with click recognition in this hydra
		  ("<down-mouse-1>" ignore)
		  ("<drag-mouse-1>" ignore)
		  ("q" nil)))


;; ---- dashboard ----
 (use-package dashboard
  :ensure t
  :config
  (setq dashboard-banner-logo-title "Welcome to Emacs!") ;; 个性签名，随读者喜好设置
  ;; (setq dashboard-projects-backend 'projectile) ;; 读者可以暂时注释掉这一行，等安装了 projectile 后再使用
  (setq dashboard-startup-banner 'official) ;; 也可以自定义图片
  (setq dashboard-items '((recents  . 5)   ;; 显示多少个最近文件
			  (bookmarks . 5)  ;; 显示多少个最近书签
			  (projects . 10))) ;; 显示多少个最近项目
  (dashboard-setup-startup-hook))


;; ---- highlight-symbol ----
;(use-package highlight-symbol
;  :ensure t
;  :init (highlight-symbol-mode)
;  :bind ("<f3>" . highlight-symbol)) ;; 按下 F3 键就可高亮当前符号

(require 'highlight-symbol)
(global-set-key [f3] 'highlight-symbol)
(global-set-key [(control f3)] 'highlight-symbol-next)
(global-set-key [(shift f3)] 'highlight-symbol-prev)
(global-set-key [(meta f3)] 'highlight-symbol-query-replace)


;; ---- rainbow-delimiters ----
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))


;; ---- evil ----
;(use-package evil
;  :ensure t
;  :init (evil-mode))

;; ---- Other source .el function files ----
(require 'init-program)


(provide 'init)
;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("063c278e83aa631e230535f1be093fa57d0df4a2f5b7e781c6952e6145532976" "84d2f9eeb3f82d619ca4bfffe5f157282f4779732f48a5ac1484d94d5ff5b279" "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" "a27c00821ccfd5a78b01e4f35dc056706dd9ede09a8b90c6955ae6a390eb1c1e" default))
 '(package-selected-packages
   '(lsp-pyright doom-modeline dap-mode lsp-mssql lsp-ui lsp-ivy lsp-mode flycheck yasnippet-snippets yasnippet company-box company evil rainbow-delimiters highlight-symbol dashboard multiple-cursors use-package-hydra hydra marginalia which-key zweilight-theme smart-mode-line-atom-one-dark-theme zzz-to-char doom-themes dracula-theme smart-mode-line-powerline-theme smart-mode-line undo-tree mwim ace-window amx ivy)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
