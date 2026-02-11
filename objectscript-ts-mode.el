;;; objectscript-treesitter-major-mode --- A major-mode for editing ObjectScript -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2024 Marc Johnson
;;
;; Author: Marc Johnson <marjohns@intersystems.com>
;; Maintainer: Marc Johnson <marjohns@intersystems.com>
;; Created: May 03, 2024
;; Modified: August 04, 2025
;; Version: 0.0.1
;; Keywords:  languages lisp tools objectscript
;; Homepage: https://github.com/intersystems/emacs-objectscript-ts-mode.git
;; Package-Requires: ((emacs "29.1"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;; This is a major-mode for editing ObjectScript on Emacs.
;;; It provides highlighting, indent rules, imenu features, and
;;; You will need to install the language parsers (more instructions in the README.md)
;;
;;  Description
;;
;;; Code:

(require 'treesit)
(require 'font-lock)
(require 'python)
(require 'java-ts-mode)

(defvar objectscript-ts-range-rules
  '(
    :embed python
    :host objectscript
    ((method_definition
      keywords: (external_method_keywords
                 (method_keyword_language
                  (identifier)
                  (rhs) @lang
                  (:equal @lang "python")))
      body: (external_method_body_content) @capture))

    :embed objectscript_core
    :host objectscript
    ((method_definition
      name: (_)
      arguments: (_)
      keywords: (_)
      body: (core_method_body_content) @capture))
    ))

(defvar objectscript-ts-font-lock-rules
  '(
    ;; === Class Definitions ===
    :language objectscript
    :feature class
    :override t
    ((class_definition
      keyword: (keyword_class) @font-lock-keyword-face
      class_name: (identifier) @font-lock-function-name-face
      class_body: (_))
     (class_definition
      keyword: (keyword_class) @font-lock-keyword-face
      class_name: (identifier) @font-lock-function-name-face
      (class_extends keyword: (keyword_extends)
                     (identifier) @font-lock-type-face)
      class_body: (_)))

    ;; === Properties, Relationships, Indexes, etc. ===
    :language objectscript
    :feature property
    :override t
    ((property
      keyword: (keyword_property) @font-lock-keyword-face
      name: (identifier (identifier) @font-lock-variable-name-face)
      (property_type (keyword_as)
                     (typename (identifier) @font-lock-type-face)))

     (relationship
      keyword: (keyword_relationship) @font-lock-keyword-face
      name: (identifier (identifier) @font-lock-variable-name-face)
      keyword: (keyword_as) @font-lock-keyword-face
      (typename (_) @font-lock-type-face)
      (relationship_keywords (_))*)

     (foreignkey
      keyword: (keyword_foreignkey) @font-lock-keyword-face
      name: (identifier (identifier) @font-lock-variable-name-face)
      (identifier (identifier) @font-lock-variable-name-face)+
      keyword: (keyword_references) @font-lock-keyword-face
      (identifier (identifier) @font-lock-variable-name-face)
      (foreignkey_keywords (_))*)

     [(foreignkey (identifier) @font-lock-variable-name-face)
      (foreignkey (foreignkey_keywords) @font-lock-keyword-face)]

     ;; [(kw_Cardinality name: (keyword_name))
     ;;  (kw_Inverse name: (keyword_name)
     ;;              rhs: (identifier) @font-lock-variable-name-face)]
     ;; @font-lock-preprocessor-face

     [(typename (identifier))
      (class_name)
      (locktype)]
     @font-lock-type-face

     ;; Index variations
     [(index keyword: (keyword_index) @font-lock-keyword-face
             name: (identifier (identifier) @font-lock-variable-name-face))
      (index keyword: (keyword_index) @font-lock-keyword-face
             name: (identifier (identifier) @font-lock-variable-name-face)
             keyword: (keyword_on) @font-lock-keyword-face
             (index_properties (_) @font-lock-variable-name-face)*)]

     ;; (parameter
     ;;  keyword: (keyword_parameter) @font-lock-keyword-face
     ;;  name: (identifier (identifier) @font-lock-variable-name-face))
    )

    ;; ;; === Methods & Classmethods ===
    ;; :language objectscript
    ;; :feature method
    ;; :override t
    ;; ([
    ;;   ;; Classmethod definitions
    ;;   (classmethod keyword: (_) @font-lock-keyword-face
    ;;    (method_definition
    ;;     name: (identifier (identifier) @font-lock-function-name-face)
    ;;     arguments: (_)))

    ;;   (classmethod keyword: (_) @font-lock-keyword-face
    ;;    (method_definition
    ;;     name: (identifier (identifier) @font-lock-function-name-face)
    ;;     arguments: (_)
    ;;     keywords: (method_keywords
    ;;                (_ name: (keyword_name)
    ;;                   @font-lock-variable-name-face))
    ;;     @font-lock-keyword-face))
    ;;   ;; Regular methods
    ;;   (method keyword: (_) @font-lock-keyword-face
    ;;    (method_definition
    ;;     name: (identifier (identifier) @font-lock-function-name-face)
    ;;     arguments: (_)))

    ;;   (method keyword: (_) @font-lock-keyword-face
    ;;    (method_definition
    ;;     name: (identifier (identifier) @font-lock-function-name-face)
    ;;     arguments: (_)
    ;;     keywords: (method_keywords
    ;;                (_ name: (keyword_name)
    ;;                   @font-lock-variable-name-face))
    ;;     @font-lock-keyword-face))
    ;;   (method_definition name: (identifier) @font-lock-function-name-face)
    ;;  ]
    ;;  ;; (instance_method_call (method_name) @font-lock-function-call-face)
    ;;  ;; [(method_name)
    ;;  ;;  (user_defined_function)
    ;;  ;;  (routine_method_call)
    ;;  ;;  (tag)
    ;;  ;;  (goto_label)
    ;;  ;;  (goto_routine)] @font-lock-function-name-face
    ;;   )

    :language objectscript
    :feature argument
    :override t
    ([(argument (identifier) @font-lock-variable-name-face
                (argument_type keyword: (keyword_as) @font-lock-keyword-face
                                (typename (_) @font-lock-type-face)))
      (argument keyword: (keyword_byref) @font-lock-keyword-face (identifier) @font-lock-variable-name-face
                (argument_type keyword: (keyword_as) @font-lock-keyword-face
                                (typename (_) @font-lock-type-face)))
      (argument (identifier) @font-lock-variable-name-face)
      (argument keyword: (keyword_byref) @font-lock-keyword-face (identifier) @font-lock-variable-name-face)])

    ;; === Keywords ===
    :language objectscript
    :feature keyword
    :override t
    ([(keyword_class)
      (keyword_index)
      (keyword_relationship)
      (keyword_foreignkey)
      (keyword_references)
      (keyword_classmethod)
      (keyword_property)
      (keyword_parameter)
      (keyword_method)
      (keyword_query)
      (keyword_xdata)
      (keyword_include)
      (keyword_byref)
      (keyword_includegenerator)
      (keyword_trigger)
      (keyword_as)
      (keyword_catch)
      (keyword_try)
      (keyword_of)
      (keyword_merge)
      (keyword_pound_pound_class)
      (keyword_extends)]
     @font-lock-keyword-face
     [(keyword_set)
      (keyword_write)
      (keyword_read)
      (keyword_do)
      (keyword_while)
      (keyword_kill)
      (keyword_open)
      (keyword_if)
      (keyword_else)
      (keyword_elseif)
      (keyword_oldelse)
      (keyword_tstart)
      (keyword_for)
      (keyword_pound_define)
      (keyword_return)
      (keyword_quit)
      (keyword_new)
      (keyword_throw)
      (keyword_break)
      (keyword_tcommit)]
     @font-lock-keyword-face
        [(keyword_array)] @font-lock-type-face)

    ;; === Variables ===
    :language objectscript
    :feature variable
    ([(glvn (gvn))
      (lvn)
      (property_name (identifier_segment_immediate) @font-lock-variable-name-face)
      (method_arg)
      ;; (instance_property (property_name))
      ]
     @font-lock-variable-name-face)



    ;; === Variables 2 ===
    :language objectscript
    :feature variable
     ([(pound_define macro_name: (pound_define_variable_name)
                    @font-lock-function-name-face)
      (pound_define_variable_args macro_arg: (macro_arg)
                                  @font-lock-variable-name-face)])

    ;; ;; === System-defined things ===
    ;; :language objectscript
    ;; :feature system_defined
    ;; ([(routine_method_call)
    ;;   (system_defined_function)
    ;;   (system_defined_variable)
    ;;   (macro_function (_))
    ;;   (macro_constant)]
    ;;  @font-lock-preprocessor-face)

    ;; === Comments & Documentation ===
    :language objectscript
    :feature comment
    :override t
    ([(line_comment_1)
      (line_comment_2)
      (line_comment_3)
      (block_comment)]
     @font-lock-comment-face
     (documatic_line) @font-lock-doc-face)

    ;; === Strings ===
    :language objectscript
    :feature literal
    :override t
    ([(string_literal)
      (_read_prompt)]
     @font-lock-string-face)

    ;; === Numbers ===
    :language objectscript
    :feature literal
    :override t
    ([(numeric_literal)]
     @font-lock-number-face)

    ;; === Brackets & Delimiters ===
    :language objectscript
    :feature bracket
    :override t
    (["[" "]" "(" ")" "{" "}"] @font-lock-delimiter-face)
  ))


(defun objectscript-ts-imenu-property (node)
  "Imenu boolean function for property using NODE."
  (equal (treesit-node-type node) "property"))

(defun objectscript-ts-imenu-parameter (node)
  (equal (treesit-node-type node) "parameter"))

(defun objectscript-ts-imenu-property-name-function (node)
    "Naming the imenu property nodes using NODE."
  (let ((name (treesit-node-text node)))
    (if (objectscript-ts-imenu-property node)
        name
    name)))

(defun objectscript-ts-imenu-method (node)
  "Imenu boolean function for methods using NODE."
  (or (equal (treesit-node-type node) "classmethod")
      (equal (treesit-node-type node) "method")))

(defun objectscript-ts-imenu-method-name-function (node)
    "Naming the imenu method nodes using NODE."
    (let* ((method_definition (treesit-node-child node 1))
           (class_keyword (treesit-node-child node 0))
           (identifier (treesit-node-child method_definition 0))
           (name (treesit-node-text identifier)))
      (concat (treesit-node-text class_keyword) " " name)))


(defun objectscript-ts-imenu-parameter-name-function (node)
  (treesit-node-text node))

(defun objectscript_core-ts-imenu-variable (node)
  (equal (treesit-node-type node) "command_set"))

(defun objectscript_core-ts-imenu-variable-name-function (node)
  (treesit-node-text (treesit-node-child (treesit-node-child node 1) 0)))

(defun objectscript-ts-setup ()
  "Setup treesit for objectscript-ts-mode."

 (setq-local treesit-font-lock-feature-list
              '((comment delimiter bracket definition)
                (class method constant system_defined function
                 variable literal keyword property argument)
                ))

 (setq-local treesit-range-settings
             (apply #'treesit-range-rules
                     objectscript-ts-range-rules))

 (setq-local treesit-font-lock-settings
             (append python--treesit-settings
                     ;;js--treesit-font-lock-settings
                     java-ts-mode--font-lock-settings
                     (apply #'treesit-font-lock-rules objectscript-ts-font-lock-rules)))

 (setq-local treesit-font-lock-level 4)

 (setq-local treesit--indent-verbose t)


 (defvar objectscript-ts-indent-rules
  '((objectscript
     ;; --- Class Definition ---
     ((parent-is "class_body") parent-bol 4)
     ((match "class_statement") parent-bol 4)


     ((parent-is "command_if") parent-bol 4)
     ((parent-is "command_for") parent-bol 4)
     ((parent-is "command_while") parent-bol 4)
     ((parent-is "elseif_block") parent-bol 4)
     ((parent-is "else_block") parent-bol 4)

             ;; --- Old-style FOR / IF / ELSE ---
     ((parent-is "command_for") parent-bol 4)
     ((parent-is "command_if") parent-bol 4)
     ((parent-is "command_else") parent-bol 4)

     ((n-p-gp "core_method_body_content" "method_definition" nil) parent-bol 4)
     ((parent-is "core_method_body_content") parent-bol 0)


     ;; --- Command arguments that may wrap across lines ---
     ((node-is "write_argument") (nth-sibling 1) 0)
     ((node-is "set_argument") (nth-sibling 1) 4)
     ((node-is "do_parameter") (nth-sibling 1) 4)
     ((node-is "kill_argument") (nth-sibling 1) 4)
     ((node-is "command_lock_argument") (nth-sibling 1) 4)
     ((node-is "read_argument") (nth-sibling 1) 4)
     ((node-is "open_parameter") (nth-sibling 1) 4)
     ((node-is "close_parameter") (nth-sibling 1) 4)
     ((node-is "use_parameter") (nth-sibling 1) 4)

     ;; --- Generic fallback for braces/parentheses spanning multiple lines ---
     ((match "{" "}") parent-bol 4)
     ((match "(" ")") parent-bol 4))

    ;; For embedded core ObjectScript code blocks
    (objectscript_core

)))

 (setq-local indent-line-function #'treesit-simple-indent-line)
 (setq-local treesit-simple-indent-rules objectscript-ts-indent-rules)

  (setq-local treesit-simple-imenu-settings
              '(("Properties" objectscript-ts-imenu-property nil objectscript-ts-imenu-property-name-function)
                ("Methods" objectscript-ts-imenu-method nil objectscript-ts-imenu-method-name-function)
                ("Parameters" objectscript-ts-imenu-parameter nil objectscript-ts-imenu-parameter-name-function)
                ("Local Variables" objectscript_core-ts-imenu-variable nil objectscript_core-ts-imenu-variable-name-function)))
  (treesit-major-mode-setup))

(define-derived-mode objectscript-ts-mode prog-mode "objectscript"
  "Major mode for editing 'Objectscript, powered by tree-sitter."
  (when (and (treesit-ready-p 'objectscript)
             (treesit-ready-p 'objectscript_core)
             (treesit-ready-p 'python)
      ;;       (treesit-ready-p 'javascript)
             (treesit-ready-p 'java))
    ;;(treesit-parser-create 'javascript)
    (treesit-parser-create 'objectscript_core)
    (treesit-parser-create 'java)
    (treesit-parser-create 'python)
    (treesit-parser-create 'objectscript)
    (objectscript-ts-setup)))

(if (treesit-ready-p 'objectscript)
    (add-to-list 'auto-mode-alist '("\\.cls\\'" . objectscript-ts-mode)))
(provide 'objectscript-ts-mode)
;;; objectscript-treesitter-major-mode ends here
