;;; init.el --- Emacs initialization file -*- lexical-binding: t; -*-

(message "STEP 1: init.el loading")
(load (expand-file-name "scripts/elpaca-setup.el" user-emacs-directory))
(message "STEP 2: elpaca loaded")
(org-babel-load-file
 (expand-file-name "config.org" user-emacs-directory))
(message "STEP 3: config.org loaded")

;;; init.el ends here
