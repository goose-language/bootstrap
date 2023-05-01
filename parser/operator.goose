import "parser/ast.goose"
import "std/modules/parser/parser.goose"
import "std/modules/array.goose"
import "modules/combinator.goose"
import "std/modules/string.goose"

type OP = { type_: string, lhs: AST::Expression, rhs: AST::Expression }
public module Operator
  declare expression(p: fun(): Parser[AST::Expression]): Parser[AST::Expression]
    
  def factor(expr) return 
    Parser::choice([
      Parser::lazyBetween(Parser::token("lparen"), Parser::token("rparen"), fun() Operator::expression(expr)),
      expr()
    ])

  def access(expr) return
    Parser::bind(Parser::andThenBound(Operator::factor(expr), Parser::many(Parser::or(
      Parser::bind(
        Parser::andThen(Parser::token("dot"), Parser::token("identifier")),
        fun(x) do
          return Parser::return_(fun(e) do
            return AST::StructureAccess(e, x.value)
          end)
        end
      ), 
      Parser::bind(
        Combinator::brackets(Operator::factor(expr)),
        fun(x) 
          return Parser::return_(fun(e) do
            return AST::ListAccess(e, x)
          end)
      )
    ))), fun(expr) do
      def ex = Tuple::fst(expr)
      def operands = Tuple::snd(expr)
      return Parser::return_(Array::reduce(operands, ex, fun(x, f) f(x)))
    end)
  
  def product(expr) return
    Parser::bind(Parser::andThenBound(Operator::access(expr), 
      Parser::many(Parser::andThen(Parser::token("times"), Operator::access(expr)))), fun(expr) do
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