import "std/modules/parser/parser.goose"
import "std/modules/array.goose"
import "parser/ast.goose"

def parseNamespaced() do
  return Parser::choice([
    Parser::bind(
      Parser::sepBy1(
        Parser::token("identifier"),
        Parser::string("::")),
      fun(x) do
        def paths = Array::map(Array::sliceFromTo(x, 0, Array::length(x) - 1), fun(x) x.value)
        def name = x[Array::length(x) - 1].value
        return Parser::return_(if Array::empty(paths) then Simple(name) else Namespace(paths, name))
      end
    )
  ])
end