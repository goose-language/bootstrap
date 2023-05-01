import "std/modules/IO.goose"

// Lexer related imports
import "std/modules/parser/lexer.goose"
import "modules/tokens.goose"

import "std/modules/datatypes/tuple.goose"
import "std/modules/datatypes/either.goose"

// Parser related imports
import "std/modules/parser/parser.goose"
import "parser/toplevel.goose"

def main() do
  def content = IO::readFile("example/main.goose")
  def base = Tokens::init()
  def rules = Tokens::addReserved(base, ["enum", "end", "public", "module", "def", "for", "in", "do", "while", "break", "if", "then", "else", "import", "extern", "return", "declare", "fun", "match", "type", "as"])
  def tokens = Lexer::tokenize(rules, content)

  match Toplevel::parseToplevel()(tokens) do
    Tuple(Right(res), tokens) -> do
      IO::println(res)
      IO::println(tokens)
    end,
    Tuple(Left(err), _) -> IO::println(err)
  end
end
