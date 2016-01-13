;;; init.el --- Spacemacs Initialization File
;;
;; Copyright (c) 2012-2014 Sylvain Benner
;; Copyright (c) 2014-2015 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;; Without this comment emacs25 adds (package-initialize) here
;; (package-initialize)
;; 事前にros emacsを実行しておくこと
(load "~/.roswell/impls/ALL/ALL/quicklisp/slime-helper.el")

(setq gc-cons-threshold 100000000)
(defconst spacemacs-version          "0.104.2" "Spacemacs version.")
(defconst spacemacs-emacs-min-version   "24.3" "Minimal version of Emacs.")

(defun spacemacs/emacs-version-ok ()
  (version<= spacemacs-emacs-min-version emacs-version))

(when (spacemacs/emacs-version-ok)
  (load-file (concat user-emacs-directory "core/core-load-paths.el"))
  (require 'core-spacemacs)
  (require 'core-configuration-layer)
  (spacemacs/init)
  (spacemacs/maybe-install-dotfile)
  (configuration-layer/sync)
  (spacemacs/setup-startup-hook)
  (require 'server)
  (unless (server-running-p) (server-start)))


;; add bokuweb
(let ((ws window-system))
  (cond ((eq ws 'w32)
         (set-face-attribute 'default nil
                             :family "MeiryoKe_Gothic"  ;; 英数
                             :height 100)
         (set-fontset-font nil 'japanese-jisx0208 (font-spec :family "MeiryoKe_Gothic")))  ;; 日本語
        ((eq ws 'ns)
         (set-face-attribute 'default nil
                             :family "Osaka"  ;; 英数
                             :height 140)
         (set-fontset-font nil 'japanese-jisx0208 (font-spec :family "Osaka")))))  ;; 日本語

(global-linum-mode t)
(set-face-attribute 'linum nil
                    :background "#252629"
                    :height 0.9)

(setq linum-format "%4d  ")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("11dd7fb48f2c0360f79e80a694c9e919a86dce32e5605018e9862e1e6287e3cb" default)))
 '(tab-width 4))

(fset 'yes-or-no-p 'y-or-n-p)

;; -------------------------------------------------------------------------
;; @ whitespace

(global-whitespace-mode 1)
(setq whitespace-space-regexp "\\(\u3000\\)")
(setq whitespace-style '(face tabs tab-mark spaces space-mark))
(setq whitespace-display-mappings ())
(set-face-foreground 'whitespace-tab "#F1C40F")
(set-face-background 'whitespace-space "#E74C3C")

;; -------------------------------------------------------------------------
;;
;; tabbar
;; (install-elisp "http://www.emacswiki.org/emacs/download/tabbar.el")
;; ______________________________________________________________________

(require 'tabbar)
(tabbar-mode 1)

(tabbar-mwheel-mode -1)

(setq tabbar-buffer-groups-function nil)

(dolist (btn '(tabbar-buffer-home-button
               tabbar-scroll-left-button
               tabbar-scroll-right-button))
  (set btn (cons (cons "" nil)
                 (cons "" nil))))

(setq tabbar-separator '(2.2))

(set-face-attribute
 'tabbar-default nil
 :family "MeiryoKe_Gothic"
 :background "#252629"
 :foreground "#EEEEEE"
 :height 0.95
 )

(set-face-attribute
 'tabbar-unselected nil
 :background "#252629"
 :foreground "#EEEEEE"
 :box nil
)
(set-face-attribute
 'tabbar-modified nil
 :background "#E74C3C"
 :foreground "#EEEEEE"
 :box nil
)
(set-face-attribute
 'tabbar-selected nil
 :background "#8E44AD"
 :foreground "#EEEEEE"
 :box nil)
(set-face-attribute
 'tabbar-button nil
 :box nil)
(set-face-attribute
 'tabbar-separator nil
 :height 2.0)

(defvar my-tabbar-displayed-buffers
  '("*scratch*" "*Messages*" "*Backtrace*" "*Colors*" "*Faces*" "*vc-" "*terminal*" "*shell*" "spacemacs" "*terminal<0>*" "*terminal<1>*" "*terminal<2>*" "*terminal<3>*" "*terminal<4>*")
  "*Regexps matches buffer names always included tabs.")

(defun my-tabbar-buffer-list ()
  "Return the list of buffers to show in tabs.
Exclude buffers whose name starts with a space or an asterisk.
The current buffer and buffers matches `my-tabbar-displayed-buffers'
are always included."
  (let* ((hides (list ?\  ?\*))
         (re (regexp-opt my-tabbar-displayed-buffers))
         (cur-buf (current-buffer))
         (tabs (delq nil
                     (mapcar (lambda (buf)
                               (let ((name (buffer-name buf)))
                                 (when (or (string-match re name)
                                           (not (memq (aref name 0) hides)))
                                   buf)))
                             (buffer-list)))))
    ;; Always include the current buffer.
    (if (memq cur-buf tabs)
        tabs
      (cons cur-buf tabs))))
(setq tabbar-buffer-list-function 'my-tabbar-buffer-list)


;; Ctrl-Tab, Ctrl-Shift-Tab
(dolist (func '(tabbar-mode tabbar-forward-tab tabbar-forward-group tabbar-backward-tab tabbar-backward-group))
  (autoload func "tabbar" "Tabs at the top of buffers and easy control-tab navigation"))
(defmacro defun-prefix-alt (name on-no-prefix on-prefix &optional do-always)
  `(defun ,name (arg)
     (interactive "P")
     ,do-always
     (if (equal nil arg)
         ,on-no-prefix
       ,on-prefix)))
(defun-prefix-alt shk-tabbar-next (tabbar-forward-tab) (tabbar-forward-group) (tabbar-mode 1))
(defun-prefix-alt shk-tabbar-prev (tabbar-backward-tab) (tabbar-backward-group) (tabbar-mode 1))
(global-set-key [(control tab)] 'shk-tabbar-next)
(global-set-key [(control shift tab)] 'shk-tabbar-prev)


;; backspace
(global-set-key "\C-h" 'delete-backward-char)

;; -------------------------------------------------------------------------
;; multiple-cursors
;;
;; mc/mark-next-like-this
;;
;; http://nishikawasasaki.hatenablog.com/entry/2012/12/31/094349
(require 'multiple-cursors)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-M->") 'mc/skip-to-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

;; -------------------------------------------------------------------------
;; highlight-symbol
(require 'highlight-symbol)
(setq highlight-symbol-colors '("DarkOrange" "DodgerBlue1" "DeepPink1"))


(global-set-key (kbd "C-S-h") 'highlight-symbol-at-point)
(global-set-key (kbd "C-S-M-h") 'highlight-symbol-remove-all)

;; -------------------------------------------------------------------------
;; expand region
;; http://blog.shibayu36.org/entry/2013/12/30/190354
(require 'expand-region)
(global-set-key (kbd "C-@") 'er/expand-region)
(global-set-key (kbd "C-M-@") 'er/contract-region)

(transient-mark-mode t)

;; ------------------------------------------------------------------------
;; @ redo+.el

;;; redo+
;;(require 'redo+)
;;(global-set-key (kbd "C-M-/") 'redo+)
;;(setq undo-no-redo t) ; 過去のundoがredoされないようにする
;;(setq undo-limit 600000)
;;(setq undo-strong-limit 900000)

;; http://www.emacswiki.org/emacs/redo+.el
;;(define-key global-map (kbd "C-_") 'redo))


;; -------------------------------------------------------------------------
(defadvice isearch-mode (around isearch-mode-default-string (forward &optional regexp op-fun recursive-edit word-p) activate)
  (if (and transient-mark-mode mark-active (not (eq (mark) (point))))
      (progn
        (isearch-update-ring (buffer-substring-no-properties (mark) (point)))
        (deactivate-mark)
        ad-do-it
        (if (not forward)
            (isearch-repeat-backward)
          (goto-char (mark))
          (isearch-repeat-forward)))
    ad-do-it))

;; http://ubulog.blogspot.jp/2007/06/emacs.html
(global-set-key "\C-xf" 'helm-recentf)

;; kill-ring
(global-set-key (kbd "M-y") 'helm-show-kill-ring)

;; ------------------------------------------------------------------------
;; @anzu
;;  http://blog.shibayu36.org/entry/2013/12/30/190354y

(require 'anzu)
(global-anzu-mode +1)
(setq anzu-use-migemo t)
(setq anzu-search-threshold 1000)
(setq anzu-minimum-input-length 3)

(global-set-key (kbd "C-c r") 'anzu-query-replace)
(global-set-key (kbd "C-c R") 'anzu-query-replace-regexp)

;; ------------------------------------------------------------------------
;; @ magit.el
;; http://d.hatena.ne.jp/nyaasan/20071216/p1
(require 'magit)
;;(setq magit-git-executable "C:/Program Files/Git/cmd/git.exe")
(global-set-key "\C-cm" 'magit-status)


;; git-grep
(defun chomp (str)
  (replace-regexp-in-string "[\n\r]+$" "" str))

;; git
;; http://blog.shibayu36.org/entry/2013/02/08/215719
;;
(defun git-project-p ()
  (string=
   (chomp
    (shell-command-to-string "git rev-parse --is-inside-work-tree"))
   "true"))

(defun git-root-directory ()
  (cond ((git-project-p)
         (chomp
          (shell-command-to-string "git rev-parse --show-toplevel")))
        (t
         "")))

(defun git-grep (grep-dir command-args)
  (interactive
   (let ((root (concat (git-root-directory) "/")))
     (list
      (read-file-name
       "Directory for git grep: " root root t)
      (read-shell-command
       "Run git-grep (like this): "
       (format "PAGER='' git grep -I -n -i -e %s"
               "")
       'git-grep-history))))
  (let ((grep-use-null-device nil)
        (command
         (format (concat
                  "cd %s && "
                  "%s")
                 grep-dir
                 command-args)))
    (grep command)))


;;grepから検索結果を直接編集
;; https://raw.github.com/mhayashi1120/Emacs-wgrep/master/wgrep.el
;; 使い方
;; M-x grepやrgrepで得た検索結果(grepバッファ)で編集する
;; C-c C-p
;; 編集を開始する
;; C-x C-s/C-c C-c/C-c C-e
;; 編集内容を確定
;; C-c C-k
;; 編集した内容を破棄してwgrepを終了する
;; C-x C-q
;; wgrepを終了する
(require 'wgrep nil t)

;; migemo
(when (and (executable-find "cmigemo")
           (require 'migemo nil t))
  (setq migemo-options '("-q" "--emacs"))

  (setq migemo-user-dictionary nil)
  (setq migemo-regex-dictionary nil)
  (setq migemo-coding-system 'utf-8-unix)
  (setq migemo-command "/usr/local/bin/cmigemo")
  (setq migemo-dictionary "/usr/local/share/migemo/utf-8/migemo-dict")
  (load-library "migemo")
  (migemo-init)
  )

;; -------------------------------------------------------------------------
;;  @helm-swoop

;;; この前にmigemoの設定が必要
(require 'helm-migemo)
;;; この修正が必要
(eval-after-load "helm-migemo"
  '(defun helm-compile-source--candidates-in-buffer (source)
     (helm-aif (assoc 'candidates-in-buffer source)
         (append source
                 `((candidates
                    . ,(or (cdr it)
                           (lambda ()
                             ;; Do not use `source' because other plugins
                             ;; (such as helm-migemo) may change it
                             (helm-candidates-in-buffer (helm-get-current-source)))))
                   (volatile) (match identity)))
       source)))


(require 'helm-swoop)
;;; isearchからの連携を考えるとC-r/C-sにも割り当て推奨
(define-key helm-swoop-map (kbd "C-r") 'helm-previous-line)
(define-key helm-swoop-map (kbd "C-s") 'helm-next-line)

;;; 検索結果をcycleしない、お好みで
(setq helm-swoop-move-to-line-cycle nil)

(cl-defun helm-swoop-nomigemo (&key $query ($multiline current-prefix-arg))
  "シンボル検索用Migemo無効版helm-swoop"
  (interactive)
  (let ((helm-swoop-pre-input-function
         (lambda () (format "\\_<%s\\_> " (thing-at-point 'symbol)))))
    (helm-swoop :$source (delete '(migemo) (copy-sequence (helm-c-source-swoop)))
                :$query $query :$multiline $multiline)))
;;; C-M-:に割り当て
(global-set-key (kbd "C-M-:") 'helm-swoop-nomigemo)

;;; [2014-11-25 Tue]
(when (featurep 'helm-anything)
  (defadvice helm-resume (around helm-swoop-resume activate)
    "helm-anything-resumeで復元できないのでその場合に限定して無効化"
    ad-do-it))

;;; ace-isearch
;;;(global-ace-isearch-mode 1)


;; ------------------------------------------------------------------------
;; js2-mode
;;(autoload 'js2-jsx-mode "js")
(autoload 'js2-mode "js2" nil t)
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-jsx-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . js2-jsx-mode))
(add-hook 'js-mode-hook 'js2-minor-mode)

(add-hook 'js2-mode-hook 'ac-js2-mode)
(add-hook 'js2-jsx-mode-hook 'ac-js2-mode)
(setq ac-js2-evaluate-calls t)

;; ------------------------------------------------------------------------
;; @ autocomplete.el
(require 'auto-complete)
(require 'auto-complete-config)
(global-auto-complete-mode t)
(ac-config-default)
(define-key ac-completing-map (kbd "C-n") 'ac-next)
(define-key ac-completing-map (kbd "C-p") 'ac-previous)
(define-key ac-completing-map (kbd "C-m") 'ac-complete)


;; ------------------------------------------------------------------------
;; @ company-mode.el
;;(require 'company)
;;(global-company-mode) ; 全バッファで有効にする 
;;(setq company-idle-delay 0) ; デフォルトは0.5
;;(setq company-minimum-prefix-length 2) ; デフォルトは4
;;(setq company-selection-wrap-around t) ; 候補の一番下でさらに下に行こうとすると一番上に戻る

(define-key company-active-map (kbd "C-n") 'company-select-next)
(define-key company-active-map (kbd "C-p") 'company-select-previous)

;;
;; multi term
(require 'multi-term)

(delete-selection-mode t)


(require 'sws-mode)
(require 'jade-mode)
(add-to-list 'auto-mode-alist '("\\.styl\\'" . sws-mode))


(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-attr-indent-offset nil)
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-sql-indent-offset 2)
  (setq indent-tabs-mode nil)
  (setq tab-width 2))
(add-hook 'web-mode-hook 'my-web-mode-hook)


