;;; gptel-presets.el --- Collection of ready‑made gptel presets  -*- lexical-binding: t; -*-

;; Author:  Your Name <you@example.com>
;; Version: 0.2
;; Package-Requires: ((gptel "0.9.0"))
;; Keywords: convenience, AI

;;; Commentary:

;; Collection of `gptel-make-preset' definitions covering basic,
;; programming, vision, tool‑using, explainer and large‑context
;; scenarios.  Load this file after gptel is initialised.

;;; Code:

(require 'gptel)

;; ------------------------------------------------------------
;; 0  Free‑basic – cheap / fallback model
;; ------------------------------------------------------------
(gptel-make-preset 'free-basic
  :description "Cheap fallback model for everyday queries"
  :backend     "CBorg"
  :model       'gpt-oss-120b-high
  :temperature 0.2
  :max-tokens  4096
  :system
  "You are a helpful assistant. Keep answers concise and avoid unnecessary detail.")

;; ------------------------------------------------------------
;; 1  Programmer – best for code generation & reasoning
;; ------------------------------------------------------------
(gptel-make-preset 'programmer
  :description "Expert programming assistant"
  :backend     "CBorg"
  :model       'claude-opus-4-7
  :max-tokens  8000
  :system
  "You are an expert Emacs-Lisp and general-purpose programmer.
Write correct, runnable code, add brief comments, and suggest native Emacs tools when appropriate.")

;; ------------------------------------------------------------
;; 2  Vision – model that can process images
;; ------------------------------------------------------------
(gptel-make-preset 'vision
  :description "Image-capable assistant"
  :backend     "CBorg"
  :model       'claude-opus-4-7
  :max-tokens  4000
  :system
  "You are an AI with vision capabilities. Analyse any attached image and answer the user's question about it. Use Org for any textual description.")

;; ------------------------------------------------------------
;; 3  Tool‑using – best for function‑calling / tool integration
;; ------------------------------------------------------------
(gptel-make-preset 'tool
  :description "Tool/function-calling assistant"
  :backend     "CBorg"
  :model       'claude-opus-4-7
  :max-tokens  2500
  :system
  "You are a tool-using AI. When a request can be satisfied by a function call (calculator, web-search, file read, …) generate the appropriate tool-call JSON instead of a plain answer. If no tool is needed, answer concisely.")

;; ------------------------------------------------------------
;; 4  Explainer – clear, step‑by‑step teaching style
;; ------------------------------------------------------------
(gptel-make-preset 'explainer
  :description "Step-by-step teacher"
  :backend     "CBorg"
  :model       'claude-sonnet-high
  :max-tokens  3000
  :system
  "You are a friendly explainer. Break every answer into numbered steps,
use analogies where helpful, keep jargon minimal, and provide concise code examples when relevant. Output in Org where appropriate.")

;; ------------------------------------------------------------
;; 5  Large‑context – when you need the biggest window
;; ------------------------------------------------------------
(gptel-make-preset 'large-context
  :description "Huge-context summariser"
  :backend     "CBorg"
  :model       'gemini-3.1-pro
  :temperature 0.2
  :max-tokens  8192
  :system
  "You are an AI with a very large context window. Summarise, reference,
and manipulate long documents faithfully. Keep replies within the token budget.")

(provide 'gptel-presets)

;;; gptel-presets.el ends here
