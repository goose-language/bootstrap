import "std/modules/parser/parser.goose"

module Combinator 
  def brackets[a](p: Parser[a]): Parser[a] do
    Parser::between(Parser::string("["), Parser::string("]"), p)
  end

  def parens[a](p: Parser[a]): Parser[a] do
    Parser::between(Parser::string("("), Parser::string(")"), p)
  end

  def braces[a](p: Parser[a]): Parser[a] do
    Parser::between(Parser::string("\{"), Parser::string("}"), p)
  end

  def angles[a](p: Parser[a]): Parser[a] do
    Parser::between(Parser::string("<"), Parser::string(">"), p)
  end

  def anyToken[a](): Parser[a] do
    Parser::satisfy(fun(_) true)
  end
end