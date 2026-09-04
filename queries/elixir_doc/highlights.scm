; inherits: elixir

; `iex> expr` parses as `iex > expr`; show the prompt as punctuation rather
; than as a variable followed by an operator.
((binary_operator
  left: [
    (identifier) @_prompt
    (call
      target: (identifier) @_prompt)
  ] @punctuation.special
  operator: ">" @punctuation.special)
  (#eq? @_prompt "iex"))
