; no backup files
(setq make-backup-files nil)

;M-<up> (scroll-up-command)
;M-<down> (scroll-down-command)
;(global-set-key (kbd "C-up") 'scroll-up-command)
;(global-set-key (kbd "C-down") 'scroll-down-command)

; Add cmake listfile names to the mode list.
(setq auto-mode-alist
        (append
	    '(("CMakeLists\\.txt\\'" . cmake-mode))
	       '(("\\.cmake\\'" . cmake-mode))
	          auto-mode-alist))

(autoload 'cmake-mode "~/.custom/cmake-mode.el" t)