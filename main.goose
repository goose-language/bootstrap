import "std/modules/IO.goose"

// Lexer related imports
import "std/modules/parser/lexer.goose"
import "modules/tokens.goose"

import "std/modules/datatypes/tuple.goose"
import "std/modules/datatypes/either.goose"

// Parser related imports
import "std/modules/parser/parser.goose"
import "parser/toplevel.goose"

// Module resolving related imports
import "resolving/module.goose"
import "resolving/resolver.goose"

def main() do
  def content = IO::readFile("example/main.goose")
  def rules = Tokens::rules
  def tokens = Lexer::tokenize(rules, content)
  def res = parseGoose(tokens)
  match res do
    Left(err) -> IO::println("Error: " + err),
    Right(ast) -> do
      def resolved = Module::resolveImports(ast)
      IO::println(resolved)
    end
  end
end
