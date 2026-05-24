;;; gptel-presets.el --- Collection of ready-made gptel presets  -*- lexical-binding: t; -*-

(require 'gptel)

;; Ensure tools are loaded before presets reference them.
;; (Safe even if gptel-tools.el was already loaded.)
(let ((tools-file (expand-file-name "lisp/gptel-tools.el" user-emacs-directory)))
  (when (file-exists-p tools-file)
    (load tools-file)))

;; ------------------------------------------------------------
;; Helper: resolve tool names to tool objects safely
;; ------------------------------------------------------------
(defun my/gptel-tools (&rest names)
  "Return a list of gptel tool objects for NAMES, skipping missing ones."
  (delq nil
        (mapcar (lambda (n)
                  (condition-case nil
                      (gptel-get-tool n)
                    (error (message "gptel preset: tool %S not found" n) nil)))
                names)))

;; ------------------------------------------------------------
;; 0  Free-basic
;; ------------------------------------------------------------
(gptel-make-preset 'free-basic
  :description "Cheap fallback model for everyday queries"
  :backend     "CBorg"
  :model       'gpt-oss-120b-high
  :temperature 0.2
  :max-tokens  4096
  :tools       nil    ;; explicitly no tools
  :system
  "You are a helpful assistant. Keep answers concise and avoid unnecessary detail.")

;; ------------------------------------------------------------
;; Programmer – read code, list directories, inspect buffers
;; ------------------------------------------------------------
(gptel-make-preset 'programmer
  :description "Expert programming assistant with file & buffer access"
  :backend     "CBorg"
  :model       'claude-opus-4-7
  :max-tokens  8000
  :tools       (my/gptel-tools "read_file"
                               "list_directory"
                               "current_buffer"
                               "list_buffers"
			       "org_current_subtree"
			       "org_insert_src_block")
  :system
  "You are an expert Emacs-Lisp and general-purpose programmer.
Write correct, runnable code, add brief comments, and suggest native Emacs tools when appropriate.
When the user is in an Org buffer, you may use org_current_subtree to read context
and org_insert_src_block to add code under a heading.")

;; ------------------------------------------------------------
;; Vision
;; ------------------------------------------------------------
(gptel-make-preset 'vision
  :description "Image-capable assistant"
  :backend     "CBorg"
  :model       'claude-opus-4-7
  :max-tokens  4000
  :tools       nil
  :system
  "You are an AI with vision capabilities. Analyse any attached image and answer the user's question about it. Use Org for any textual description.")

;; ------------------------------------------------------------
;;Tool – general-purpose tool-using assistant
;; ------------------------------------------------------------
(gptel-make-preset 'tool
  :description "General tool-using assistant (filesystem + shell)"
  :backend     "CBorg"
  :model       'claude-opus-4-7
  :max-tokens  2500
  :tools       (my/gptel-tools "read_file"
                               "list_directory"
                               "list_buffers"
                               "run_shell_command")
  :system
  "You are a capable assistant with access to tools for reading files,
listing directories and buffers, and running shell commands.
Call tools when they will produce a more accurate or grounded answer.
Prefer reading actual files over guessing. Be concise.")

;; ------------------------------------------------------------
;; Explainer
;; ------------------------------------------------------------
(gptel-make-preset 'explainer
  :description "Step-by-step teacher"
  :backend     "CBorg"
  :model       'claude-sonnet-high
  :max-tokens  3000
  :tools       nil
  :system
  "You are a friendly explainer. Break every answer into numbered steps,
use analogies where helpful, keep jargon minimal, and provide concise code examples when relevant. Output in Org where appropriate.")

;; ------------------------------------------------------------
;; Large-context
;; ------------------------------------------------------------
(gptel-make-preset 'large-context
  :description "Huge-context summariser"
  :backend     "CBorg"
  :model       'gemini-3.1-pro
  :temperature 0.2
  :max-tokens  8192
  :tools       (my/gptel-tools "read_file" "list_directory")
  :system
  "You are an AI with a very large context window. Summarise, reference,
and manipulate long documents faithfully. Keep replies within the token budget.
Use the read_file tool when the user references a file path you haven't seen yet.")

;; ------------------------------------------------------------
;; Org-note assistant
;; ------------------------------------------------------------
(gptel-make-preset 'org-notes
  :description "Assistant for navigating and editing Org notes"
  :backend     "CBorg"
  :model       'claude-sonnet-high
  :max-tokens  6000
  :tools       (my/gptel-tools "org_list_headings"
                               "org_read_heading"
                               "org_current_subtree"
                               "org_insert_under_heading"
                               "org_insert_src_block"
                               "org_search"
                               "read_file"
                               "list_directory")
  :system
  "You are a careful assistant working with the user's Org-mode notes.
Use org_search and org_list_headings to discover relevant content before answering.
Use org_read_heading to fetch specific sections.
When asked to add notes, use org_insert_under_heading or org_insert_src_block — do not invent file paths or headings; verify they exist first.
Preserve the user's existing Org structure and style.")



(provide 'gptel-presets)
;;; gptel-presets.el ends here
