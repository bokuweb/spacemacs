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
;; Windowsで英数と日本語にMeiryoを指定
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

;; タブ幅
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("11dd7fb48f2c0360f79e80a694c9e919a86dce32e5605018e9862e1e6287e3cb" default)))
 '(tab-width 4))

;; yes or noをy or n
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

;; タブ上でマウスホイール操作無効
(tabbar-mwheel-mode -1)

 ;; グループ化しない
(setq tabbar-buffer-groups-function nil)

;; 左に表示されるボタンを無効化
(dolist (btn '(tabbar-buffer-home-button
               tabbar-scroll-left-button
               tabbar-scroll-right-button))
  (set btn (cons (cons "" nil)
                 (cons "" nil))))

;; タブの長さ
(setq tabbar-separator '(2.2))

;; 外観変更
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

;; タブに表示させるバッファの設定
(defvar my-tabbar-displayed-buffers
  '("*scratch*" "*Messages*" "*Backtrace*" "*Colors*" "*Faces*" "*vc-" "*terminal*" "*shell*" "spacemacs")
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


;; Ctrl-Tab, Ctrl-Shift-Tab でタブを切り替える
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
;; リージョンが存在しない場合は、現在のカーソル位置の丁度上下に新たなカーソルを追加します。
;; 文字列の置き換えをしないのであれば、リージョン選択せずにカーソルを増やして一括編集が可能です。
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
(setq highlight-symbol-colors '("DarkOrange" "DodgerBlue1" "DeepPink1")) ;; 使いたい色を設定、repeatしてくれる

;; 適宜keybindの設定
(global-set-key (kbd "C-S-h") 'highlight-symbol-at-point)
(global-set-key (kbd "C-S-M-h") 'highlight-symbol-remove-all)

;; -------------------------------------------------------------------------
;; expand region
;; http://blog.shibayu36.org/entry/2013/12/30/190354
(require 'expand-region)
(global-set-key (kbd "C-@") 'er/expand-region)
(global-set-key (kbd "C-M-@") 'er/contract-region) ;; リージョンを狭める

;; transient-mark-modeが nilでは動作しませんので注意
(transient-mark-mode t)

;; ------------------------------------------------------------------------
;; @ redo+.el

;; redoできるようにする
;; http://www.emacswiki.org/emacs/redo+.el
(when (require 'redo+ nil t)
  (define-key global-map (kbd "C-_") 'redo))


;; -------------------------------------------------------------------------
;;; 選択範囲をisearch
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

;;最近開いたファイルからファイルを開く
;; http://ubulog.blogspot.jp/2007/06/emacs.html
(global-set-key "\C-xf" 'helm-recentf) ;;履歴一覧を開く。

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



