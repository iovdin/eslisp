# Serves as an adapter from the S-expression parser's format to the internal
# AST objects.
sexpr = require \sexpr-plus

parse-sexpr = (input) ->
  parser = sexpr!
  s = parser.main.parse input
  if s.status then s.value
  else throw Error "Parse error: expected #{s.expected} at #{s.index}"

list = (values, location)  -> { type : \list values, location }
atom = (value, location)   -> { type : \atom value, location }
string = (value, location) -> { type : \string value, location }

convert = (tree) ->

  # Parser returns locations with 1-based columns, but source map
  # expects 0-based, so let's fix that.

  tree.location
    ..start.column -= 1
    ..end  .column -= 1

  switch tree.type
  | \list   => list   (tree.content.map convert), tree.location
  | \atom   => atom   tree.content, tree.location
  | \string => string tree.content, tree.location
  | null    => throw Error "Unexpected type `#that` (of `#tree`)"

module.exports = parse-sexpr >> (.map convert)
