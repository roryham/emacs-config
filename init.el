;;; init.el --- Emacs initialization file
;;; Commentary:
;; Load Elpaca setup first, then config.org

;;; Code:

;; Load Elpaca package manager from scripts directory
(load (expand-file-name "scripts/elpaca-setup.el" user-emacs-directory))

;; Now load config.org
(org-babel-load-file
 (expand-file-name
  "config.org"
  user-emacs-directory))

;;; init.el ends here
