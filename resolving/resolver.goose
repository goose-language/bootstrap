import "parser/ast.goose"
import "std/modules/IO.goose"
import "library/env.goose"

// Lexer related imports
import "std/modules/parser/lexer.goose"
import "modules/tokens.goose"

module Module 
  declare resolveImports(ast: [AST::Toplevel]): [AST::Toplevel]

  def path = Env::get("GOOSE")

  def resolveImport(path: string): [AST::Toplevel] do
    def path_ = if Array::startsWith(path, "std/") 
      then if Module::path != "" 
        then Module::path + "/" + path
        else IO::throw("Goose variable GOOSE is not set in environment")
      else path

    if IO::fileExists(path_) 
      then do
        def content = IO::readFile(path_)
        def tokens = Lexer::tokenize(Tokens::rules, content)
        def ast = TL::parseGoose(tokens)
        match ast do
          Left(err) -> do
            IO::println("Error: {err}")
            IO::exit(0)
          end,
          Right(ast) -> do
            def resolved = Module::resolveImports(ast)
            return resolved
          end
        end
      end 
      else do
        IO::println("File not found: {path}")
        IO::exit(0)
      end
  end

  def resolveImports(ast: [AST::Toplevel]): [AST::Toplevel] do
    def res: [AST::Toplevel] = []
    for node in ast do
      match node do
        AST::ImportAs(path, name) -> do
          IO::println(path)
        end,

        AST::Import(path) -> do
          res = res + Module::resolveImport(path)
        end,

        AST::Public(node_) -> do
          def resolved = Module::resolveImports([node_])
          res = res + [AST::Public(resolved[0])]
        end,

        AST::Namespace(name, nodes) -> do
          def resolved = Module::resolveImports(nodes)
          res = res + [AST::Namespace(name, resolved)]
        end,

        _ -> do
          res = res + [node]
        end
      end
    end
    return res
  end
end