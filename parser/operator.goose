import "parser/ast.goose"
type OP = { type_: string, lhs: AST::Expression, rhs: AST::Expression }
public module Operator
  declare expression(p: fun(): Parser[AST::Expression]): Parser[AST::Expression]
  
  def factor(expr) return 
    Parser::choice([
      Parser::lazyBetween(Parser::token("lparen"), Parser::token("rparen"), fun() Operator::expression(expr)),
      expr()
    ])
  
  def product(expr) return
    Parser::bind(Parser::andThenBound(Operator::factor(expr), 
      Parser::many(Parser::andThen(Parser::token("times"), Operator::factor(expr)))), fun(expr) do
        return Parser::return_(Array::reduce(Tuple::snd(expr), Tuple::fst(expr), fun (x, y) do
          return AST::Binary("*", x, y)
        end
      ))
    end)

  def sum(expr) return
    Parser::bind(Parser::andThenBound(Operator::product(expr), Parser::many(Parser::andThen(Parser::token("plus"), Operator::product(expr)))), fun(expr) do
      return Parser::return_(Array::reduce(Tuple::snd(expr), Tuple::fst(expr), fun (x, y) do
        return AST::Binary("+", x, y)
      end))
    end)

  def expression(expr) do
    return Operator::sum(expr)
  end
end