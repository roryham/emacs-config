;;; -*- Emacs-Lisp -*- ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; BSV stands for Bluespec SystemVerilog.
;; This mode provides syntax highlighting, keyword recognition, and
;; automatic indentation for writing hardware descriptions in Emacs.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(if (< emacs-major-version 23)
    (require 'bsv-mode-22)
    (require 'bsv-mode-23))

(provide 'bsv-mode)

