import "parser/expression.goose"
import "parser/operator.goose"

module Toplevel 
  def parseFunction() do
    return Parser::bind(
      Parser::andThenBound(
        Parser::reserved("def"),
        Parser::andThenBound(
          Parser::token("identifier"),
          Parser::andThenBound(
            Parser::between(
              Parser::token("lparen"),
              Parser::token("rparen"),
              Parser::sepBy(
                Parser::token("identifier"),
                Parser::token("comma")
              )
            ),
            Operator::expression(Expression::parseExpression)
          )
        )
      ),
      fun (expr) do
        match expr do
          Tuple(_, Tuple(name, Tuple(args_, body))) -> do
            def args__ = Array::map(args_, fun (arg) return arg.value)
            def name_ = name.value
            return Parser::return_(AST::Function(name_, args__, body))
          end
        end
      end
    )
  end

  
end