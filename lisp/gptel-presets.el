;;; gptel-presets.el --- Collection of ready-made gptel presets  -*- lexical-binding: t; -*-

(require 'gptel)
(require 'cl-lib)

;; Ensure tools are loaded before presets reference them.
;; (Safe even if gptel-tools.el was already loaded.)
(let ((tools-file (expand-file-name "lisp/gptel-tools.el" user-emacs-directory)))
  (when (file-exists-p tools-file)
    (load tools-file)))

;; ------------------------------------------------------------
;; Helper: resolve tool names to tool objects safely
;;
;; NOTE: `gptel-get-tool' expects a CATEGORY-qualified path, e.g.
;; '("org" "org_search"), so a bare name lookup silently fails.  These
;; helpers search every registered category by name instead.
;; ------------------------------------------------------------
(defun my/gptel-tool (name)
  "Return the (name . tool) cons for the gptel tool called NAME.
Searches all registered categories.  Returns nil if not found."
  (cl-loop for (_cat . tools) in gptel--known-tools
           thereis (cl-find name tools
                            :key (lambda (c) (gptel-tool-name (cdr c)))
                            :test #'equal)))

(defun my/gptel-tools (&rest names)
  "Return a list of gptel tool objects for NAMES.
Missing tools are skipped, with a message naming each one."
  (delq nil
        (mapcar (lambda (n)
                  (let ((hit (my/gptel-tool n)))
                    (unless hit (message "gptel preset: tool %S not found" n))
                    (and hit (cdr hit))))
                names)))

;; ------------------------------------------------------------
;; Helper: resolve an MCP tool category to its tool names
;; ------------------------------------------------------------
(defun my/mcp-tool-names (category)
  "Return the names of all gptel tools registered under CATEGORY.
Returns nil if CATEGORY has no tools, e.g. if its MCP server
failed to start."
  (condition-case nil
      (mapcar #'gptel-tool-name (gptel-get-tool (list category)))
    (error (message "gptel preset: MCP category %S not found" category) nil)))

;; ------------------------------------------------------------
;; 0  Free-basic
;; ------------------------------------------------------------
(gptel-make-preset 'free-basic
  :description "Free fallback model for everyday queries"
  :backend     "CBorg"
  :model       'cborg-deepthought
  :temperature nil
  :max-tokens  8192
  :tools       nil    ;; explicitly no tools
  :system
  "You are a helpful assistant. Keep answers concise and avoid unnecessary detail.")

;; ------------------------------------------------------------
;; Programmer – read code, list directories, inspect buffers
;; ------------------------------------------------------------
(gptel-make-preset 'programmer
  :description "Expert programming assistant with file & buffer access"
  :backend     "CBorg"
  :model       'claude-opus-4-8
  :temperature nil
  :max-tokens  8192
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
  :model       'cborg-vision
  :temperature nil
  :max-tokens  8192
  :tools       nil
  :system
  "You are an AI with vision capabilities. Analyse any attached image and answer the user's question about it. Use Org for any textual description.")

;; ------------------------------------------------------------
;;Tool – general-purpose tool-using assistant
;; ------------------------------------------------------------
(gptel-make-preset 'tool
  :description "General tool-using assistant (filesystem + shell)"
  :backend     "CBorg"
  :model       'cborg-deepthought
  :temperature nil
  :max-tokens  8192
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
  :model       'cborg-deepthought
  :temperature nil
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
  :model       'google/grok-4.1-reasoning
  :temperature nil
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
  :model       'cborg-deepthought
  :temperature 0.2
  :max-tokens  8192
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

;; ------------------------------------------------------------
;; Travel agent
;; ------------------------------------------------------------
(gptel-make-preset 'travel-agent
  :description "AI travel agent: researches trips with real sources, remembers per-trip details, outputs an Org plan."
  :backend     "CBorg"
  :model       'cborg-deepthought
  :temperature nil
  :max-tokens  8192
  :system
  "You are an expert travel agent helping the user plan a trip end to end:
researching destinations, comparing flights, lodging, and activities, building
day-by-day itineraries, and handling logistics (weather, visas, local customs,
transit, budgeting).

SCOPE: You research and plan using real, current web information. You cannot make
bookings, take payment, or access live booking inventory. Present concrete,
sourced options and let the user book themselves. NEVER invent prices, schedules,
hours, or availability. If you cannot verify a fact, say so explicitly.

TOOLS and how to use them:
- searxng: search for current info (prices, schedules, hours, events, advisories).
  Always prefer searching over memory for anything time-sensitive.
- fetch: read the full content of authoritative pages (official tourism boards,
  transit operators, airline/hotel sites, reputable guides) when search snippets
  aren't enough. Fetch before quoting specific prices or schedules.
- project memory: this trip has its own memory. At the START of every session,
  read memory to recall the trip's parameters and decisions so far. As you learn
  preferences or make decisions, WRITE them to memory: traveler details, dates,
  budget, interests, dietary/access needs, options shortlisted, and choices made.
  Memory persists across sessions for this trip, so build on it rather than
  re-asking what you already know.

PROCESS:
1. Read project memory first. If the trip's core parameters (dates, travelers,
   origin, budget, interests) are missing, ask for them before researching.
2. Research thoroughly with real sources. Fetch pages for anything specific.
3. Present options with honest tradeoffs, not just one pick. Cite a source for
   every price, schedule, or time-sensitive claim.
4. Update memory with new info and decisions.

DELIVERABLE: When asked to summarize, or when a plan is ready, produce a complete
Org-mode document with this structure:

* Trip Overview        :: dates, travelers, budget, one-paragraph summary
* Getting There        :: flight/transit options, real prices, sources
* Accommodation        :: options, prices, location notes, sources
* Itinerary            :: day-by-day, using =** Day N - <date>= subheadings
* Activities & Dining  :: options with notes, hours, prices, sources
* Logistics            :: visa, weather, currency, transit passes, packing, tips
* Budget Estimate      :: an Org table itemizing costs with a total
* Sources              :: every URL used, as Org links

Use correct Org syntax: =*=/=**= headings, =-= lists, =| a | b |= tables, and
=[[url][label]]= links. Flag any figure that should be reconfirmed before booking
with a =(verify before booking)= note. Keep the document self-contained and
actionable."
  :tools `(,@(my/mcp-tool-names "mcp-searxng")
           ,@(my/mcp-tool-names "mcp-fetch")))

;; ------------------------------------------------------------
;; Gptel-agent.
;;
;; `:parents' supplies gptel-agent's system prompt, so none is set here.
;;
;; The tool list is spelled out in full, as plain NAMES, rather than
;; using `:append': appending resolved tool objects onto the parent's
;; name strings produces a mixed list that breaks the transient menu
;; (wrong-type-argument characterp).  The first 15 entries are
;; gptel-agent's own tools — re-check them with
;;   (mapcar #'gptel-tool-name gptel-tools)
;; in a plain `M-x gptel-agent' buffer after updating the package.
;;
;; The three MCP memory *delete* tools are deliberately omitted: an
;; autonomous loop should not be able to wipe the knowledge graph.
;; ------------------------------------------------------------
(gptel-make-preset 'agent
  :description "gptel-agent on a frontier model, with Org and MCP memory"
  :parents 'gptel-agent
  :backend "CBorg"
  :model 'claude-sonnet-high
  :tools '("Agent" "TodoWrite" "Glob" "Grep" "Read" "Insert" "Edit" "Write"
           "Mkdir" "Eval" "Bash" "WebSearch" "WebFetch" "YouTube" "Skill"
           "org_list_headings" "org_read_heading" "org_search"
           "org_insert_under_heading" "org_insert_src_block"
           "open_nodes" "search_nodes" "read_graph"
           "create_entities" "create_relations" "add_observations"))

(provide 'gptel-presets)
;;; gptel-presets.el ends here
