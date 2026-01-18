;;; init.el --- Emacs initialization file
;;; Commentary:
;; Load configuration from config.org

;;; Code:
(org-babel-load-file
 (expand-file-name
  "config.org"
  user-emacs-directory))

;;; init.el ends here
INITEL

echo "✓ Created init.el"
