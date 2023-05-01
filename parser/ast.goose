import "std/modules/datatypes/tuple.goose"
type Name = string
type Arguments = [string]

enum Namespaced 
  Namespace(Arguments, Name)
  Simple(Name)
end

public module Declaration 
  enum Declaration
    ID(Namespaced)
    Constructor(Declaration::Declaration, [Declaration::Declaration])
    Generic(string)
    List(Declaration::Declaration)
    Function([Declaration::Declaration], Declaration::Declaration)
    Structure([Tuple[string, Declaration::Declaration]])
  end
end

public module AST
  enum Literal 
    String(string)
    Number(int)
    Boolean(bool)
    Unit
    Char(char)
  end

  declare enum Expression
  enum Updated 
    UVariable(Namespaced)
    UListAccess(AST::Updated, AST::Expression)
    UStructureAccess(AST::Updated, string)
  end

  enum Pattern
    PVariable(Namespaced)
    PList([AST::Pattern])
    PStructure([Tuple[string, AST::Pattern]])
    PWildcard
    PLiteral(AST::Literal)
  end

  enum Expression
    Binary(string, AST::Expression, AST::Expression)
    Literal(AST::Literal)
    Identifier(Namespaced)
    Call(AST::Expression, [AST::Expression])
    Sequence([AST::Expression])
    If(AST::Expression, AST::Expression, AST::Expression)
    Return(AST::Expression)
    Lambda(Arguments, AST::Expression)
    Let(string, AST::Expression, AST::Expression)
    Match(AST::Expression, [Tuple[AST::Pattern, AST::Expression]])
    List([AST::Expression])
    Structure([Tuple[string, AST::Expression]])
    StructureAccess(AST::Expression, string)
    ListAccess(AST::Expression, AST::Expression)
    While(AST::Expression, [AST::Expression])
    For(string, AST::Expression, [AST::Expression])
    Update(string, AST::Expression)
  end

  enum Toplevel
    Function(Name, Arguments, AST::Expression)
    Type(Name, Arguments, Declaration::Declaration)
    Public(AST::Toplevel)
    Enumeration(Name, Arguments, [Tuple[string, [Declaration::Declaration]]])
    Namespace(Name, [AST::Toplevel])
    Import(Name)
    ImportAs(Name, Name)
    Declare(Name, Arguments, [Declaration::Declaration], Declaration::Declaration)
  end
end