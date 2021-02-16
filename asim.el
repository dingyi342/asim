;;; asim.el -*- lexical-binding: t; -*-

;;; Commentary:

;;

;;; Code:

;; (setq default-input-method nil)
;; C-x Ret C-\ 选定的输入法
;;; 光标类型
(setq asim-cnim-cursor-color "#ff1493")
(setq asim-enim-cursor-color "#adff2f")
(setq asim-enim-only-cursor-color "#0087ff")
(setq asim-cnim-cursor-type '(hbar . 5))
(setq asim-enim-cursor-type '(hbar . 5))
(setq asim-enim-only-cursor-type '(hbar . 5))

(defun asim-set-cnim-cursor ()
  (set-cursor-color asim-cnim-cursor-color)
  (setq cursor-type asim-cnim-cursor-type))

(defun asim-set-enim-cursor ()
  (set-cursor-color asim-enim-cursor-color)
  (setq cursor-type asim-enim-cursor-type))

(defun asim-set-enim-only-cursor ()
  (set-cursor-color asim-enim-only-cursor-color)
  (setq cursor-type asim-enim-only-cursor-type))

;;; 切换输入法
;; (setq asim-cnim default-input-method)
(require 'flypy-cn)
(setq default-input-method "chinese-flypy")
(setq asim-cnim "chinese-flypy")
(setq asim-enim nil)


(defun asim-enim-p ()
  (string= current-input-method asim-enim))

(defun asim-cnim-p ()
  (string= current-input-method asim-cnim))

(defun asim-set-cnim ()
  (set-input-method asim-cnim)
  (asim-set-cnim-cursor))

(defun asim-set-enim ()
  (set-input-method asim-enim)
  (asim-set-enim-cursor))

(defun asim-toggle-im ()
  ;;(toggle-input-method)
  (if (asim-enim-p) (asim-set-cnim) (asim-set-enim)))

;;; 获取字符
(defun asim-string-match-p (regexp string &optional start)
  "与 `string-match-p' 类似，如果 REGEXP 和 STRING 是非字符串时，
不会报错。"
  (and (stringp regexp)
       (stringp string)
       (string-match-p regexp string start)))

(defun asim-char-before-to-string (num)
  "得到光标前第 `num' 个字符，并将其转换为字符串。"
  (let* ((point (point))
         (point-before (- point num)))
    (when (and (> point-before 0)
               (char-before point-before))
      (char-to-string (char-before point-before)))))

(defun asim-char-after-to-string (num)
  "得到光标后第 `num' 个字符，并将其转换为字符串。"
  (let* ((point (point))
         (point-after (+ point num)))
    (when (char-after point-after)
      (char-to-string (char-after point-after)))))

(defun asim-char-before-is-cn-p (num)
  (asim-string-match-p "\\cc" (asim-char-before-to-string num)))

(defun asim-char-before-is-en-p (num)
  (asim-string-match-p "[a-zA-Z]" (asim-char-before-to-string num)))

(defun asim-char-before-is-space-p (num)
  (asim-string-match-p " " (asim-char-before-to-string num)))

(defun asim-char-before-is-return-p (num)
  (asim-string-match-p "\n" (asim-char-before-to-string num)))

(defun asim-probe-program-mode ()
  (interactive)
  (when (derived-mode-p 'prog-mode)
    (let* ((pos (point))
           (ppss (syntax-ppss pos)))
      (not
       (or (car (setq ppss (nthcdr 3 ppss)))
           (car (setq ppss (cdr ppss)))
           (nth 3 ppss))))))

(defun asim-char-before-is-punc-p (num)
  (asim-string-match-p
   "[]!@#$%^&*(){}-=+\|`~<>,.;:\'\"?/[]"
   (asim-char-before-to-string num))
  ;; (pyim-string-match-p
  ;; "[]!@#$%^&*(){}-=+\|`~<>,.;:\'\"?/[]"
  ;; (pyim-char-before-to-string 1))
  )

;;; 自动切换
(defun asim-auto-switch-im ()
  (cond
   ((asim-char-before-is-cn-p 0) (asim-set-enim))
   ((asim-char-before-is-en-p 0) (asim-set-cnim))
   (t (asim-toggle-im)))) 

;;; space
;;;###autoload
(defun asim-auto-switch-im-with-space ()
  (interactive)
  (cond
   ((asim-probe-program-mode) (asim-set-enim) (insert " "))
   ((org-in-src-block-p) (asim-set-enim) (insert " "))
   ((asim-char-before-is-cn-p 0) (asim-set-enim) (insert " "))
   ((asim-char-before-is-en-p 0) (asim-set-cnim) (insert " "))
   ((asim-char-before-is-space-p 0) (asim-toggle-im))
   ((asim-char-before-is-return-p 0) (asim-toggle-im))
   (t (asim-toggle-im) (insert " ")))) 

(define-minor-mode asim-minor-mode ()
  :lighter " asim"
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "SPC") 'asim-auto-switch-im-with-space)
            map))

(defun asim-enable ()
  (asim-minor-mode 1)
  (add-hook 'prog-mode-hook #'asim-minor-mode)
  (add-hook 'text-mode-hook #'asim-minor-mode))

(defun asim-disable ()
  (asim-minor-mode -1)
  (remove-hook 'prog-mode-hook #'asim-minor-mode)
  (remove-hook 'text-mode-hook #'asim-minor-mode))

(define-minor-mode asim-mode ()
  "asim"
  :init-value nil
  :global t
  (if asim-mode
      (asim-enable)
    (asim-disable)))

;;; asim.el ends here.
(provide 'asim)
