# Turns an internal AST form into an estree object with reference to the given
# root environment.  Throws error unless the resulting estree AST is valid.

{ concat-map }   = require \prelude-ls
root-macro-table = require \./built-in-macros
statementify     = require \./es-statementify
environment      = require \./env
compile          = require \./compile

#{ create-transform-macro } = require \./import-macro

{ errors } = require \esvalid

module.exports = (root-env, ast, options={}) ->
  statements = ast
  program-ast =
    type : \Program
    body : statements
           |> concat-map -> compile root-env, it
           |> (.filter (isnt null)) # because macro definitions emit null
           |> (.map statementify)

  err = errors program-ast
  if err.length
    first-error = err.0
    throw first-error
  else
    return program-ast
