import "parser/expression.goose"
import "parser/operator.goose"
import "modules/combinator.goose"

module Toplevel 
  declare parseToplevel(): Parser[AST::Toplevel]

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

  def parsePublic() do
    return Parser::bind(
      Parser::andThenLazy(
        fun() Parser::reserved("public"),
        Toplevel::parseToplevel
      ),
      fun(tl) return Parser::return_(AST::Public(tl))
    )
  end

  def parseNamespace() do
    return Parser::bind(
      Parser::andThen(
        Parser::reserved("module"),
        Parser::andThenBound(
          Parser::token("identifier"),
          Parser::andThenBound(
            Parser::lazyMany(Toplevel::parseToplevel),
            Parser::reserved("end")
          )
        )
      ),
      fun (expr) do
        match expr do
          Tuple({ value: name }, Tuple(tls, _)) -> do
            return Parser::return_(AST::Namespace(name, tls))
          end
        end
      end
    )
  end

  def parseImportAs() do
    return Parser::bind(
      Parser::andThen(
        Parser::reserved("import"),
        Parser::andThenBound(
          Parser::token("string"),
          Parser::andThen(
            Parser::reserved("as"),
            Parser::token("identifier")
          )
        )
      ),
      fun (expr) do
        match expr do
          Tuple({ value: name }, { value: as }) -> do
            def value = Array::sliceFromTo(name, 1, Array::length(name) - 1)
            return Parser::return_(AST::ImportAs(value, as))
          end
        end
      end
    )
  end

  def parseImport() do
    return Parser::bind(
      Parser::andThen(
        Parser::reserved("import"),
        Parser::token("string")
      ),
      fun(e) do
        def value = Array::sliceFromTo(e.value, 1, Array::length(e.value) - 1)
        return Parser::return_(AST::Import(value))
      end
    )
  end

  def parseToplevel()
    return Parser::choice([
      Toplevel::parseNamespace(),
      Toplevel::parseFunction(),
      Toplevel::parsePublic(),
      Toplevel::parseImportAs(),
      Toplevel::parseImport()
    ])
end

def parseGoose(content) do
  return runParser(Parser::many(Toplevel::parseToplevel()), content)
end