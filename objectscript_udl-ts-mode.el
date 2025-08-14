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

(defvar objectscript_udl-ts-range-rules
  '(
    :embed python
    :host objectscript_udl
    ((method_definition
      name: (_)
      arguments: (_)
      keywords: (method_keywords
                         (kw_External_Language name: (keyword_name) rhs: "python"))

      body: (external_method_body_content) @capture))

    :embed java
    :host objectscript_udl
    ((method_definition
      name: (_)
      arguments: (_)
      keywords: (method_keywords
                 (kw_External_Language name: (keyword_name) rhs: "java"))

      body: (external_method_body_content) @capture))

    :embed objectscript_core
    :host objectscript_udl
    ((method_definition
      name: (_)
      arguments: (_)
      keywords: (_)
      body: (core_method_body_content) @capture))
    ))

(defvar objectscript_udl-ts-font-lock-rules
  '(
    ;; === Class Definitions ===
    :language objectscript_udl
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
    :language objectscript_udl
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
      (typename (_))
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

     [(kw_Cardinality name: (keyword_name))
      (kw_Inverse name: (keyword_name)
                  rhs: (identifier) @font-lock-variable-name-face)]
     @font-lock-preprocessor-face

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


     (parameter
      keyword: (keyword_parameter) @font-lock-keyword-face
      name: (identifier (identifier) @font-lock-variable-name-face))
    )

    ;; === Methods & Classmethods ===
    :language objectscript_udl
    :feature method
    :override t
    ([
      ;; Classmethod definitions
      (classmethod keyword: (_) @font-lock-keyword-face
       (method_definition
        name: (identifier (identifier) @font-lock-function-name-face)
        arguments: (_)))

      (classmethod keyword: (_) @font-lock-keyword-face
       (method_definition
        name: (identifier (identifier) @font-lock-function-name-face)
        arguments: (_)
        keywords: (method_keywords
                   (_ name: (keyword_name)
                      @font-lock-variable-name-face))
        @font-lock-keyword-face))
      ;; Regular methods
      (method keyword: (_) @font-lock-keyword-face
       (method_definition
        name: (identifier (identifier) @font-lock-function-name-face)
        arguments: (_)))

      (method keyword: (_) @font-lock-keyword-face
       (method_definition
        name: (identifier (identifier) @font-lock-function-name-face)
        arguments: (_)
        keywords: (method_keywords
                   (_ name: (keyword_name)
                      @font-lock-variable-name-face))
        @font-lock-keyword-face))
      (method_definition name: (identifier) @font-lock-function-name-face)
     ]
     (instance_method_call (method_name) @font-lock-function-call-face)
     [(method_name)
      (user_defined_function)
      (routine_method_call)
      (tag)
      (goto_label)
      (goto_routine)] @font-lock-function-name-face

    ;; === Arguments ===
    :language objectscript_udl
    :feature argument
    ([(argument (identifier) @font-lock-variable-name-face keyword: (keyword_as)
                (typename (identifier) @font-lock-type-face))
      (argument (identifier) @font-lock-variable-name-face)])

    ;; === Keywords ===
    :language objectscript_udl
    :feature keyword
    :override t
    ([(keyword_class)
      (keyword_index)
      (keyword_relationship)
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
     @font-lock-keyword-face)

    ;; === Variables ===
    :language objectscript_udl
    :feature variable
    ([(glvn (gvn))
      (lvn)
      (property_name)
      (method_arg)
      (instance_property (property_name))]
     @font-lock-variable-name-face
     [(pound_define macro_name: (pound_define_variable_name)
                    @font-lock-function-name-face)
      (pound_define_variable_args macro_arg: (macro_arg)
                                  @font-lock-variable-name-face)])

    ;; === System-defined things ===
    :language objectscript_udl
    :feature system_defined
    ([(routine_method_call)
      (system_defined_function)
      (system_defined_variable)
      (macro_function (_))
      (macro_constant)]
     @font-lock-preprocessor-face)

    ;; === Comments & Documentation ===
    :language objectscript_udl
    :feature comment
    :override t
    ([(line_comment_1)
      (line_comment_2)
      (line_comment_3)
      (block_comment)]
     @font-lock-comment-face
     (documatic_line) @font-lock-doc-face)

    ;; === Strings ===
    :language objectscript_udl
    :feature literal
    :override t
    ([(string_literal)
      (_read_prompt)
      (json_string_literal)]
     @font-lock-string-face
    [(numeric_literal (integer_literal) @font-lock-number-face)
      (json_number_literal)
      (goto_offset)]
     @font-lock-number-face)

    ;; === Brackets & Delimiters ===
    :language objectscript_udl
    :feature bracket
    :override t
    (["[" "]" "(" ")" "{" "}"] @font-lock-delimiter-face)
  ))


(defun objectscript_udl-ts-imenu-property (node)
  "Imenu boolean function for property using NODE."
  (equal (treesit-node-type node) "property"))

(defun objectscript_udl-ts-imenu-parameter (node)
  (equal (treesit-node-type node) "parameter"))

(defun objectscript_udl-ts-imenu-property-name-function (node)
    "Naming the imenu property nodes using NODE."
  (let ((name (treesit-node-text node)))
    (if (objectscript_udl-ts-imenu-property node)
        name
    name)))

(defun objectscript_udl-ts-imenu-method (node)
  "Imenu boolean function for methods using NODE."
  (or (equal (treesit-node-type node) "classmethod")
      (equal (treesit-node-type node) "method")))

(defun objectscript_udl-ts-imenu-method-name-function (node)
    "Naming the imenu method nodes using NODE."
    (let* ((method_definition (treesit-node-child node 1))
           (class_keyword (treesit-node-child node 0))
           (identifier (treesit-node-child method_definition 0))
           (name (treesit-node-text identifier)))
      (concat (treesit-node-text class_keyword) " " name)))


(defun objectscript_udl-ts-imenu-parameter-name-function (node)
  (treesit-node-text node))

(defun objectscript_core-ts-imenu-variable (node)
  (equal (treesit-node-type node) "command_set"))

(defun objectscript_core-ts-imenu-variable-name-function (node)
  (treesit-node-text (treesit-node-child (treesit-node-child node 1) 0)))

(defun objectscript_udl-ts-setup ()
  "Setup treesit for objectscript_udl-ts-mode."

 (setq-local treesit-font-lock-feature-list
              '((comment delimiter bracket definition)
                (class method constant system_defined function
                 variable literal keyword property argument)
                ))

 (setq-local treesit-range-settings
             (apply #'treesit-range-rules
                     objectscript_udl-ts-range-rules))

 (setq-local treesit-font-lock-settings
             (append python--treesit-settings
                     ;;js--treesit-font-lock-settings
                     java-ts-mode--font-lock-settings
                     (apply #'treesit-font-lock-rules objectscript_udl-ts-font-lock-rules)))

 ;; (setq-local treesit-font-lock-settings
 ;;             (apply #'treesit-font-lock-rules
 ;;                objectscript_udl-ts-font-lock-rules))
 (setq-local treesit-font-lock-level 4)

 (setq-local treesit--indent-verbose t)

 (setq-local treesit-simple-indent-rules
    '((objectscript_udl
     ;; Rule 1
     ((parent-is "program") parent 0)
     ((node-is "property") parent 4)
     ;; Rule 2
     ((parent-is "class_definition") parent 0)
     ;; Rule 3
     ((node-is "{") grand-parent  0)
     ((node-is "}") grand-parent  0)
     ;; Rule 4
     ((node-is "class_statement") parent 4)
     ((parent-is "class_statement") first-sibling 0)
     ((parent-is "documatic") first-sibling 0)
     ((parent-is "arguments") first-sibling 0)
     ;; Rule 5
     ((node-is "core_method_body_content") grand-parent 4)
     ((parent-is "core_method_body_content") parent 0)
     ((parent-is "command_write") (nth-sibling 1) 0)
     ((parent-is "command_read") (nth-sibling 1) 0)
     ((parent-is "command_set") (nth-sibling 1) 0)

     ((n-p-gp nil "program" "command_if") first-sibling 0)
     ((n-p-gp "}" "command_if" nil) parent 0)
     ((n-p-gp "}" "else_block" nil ) parent 0)
     ((node-is "else_block") parent 0)
     ((node-is "elseif_block") parent 0)
     ((n-p-gp nil "program" "else_block") first-sibling 0)
     ((parent-is "command_if") parent 4)
     ((n-p-gp "expression" "command_if" nil) parent 2)

     ((parent-is "command_dowhile") parent 4)
     ((parent-is "statements") parent 0)
     ((parent-is "else_block") parent 4)
     ((parent-is "elseif_block") parent 4)
     ((parent-is "binary_expression") first-sibling 0)

     ((n-p-gp "}" "command_for" nil) parent 0)
     ((n-p-gp "{" "command_for" nil ) parent 0)
     ((n-p-gp nil "program" "command_for") first-sibling 0)
     ((parent-is "command_for") parent 4)

     ((n-p-gp nil "statements" "command_while") grand-parent 4)
     ((n-p-gp "statements" "command_while" nil) parent 4)

     ((parent-is "system_defined_function") parent 4)

     ((parent-is "subscripts") (nth-sibling 1) 0)
     ((parent-is "program") parent 4)
     ((node-is "core_method_body_content") grand-parent 4)
     ((parent-is "method_definition") grand-parent 4)
     (no-node first-sibling 0)
     (no-node parent 0))))

  (setq-local treesit-simple-imenu-settings
              '(("Properties" objectscript_udl-ts-imenu-property nil objectscript_udl-ts-imenu-property-name-function)
                ("Methods" objectscript_udl-ts-imenu-method nil objectscript_udl-ts-imenu-method-name-function)
                ("Parameters" objectscript_udl-ts-imenu-parameter nil objectscript_udl-ts-imenu-parameter-name-function)
                ("Local Variables" objectscript_core-ts-imenu-variable nil objectscript_core-ts-imenu-variable-name-function)))
  (treesit-major-mode-setup))

(define-derived-mode objectscript_udl-ts-mode prog-mode "objectscript_udl"
  "Major mode for editing 'Objectscript, powered by tree-sitter."
  (when (and (treesit-ready-p 'objectscript_udl)
             (treesit-ready-p 'python)
      ;;       (treesit-ready-p 'javascript)
             (treesit-ready-p 'java))
    ;;(treesit-parser-create 'javascript)
    (treesit-parser-create 'java)
    (treesit-parser-create 'python)
    (treesit-parser-create 'objectscript_udl)
    (objectscript_udl-ts-setup)))

(if (treesit-ready-p 'objectscript_udl)
    (add-to-list 'auto-mode-alist '("\\.cls\\'" . objectscript_udl-ts-mode)))
(provide 'objectscript_udl-ts-mode)
;;; objectscript-treesitter-major-mode ends here
