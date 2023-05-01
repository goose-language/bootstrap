import "parser/ast.goose"
import "parser/literal.goose"
import "library/string.goose"
import "parser/operator.goose"
import "parser/pattern.goose"
import "parser/namespaced.goose"

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

  def parseIdentifier() 
    return Parser::bind(
      parseNamespaced(),
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
        fun() Parser::many(
          Parser::between(
            Parser::token("lparen"),
            Parser::token("rparen"),
            Parser::lazySepBy(fun() Operator::expression(Expression::parseExpression), fun() Parser::token("comma"))
          )
        )
      ),
      fun(expr) do
        match expr do
          Tuple(callee, args) -> do
            return Parser::return_(Array::reduce(args, callee, fun(acc, x) AST::Call(acc, x)))
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

  def parseList() do
    return Parser::bind(
      Parser::between(
        Parser::string("["),
        Parser::string("]"),
        Parser::lazySepBy(fun() Operator::expression(Expression::parseExpression), fun() Parser::token("comma"))
      ),
      fun(expr) do
        return Parser::return_(AST::List(expr))
      end
    )
  end

  def parseStructure() do
    return Parser::bind(
      Parser::andThen(
        Parser::string("\{"),
        Parser::andThenBoundLazy(
          fun() Parser::lazySepBy(
            fun() Parser::andThenBoundLazy(
              fun() Parser::token("identifier"),
              fun() Parser::andThenLazy(
                fun() Parser::string(":"),
                fun() Operator::expression(Expression::parseExpression)
              )
            ),
            fun() Parser::token("comma")
          ),
          fun() Parser::string("}")
        )
      ),
      fun(exprs) do
        match exprs do
          Tuple(fields, _) -> do
            def fields_ = Array::map(fields, fun(e) do
              match e do
                Tuple({ value: name }, value) -> 
                  return Tuple(name, value)
              end
            end)
            return Parser::return_(AST::Structure(fields_))
          end
        end
      end
    )
  end

  def parseLambda() do
    return Parser::bind(
      Parser::andThen(
        Parser::reserved("fun"),
        Parser::andThenBoundLazy(
          fun() Parser::between(
            Parser::token("lparen"),
            Parser::token("rparen"),
            Parser::sepBy(Parser::token("identifier"), Parser::token("comma"))
          ),
          fun() Operator::expression(Expression::parseExpression)
        )
      ),
      fun(expr) do
        match expr do
          Tuple(args, body) -> do
            def args_ = Array::map(args, fun(x) x.value)
            return Parser::return_(AST::Lambda(args_, body))
          end
        end
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
  
  def patternMatch() do
    return Parser::bind(
      Parser::andThen(
        Parser::reserved("match"),
        Parser::andThenBoundLazy(
          fun() Operator::expression(Expression::parseExpression),
          fun() Parser::andThenLazy(
            fun() Parser::reserved("do"),
            fun() Parser::andThenBoundLazy(
              fun() Parser::sepBy(
                Parser::andThenBound(
                  Pattern::pattern(),
                  Parser::andThenLazy(
                    fun() Parser::token("match"),
                    fun() Operator::expression(Expression::parseExpression)
                  )
                ),
                Parser::token("comma")
              ),
              fun() Parser::reserved("end")
            )
          )
        )
      ),
      fun(matches) do
        match matches do
          Tuple(expr, Tuple(cases, _)) -> do
            def cases_ = Array::map(cases, fun(x) do
              match x do
                Tuple(pattern, value) -> 
                  return Tuple(pattern, value)
              end
            end)
            return Parser::return_(AST::Match(expr, cases_))
          end
        end
      end
    )
  end

  def parseWhile() do
    return Parser::bind(
      Parser::andThen(
        Parser::reserved("while"),
        Parser::andThenBoundLazy(
          fun() Operator::expression(Expression::parseExpression),
          fun() Parser::andThen(
            Parser::reserved("do"),
            Parser::andThenBound(
              Parser::lazyMany(fun() Operator::expression(Expression::parseExpression)),
              Parser::reserved("end")
            )
          )
        )
      ),
      fun(expr) do
        match expr do
          Tuple(condition, Tuple(body, _)) -> do
            return Parser::return_(AST::While(condition, body))
          end
        end
      end
    )
  end

  def parseFor() do
    return Parser::bind(
      Parser::andThen(
        Parser::reserved("for"),
        Parser::andThenBoundLazy(
          fun() Parser::token("identifier"),
          fun() Parser::andThenLazy(
            fun() Parser::reserved("in"),
            fun() Parser::andThenBoundLazy(
              fun() Operator::expression(Expression::parseExpression),
              fun() Parser::andThen(
                Parser::reserved("do"),
                Parser::andThenBound(
                  Parser::lazyMany(fun() Operator::expression(Expression::parseExpression)),
                  Parser::reserved("end")
                )
              )
            )
          )
        )
      ),
      fun(expr) do
        match expr do
          Tuple({ value: name }, Tuple(collection, Tuple(body, _))) -> do
            return Parser::return_(AST::For(name, collection, body))
          end
        end
      end
    )
  end

  def parseUpdate() do
    return Parser::bind(
      Parser::andThenBound(
        Parser::token("identifier"),
        Parser::andThenLazy(
          fun() Parser::string("="),
          fun() Operator::expression(Expression::parseExpression)
        )
      ),
      fun(expr) do
        match expr do
          Tuple({ value: name }, value) -> do
            return Parser::return_(AST::Update(name, value))
          end
        end
      end
    )
  end

  def parseExpression() do
    return Parser::choice([
      Expression::parseDef(),
      Expression::parseUpdate(),
      Expression::parseWhile(),
      Expression::parseFor(),
      Expression::parseLiteral(),
      Expression::patternMatch(),
      Expression::parseReturn(),
      Expression::parseList(),
      Expression::parseStructure(),
      Expression::parseLambda(),
      Expression::parseCall(),
      Expression::parseIdentifier(),
      Expression::parseDoExpression(),
      Expression::parseIfExpression()
    ])
  end

end