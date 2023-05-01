import "std/modules/parser/parser.goose"
import "modules/combinator.goose"
import "parser/ast.goose"
import "parser/namespaced.goose"
import "parser/literal.goose"

module Pattern 
  declare pattern(): Parser[AST::Pattern]
  def variable() do
    return Parser::bind(
      parseNamespaced(),
      fun(var) do
        return Parser::return_(AST::PVariable(var))
      end
    )
  end

  def list() do
    return Parser::bind(
      Combinator::brackets(
        Parser::lazySepBy(
          Pattern::pattern,
          fun() Parser::token("comma")
        )
      ),
      fun(patterns) do
        return Parser::return_(AST::PList(patterns))
      end
    )
  end

  def structure() do
    return Parser::bind(
      Combinator::braces(
        Parser::sepBy(
          Parser::andThenBound(
            Parser::token("identifier"),
            Parser::andThenLazy(
              fun() Parser::token("colon"),
              Pattern::pattern
            )
          ),
          Parser::token("comma")
        )
      ),
      fun(fields) do
        IO::println(fields)
        return Parser::return_(AST::PWildcard())
      end
    )
  end

  def wildcard() do
    return Parser::bind(
      Parser::string("_"),
      fun(_) do
        return Parser::return_(AST::PWildcard())
      end
    )
  end

  def literal() do
    return Parser::bind(
      Literal::parseLiteral(),
      fun(lit) do
        return Parser::return_(AST::PLiteral(lit))
      end
    )
  end

  def pattern() do
    return Parser::choice([
      Pattern::literal(),
      Pattern::wildcard(),
      Pattern::variable(),
      Pattern::list(),
      Pattern::structure()
    ])
  end
end