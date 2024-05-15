;;; init_program.el --- Load the full configuration -*- lexical-binding: t -*-
;;; Commentary:

;; This file bootstraps the configuration, which is divided into
;; a number of other files.

;;; Code:

;; ---- Auto completion ----
(use-package company
  :ensure t
  :init (global-company-mode)
  :hook (after-init . global-company-mode)
  :config
  (setq company-minimum-prefix-length 1) ; 只需敲 1 个字母就开始进行自动补全
  (setq company-tooltip-align-annotations t)
  (setq company-idle-delay 0.0) ; Trigger completion immediately.
  (setq company-show-numbers t) ; 给选项编号 (按快捷键 M-1、M-2 等等来进行选择).
  (setq company-selection-wrap-around t)
  (setq company-transformers '(company-sort-by-occurrence))) ; 根据选择的频率进行排序，读者如果不喜欢可以去掉

;; ---- flycheck ----
(use-package flycheck
  :ensure t
  :config
  (setq truncate-lines nil) ; 如果单行信息很长会自动换行
  :hook
  (prog-mode . flycheck-mode))


;; ---- lsp-pyright ----
(use-package lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp-deferred))))  ; or lsp-deferred

;; ---- lsp-mode ----
(use-package lsp-mode
  :ensure t
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l"
	lsp-file-watch-threshold 500)
  :hook 
  (lsp-mode . lsp-enable-which-key-integration) ; which-key integration
  :commands (lsp lsp-deferred)
  :config
  (setq lsp-completion-provider :none) ;; 阻止 lsp 重新设置 company-backend 而覆盖我们 yasnippet 的设置
  (setq lsp-headerline-breadcrumb-enable t)
  :bind
  ("C-c l s" . lsp-ivy-workspace-symbol)) ;; 可快速搜索工作区内的符号（类名、函数名、变量名等）


; lsp-ui
(use-package lsp-ui
  :ensure t
  :config
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)
  (setq lsp-ui-doc-position 'top)) ;; 使用M-.来寻找符号的定义，用M-?来寻找符号的引用

; lsp 与 ivy协作 这样可以通过命令lsp-ivy-workspace-symbol来搜寻当前工作区的符号
(use-package lsp-ivy
  :ensure t
  :after (lsp-mode))


;; ---- Debug Adapter Protocol ----
(use-package dap-mode
  :ensure t
  :after hydra lsp-mode
  :commands dap-debug
  :custom
  (dap-auto-configure-mode t)
  :config
  (dap-ui-mode 1)
  :hydra
  (hydra-dap-mode
   (:color pink :hint nil :foreign-keys run)
   "
^Stepping^          ^Switch^                 ^Breakpoints^         ^Debug^                     ^Eval
^^^^^^^^----------------------------------------------------------------------------------------------------------------
_n_: Next           _ss_: Session            _bb_: Toggle          _dd_: Debug                 _ee_: Eval
_i_: Step in        _st_: Thread             _bd_: Delete          _dr_: Debug recent          _er_: Eval region
_o_: Step out       _sf_: Stack frame        _ba_: Add             _dl_: Debug last            _es_: Eval thing at point
_c_: Continue       _su_: Up stack frame     _bc_: Set condition   _de_: Edit debug template   _ea_: Add expression.
_r_: Restart frame  _sd_: Down stack frame   _bh_: Set hit count   _ds_: Debug restart
_Q_: Disconnect     _sl_: List locals        _bl_: Set log message
                  _sb_: List breakpoints
                  _sS_: List sessions
"
   ("n" dap-next)
   ("i" dap-step-in)
   ("o" dap-step-out)
   ("c" dap-continue)
   ("r" dap-restart-frame)
   ("ss" dap-switch-session)
   ("st" dap-switch-thread)
   ("sf" dap-switch-stack-frame)
   ("su" dap-up-stack-frame)
   ("sd" dap-down-stack-frame)
   ("sl" dap-ui-locals)
   ("sb" dap-ui-breakpoints)
   ("sS" dap-ui-sessions)
   ("bb" dap-breakpoint-toggle)
   ("ba" dap-breakpoint-add)
   ("bd" dap-breakpoint-delete)
   ("bc" dap-breakpoint-condition)
   ("bh" dap-breakpoint-hit-condition)
   ("bl" dap-breakpoint-log-message)
   ("dd" dap-debug)
   ("dr" dap-debug-recent)
   ("ds" dap-debug-restart)
   ("dl" dap-debug-last)
   ("de" dap-debug-edit-template)
   ("ee" dap-eval)
   ("ea" dap-ui-expressions-add)
   ("er" dap-eval-region)
   ("es" dap-eval-thing-at-point)
   ("q" nil "quit" :color blue)
   ("Q" dap-disconnect :color red)))


;; ---- Projectile ----
;; 项目管理
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


;; ---- 语言相关配置 ----
(use-package python
  :defer t
  :mode ("\\.py\\'" . python-mode)
  :interpreter ("python3" . python-mode)
  :config
  ;; for debug
  (require 'dap-python))

(use-package pyvenv
  :ensure t
  :config
  ;(setenv "WORKON_HOME" (expand-file-name "~/miniconda3/envs")) ;;把~/miniconda3换成自己的路径
  ;; (setq python-shell-interpreter "python3")  ; （可选）更改解释器名字
  (pyvenv-mode t)
  ;; （可选）如果希望启动后激活 miniconda 的 base 环境，就使用如下的 hook
  ;; :hook
  ;; (python-mode . (lambda () (pyvenv-workon "..")))
)



(provide 'init-program)


;;; init-program.el ends here
