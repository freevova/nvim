;; extends

; Elixir doc examples: indented blocks starting with an iex> prompt are parsed
; as Elixir under the `elixir_doc` alias, whose highlight groups are dimmed
; versions of the Elixir ones (see lua/config/elixir_doc_blocks.lua).
((indented_code_block) @injection.content
  (#lua-match? @injection.content "^%s*iex%(?%d*%)?>")
  (#set! injection.language "elixir_doc"))
