import "library/string.goose"
import "std/modules/array.goose"
import "std/modules/parser/parser.goose"
import "parser/ast.goose"

module Literal 
  def parseNumber() do
    return Parser::bind(
      Parser::token("number"),
      fun(x) return Parser::return_(AST::Number(String::toInteger(x.value)))
    )
  end

  def parseString() do
    return Parser::bind(
      Parser::token("string"),
      fun(x) return Parser::return_(AST::String(Array::sliceFromTo(x.value, 1, Array::length(x.value) - 1)))
    )
  end

  def parseChar() do
    return Parser::bind(
      Parser::token("char"),
      fun(x) return Parser::return_(AST::Char(x.value[1]))
    )
  end

  def parseBool() do
    return Parser::bind(
      Parser::token("bool"),
      fun(x) return Parser::return_(AST::Boolean(if x.value == "true" then true else false))
    )
  end

  def parseUnit() do
    return Parser::bind(
      Parser::string("nil"),
      fun(x) return Parser::return_(AST::Unit())
    )
  end

  def parseLiteral() do
    return Parser::choice([
      Literal::parseNumber(), 
      Literal::parseString(),
      Literal::parseChar(),
      Literal::parseBool(),
      Literal::parseUnit()
    ])
  end
end