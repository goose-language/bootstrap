// import "std/modules/array.goose"
import "std/modules/IO.goose"
// import "std/modules/regex.goose"
// import "std/modules/type.goose"

// Lexer related imports
import "modules/lexer.goose"
import "modules/tokens.goose"
import "library/tuple.goose"
import "library/either.goose"
import "modules/parser.goose"
// import "parser/operator.goose"
// import "parser/expression.goose"
import "parser/toplevel.goose"

def main() do
  def content = IO::readFile("example/main.goose")
  def base = mutable Tokens::init()
  def rules = Tokens::addReserved(base, ["enum", "end", "public", "module", "def", "for", "in", "do", "while", "break", "if", "then", "else", "import", "extern", "return", "declare", "fun", "match", "type"])
  def tokens = Lexer::tokenize(*rules, content)

  match Toplevel::parseFunction()(tokens) do
    Tuple(Right(res), tokens) -> do
      IO::println(res)
      IO::println(tokens)
    end,
    Tuple(Left(err), _) -> IO::println(err)
  end
end
