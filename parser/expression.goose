import "parser/ast.goose"
import "parser/literal.goose"
import "library/string.goose"
import "parser/operator.goose"

public module Expression 
  declare parseExpression[a](): a

  def parseDoExpression() 
    Parser::bind(
      Parser::between(
        Parser::string("do"),
        Parser::string("end"),
        Parser::lazyMany(fun() Operator::expression(Expression::parseExpression))),
      fun (x) return Parser::return_(AST::Sequence(x))
    )
  
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

  def parseIdentifier() 
    return Parser::bind(
      Expression::parseNamespaced(),
      fun (x) return Parser::return_(AST::Identifier(x))
    )

  def parseLiteral() do
    return Parser::bind(
      Literal::parseLiteral(),
      fun (x) return Parser::return_(AST::Literal(x))
    )
  end

  def parseIfExpression() do
    return Parser::bind(
      Parser::andThenBoundLazy(
        fun() Parser::string("if"),
        fun() Parser::andThenBoundLazy(
          fun() Operator::expression(Expression::parseExpression),
          fun() Parser::andThenBoundLazy(
            fun() Parser::string("then"),
            fun() Parser::andThenBoundLazy(
              fun() Operator::expression(Expression::parseExpression),
              fun() Parser::andThenBoundLazy(
                fun() Parser::string("else"),
                fun() Operator::expression(Expression::parseExpression)
              )
            )
          )
        )
      ),
      fun(expr) do
        match expr do
          Tuple(_, Tuple(condition, Tuple(_, Tuple(then_, Tuple(_, else_))))) -> do
            return Parser::return_(AST::If(condition, then_, else_))
          end
        end
      end
    )
  end

  def parseCallee() do
    return Parser::choice([
      Expression::parseIdentifier(),
      Parser::lazyBetween(
        Parser::string("("),
        Parser::string(")"),
        fun() Operator::expression(Expression::parseExpression)
      )
    ])
  end

  def parseCall() do
    return Parser::bind(
      Parser::andThenBoundLazy(
        Expression::parseCallee,
        fun() Parser::between(
          Parser::token("lparen"),
          Parser::token("rparen"),
          Parser::lazySepBy(fun() Operator::expression(Expression::parseExpression), fun() Parser::token("comma"))
        )
      ),
      fun(expr) do
        match expr do
          Tuple(callee, args) -> do
            return Parser::return_(AST::Call(callee, args))
          end
        end
      end
    )
  end

  def parseReturn() do
    return Parser::bind(
      Parser::andThenLazy(
        fun() Parser::string("return"),
        fun() Operator::expression(Expression::parseExpression)
      ),
      fun(expr) do
        return Parser::return_(AST::Return(expr))
      end
    )
  end

  def parseDef() do
    return Parser::bind(
      Parser::andThen(
        Parser::reserved("def"),
        Parser::andThenBound(
          Parser::token("identifier"),
          Parser::andThenLazy(
            fun() Parser::string("="),
            fun() Parser::andThenBoundLazy(
              fun() Operator::expression(Expression::parseExpression),
              fun() Parser::option(
                Parser::andThenLazy(
                  fun() Parser::reserved("in"),
                  fun() Operator::expression(Expression::parseExpression)
                ),
                AST::Sequence([])
              )
            )
          )
        )
      ),
      fun(expr) do
        match expr do
          Tuple({ value: name }, Tuple(value, body)) -> do
            return Parser::return_(AST::Let(name, value, body))
          end
        end
      end
    )
  end

  def parseExpression() do
    return Parser::choice([
      Expression::parseDef(),
      Expression::parseLiteral(),
      Expression::parseCall(),
      Expression::parseIdentifier(),
      Expression::parseDoExpression(),
      Expression::parseIfExpression()
    ])
  end

end