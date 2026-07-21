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
;;i
;;  Description
;;
;;; Code:

(require 'treesit)
(require 'python)
(require 'font-lock)


(defvar objectscript-ts-range-rules
  '(
    :embed python
    :host objectscript_udl
    ((method_definition
      ;; 1. Check if the language keyword is Python (case-insensitive)
      (method_keyword_external_language
       "="
       (typename) @lang
       (:equal @lang "python"))
      ;; 2. If it is, capture the body content as @python
      (external_method_body_content) @capture))
    ))

(defvar objectscript-udl-ts-font-lock-rules
    '(  ;; === Class Definitions ===
    :language objectscript_udl
    :feature class
    :override t
    ((class_definition
       (keyword_class) @font-lock-keyword-face
       (class_name (identifier) @font-lock-type-face)))

    :language objectscript_udl
    :feature class
    :override t
    ((parameter (keyword_parameter) @font-lock-keyword-face
                (parameter_name (identifier) @font-lock-property-name-face))
     (property (keyword_property)
               (property_name (identifier) @font-lock-property-name-face)
               (return_type (keyword_as)
                            (typename) @font-lock-type-face))
     (index (keyword_index)
            (index_name (identifier) @font-lock-variable-name-face)
            (keyword_on)
            (index_item (index_property (column_name (identifier) @font-lock-property-name-face))))
     (relationship (keyword_relationship)
                   (relationship_name (identifier) @font-lock-property-name-face)
                   (return_type (keyword_as) (typename) @font-lock-type-face)
                   (relationship_keywords
                    (relationship_keyword "=" @font-lock-operator-face
                                          [
                                           (typename) @font-lock-type-face
                                           (variable_datatype (objectscript_identifier)
                                                              @font-lock-type-face)
                                           ]) @font-lock-preprocessor-face )  )
     (foreignkey (keyword_foreignkey)
                 (foreignkey_name (identifier) @font-lock-property-name-face)
                 (property_name) @font-lock-property-name-face
                 (property_name) @font-lock-property-name-face
                 (keyword_references)
                 (class_name) @font-lock-type-face
                 (index_name) @font-lock-property-name-face)
     (foreignkey (foreignkey_keywords
                  (foreignkey_keyword "=" @font-lock-operator-face
                   [(typename) @font-lock-type-face]) @font-lock-preprocessor-face))
     (classmethod
      (keyword_classmethod) @font-lock-keyword-face
      (method_definition
       (method_name (identifier) @font-lock-function-name-face)))
     (method
      (keyword_method) @font-lock-keyword-face
      (method_definition
       (method_name (identifier) @font-lock-function-name-face)))
     (method_keyword_external_language) @font-lock-preprocessor-face
     (return_type
      (keyword_as) @font-lock-keyword-face
      (typename (identifier) @font-lock-type-face))
     (argument
      [
       (keyword_byref) @font-lock-keyword-face
       (keyword_output) @font-lock-keyword-face
      ])
     )


    )
  )

(defun objectscript-shared-ts-font-lock-rules (lang)
  (treesit-font-lock-rules

    :language lang
    :feature 'macro
    :override t
    '([(macro (macro_constant) @font-lock-preprocessor-face)
      (system_defined_function) @font-lock-preprocessor-face
      (system_defined_variable) @font-lock-preprocessor-face
      (extrinsic_function (line_ref (objectscript_identifier) @font-lock-preprocessor-face
                                    (routine_ref (routine_name) @font-lock-variable-name-face)))]
     )
    ;; === Comments & Documentation ===
    :language lang
    :feature 'comment
    :override t
    '([(line_comment_1)
      (block_comment)]
     @font-lock-comment-face
     (documatic_line) @font-lock-doc-face)

    ;; === Strings ===
    :language lang
    :feature 'literal
    :override t
    '((string_literal) @font-lock-string-face)


    ;; === Numbers ===
    :language lang
    :feature 'literal
    :override t
    '((numeric_literal)
     @font-lock-number-face)

    ;; === Variables ====
    :language lang
    :feature 'variable
    :override t
    '([(gvn (identifier) @font-lock-variable-name-face)
      (lvn (objectscript_identifier) @font-lock-variable-name-face)
      (oref_property (property_name (objectscript_identifier)
                                    @font-lock-variable-name-face))
      (instance_variable (property_name (objectscript_identifier) @font-lock-variable-name-face))
      (class_name) @font-lock-type-face
      (parameter_name (objectscript_identifier) @font-lock-property-use-face)
      ])

    ;; === Brackets & Delimiters ===
    :language lang
    :feature 'bracket
    :override t
    '(["[" "]" "(" ")" "{" "}"] @font-lock-delimiter-face)

    :language lang
    :feature 'keyword
    :override t
    '([(keyword_pound_pound_class)
      (keyword_set)
      (keyword_write)
      (keyword_read)
      (keyword_do)
      (keyword_kill)
      (keyword_while)
      (keyword_for)
      (keyword_open)
      (keyword_if)
      (keyword_else)
      (keyword_elseif)
      (keyword_oldelse)
      (keyword_tstart)
      (keyword_tcommit)
      (keyword_pound_define)
      (keyword_return)
      (keyword_quit)
      (keyword_new)
      (keyword_try)
      (keyword_catch)
      (keyword_throw)
      (keyword_break)
      (keyword_merge)
      (keyword_as)
      (keyword_of)
      (keyword_class)
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
      (keyword_storage)
      (keyword_projection)
      (keyword_extends)
      (keyword_not)
      (keyword_byref)
      (keyword_list)
      (keyword_output)
      (keyword_include)
      (keyword_on)
      ] @font-lock-keyword-face )


    :language lang
    :feature 'method
    :override t
    '([(class_method_call (class_ref)
                         (method_name [(objectscript_identifier_special) @font-lock-preprocessor-face
                                       (objectscript_identifier) @font-lock-function-call-face])

                         (method_args))
      (oref_method (method_name (objectscript_identifier) @font-lock-function-call-face)
                   (method_args))])


    :language lang
    :feature 'delimiter
    :override t
    '(["," "."] @font-lock-delimiter-face)
    )
)


(defvar objectscript-ts-indent-rules
  '((objectscript_udl
     ;; Comments should indent to match their parent
     ((node-is "line_comment_1") parent-bol 4)
     ;; Closing braces align with their opening construct
     ((node-is "}") parent-bol 0)
     ;; Content inside class body should be indented
     ((parent-is "class_body") parent-bol 4)
     ;; Method definition content (fix typo: was "method_defintion")
     ((parent-is "method_definition") parent-bol 4)
     ;; Class statements (like Parameter, Property, etc.) inside class_body
     ((node-is "class_statement") parent-bol 4)
     ;; Top level constructs align with beginning of line
     ((parent-is "class_definition") parent-bol 0)
     ((parent-is "program") parent-bol 0)
     ;; Default fallback
     (no-node parent-bol 0))))
)

(defun objectscript-ts-setup ()
  "Setup treesit for objectscript-ts-mode"
  
  (message "Starting objectscript-ts-setup...")
  
  ;; Check if we have parsers
  (message "Available parsers: %s" (treesit-parser-list))

 (setq-local treesit-range-settings
             (apply #'treesit-range-rules
                     objectscript-ts-range-rules))
  
  ;; Set font-lock feature list
  (setq-local treesit-font-lock-feature-list
              '((comment class keyword literal bracket variable method macro delimiter)))
  (message "Set font-lock feature list: %s" treesit-font-lock-feature-list)


  (setq-local treesit-font-lock-settings
              (append python--treesit-settings
              (apply #'treesit-font-lock-rules objectscript-ts-font-lock-rules)))


  (setq-local treesit--indent-verbose t)

  ;; (setq-local indent-line-function #'treesit-simple-indent-line)
   (setq-local treesit-simple-indent-rules objectscript-ts-indent-rules)


  ;; Setup treesit mode
  (treesit-major-mode-setup)
  )


(define-derived-mode objectscript-ts-mode prog-mode "objectscript"
  "Major mode for editing ObjectScript, powered by tree-sitter"

  (message "Checking treesitter availability...")
  (message "objectscript_udl ready: %s" (treesit-ready-p 'objectscript_udl))

  (if (treesit-ready-p 'objectscript_udl)
      (progn
        (message "Creating objectscript_udl parser...")
        (treesit-parser-create 'objectscript_udl)
        (treesit-parser-create 'python)
        (message "Running setup...")
        (objectscript-ts-setup)
        (message "Setup complete!"))
    (message "objectscript_udl parser not available!")))

(if (treesit-ready-p 'objectscript_udl)
    (add-to-list 'auto-mode-alist '("\\.cls\\'" . objectscript-ts-mode)))
(provide 'objectscript-ts-mode)
;; objectscript-treesitter-major-mode ends here
