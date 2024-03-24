(comment) @comment

; Identifiers
;------------

; Escaped identifiers like \"+."
((value_identifier) @constant.macro
 (#match? @constant.macro "^\\.*$"))

[
  (type_identifier)
  (unit_type)
  (list)
  (list_pattern)
] @type

((type_identifier) @type.builtin
  (#any-of? @type.builtin
    "int" "char" "string" "float" "bool" "unit"))


((unit) @constant.builtin
  (#set! "priority" 105))

[
  (variant_identifier)
  (polyvar_identifier)
] @constructor

(record_type_field (property_identifier) @property)
(record_field (property_identifier) @property)
(object (field (property_identifier) @property))
(object_type (field (property_identifier) @property))
(module_identifier) @module

(member_expression (property_identifier) @variable.member)

(record_pattern
  (value_identifier) @variable.member)

(value_identifier_path
  (module_identifier)
  (value_identifier) @variable.member)

(labeled_argument
   label: (value_identifier) @property)


; Parameters
;----------------

(list_pattern (value_identifier) @variable.parameter)
(spread_pattern (value_identifier) @variable.parameter)

; String literals
;----------------

[
  (string)
  (template_string)
] @string

(template_substitution
  "${" @punctuation.special
  "}" @punctuation.special) @embedded

(character) @character
(escape_sequence) @string.escape

; Other literals
;---------------

[
  (true)
  (false)
] @constant.builtin

(number) @number
(polyvar) @constructor
(polyvar_string) @constructor

; Functions
;----------

; parameter(s) in parens
[
 (parameter (value_identifier))
 (labeled_parameter (value_identifier))
] @variable.parameter

; single parameter with no parens
(function parameter: (value_identifier) @variable.parameter)

; first-level descructuring (required for nvim-tree-sitter as it only matches direct
; children and the above patterns do not match destructuring patterns in NeoVim)
(parameter (tuple_pattern (tuple_item_pattern (value_identifier) @variable.parameter)))
(parameter (array_pattern (value_identifier) @variable.parameter))
(parameter (record_pattern (value_identifier) @variable.parameter))

; function identifier in let binding
(let_binding 
  pattern: (value_identifier) @function
  body: (function))

; function calls

; neovim and tree-sitter-cli handle conflicts differently:
; in tree-sitter-cli the first match wins, while in neovim the last match does.
; to get the desired result for `raise` in both, we put it before the general function call
; queries (for the CLI), but also add a priority metadata rule (for neovim).

(call_expression
  function: (value_identifier) @keyword.exception
   (#set! "priority" 105)
   (#eq? @keyword.exception "raise"))

(call_expression 
  function: (value_identifier_path
    _
    (value_identifier) @function.call))

(call_expression 
  function: (value_identifier) @function.call)

; highlight the right-hand side of a pipe operator as a function call
(pipe_expression
  _
  [(value_identifier_path
    _
    (value_identifier) @function.call)
    (value_identifier) @function.call])


; Meta
;-----

(decorator_identifier) @attribute

(extension_identifier) @keyword
("%") @keyword

; Misc
;-----

(subscript_expression index: (string) @property)
(polyvar_type_pattern "#" @constructor)

[
  "include"
  "open"
] @keyword.import


[
   "as"
   "private"
   "mutable"
   "rec"
] @keyword.modifier

[
  "type"
] @keyword.type

[
  "and"
  "with"
] @keyword.operator

[
  "export"
  "external"
  "let"
  "module"
  "assert"
  "await"
  "lazy"
  "constraint"
] @keyword

((function "async" @keyword))

(module_unpack "unpack" @keyword)

[
  "if"
  "else"
  "switch"
  "when"
] @keyword.conditional

[
  "exception"
  "try"
  "catch"
] @keyword.exception


[
  "for"
  "in"
  "to"
  "downto"
  "while"
] @keyword.repeat

[
  "."
  ","
  "|"
] @punctuation.delimiter

[
  "++"
  "+"
  "+."
  "-"
  "-."
  "*"
  "**"
  "*."
  "/."
  "<="
  "=="
  "==="
  "!"
  "!="
  "!=="
  ">="
  "&&"
  "||"
  "="
  ":="
  "->"
  "|>"
  ":>"
  "+="
  "=>"
  (uncurry)
] @operator

; Explicitly enclose these operators with binary_expression
; to avoid confusion with JSX tag delimiters
(binary_expression ["<" ">" "/"] @operator)

[
  "("
  ")"
  "{"
  "}"
  "["
  "]"
] @punctuation.bracket

(polyvar_type
  [
   "["
   "[>"
   "[<"
   "]"
  ] @punctuation.bracket)

[
  "~"
  "?"
  ".."
  "..."
] @punctuation.special

(ternary_expression ["?" ":"] @keyword.conditional.ternary)

; JSX
;----------
(jsx_identifier) @tag
(jsx_element
  open_tag: (jsx_opening_element ["<" ">"] @tag.delimiter))
(jsx_element
  close_tag: (jsx_closing_element ["<" "/" ">"] @tag.delimiter))
(jsx_self_closing_element ["/" ">" "<"] @tag.delimiter)
(jsx_fragment [">" "<" "/"] @tag.delimiter)
(jsx_attribute (property_identifier) @tag.attribute)

; Error
;----------

(ERROR) @error
