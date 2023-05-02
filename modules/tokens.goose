import "std/modules/array.goose"
module Tokens
  def init() 
    return [
      { type_: "whitespace", regex: "^([[:space:]]+)", ignore: true },
      { type_: "number", regex: "^[[:digit:]]+" },
      { type_: "match", regex: "^(->)" },
      { type_: "dot", regex: "^(\\.)" },
      { type_: "plus", regex: "^\\+" },
      { type_: "minus", regex: "^\\-" },
      { type_: "times", regex: "^\\*" },
      { type_: "lparen", regex: "^\\(" },
      { type_: "rparen", regex: "^\\)" },
      { type_: "bool", regex: "^(true|false)" },
      { type_: "path", regex: "^::" },
      { type_: "identifier", regex: "^([[:alpha:]]([[:alnum:]]*))" },
      { type_: "string", regex: "^\"([^\"]*)\"" },
      { type_: "char", regex: "^'([^'])'" },
      { type_: "comma", regex: "^," },
      { type_: "operator", regex: "^([[:punct:]]+)" }
    ]
  
  def addReserved(rules, reserveds) do
    def rules_ = "^(" + Array::reduce(Array::join(reserveds, "|"), "", fun(x, y) return x + y) + ")"
    rules = [{ type_: "reserved", regex: rules_ }] + rules
    return rules
  end

  def base = Tokens::init()
  def rules = Tokens::addReserved(Tokens::base, ["enum", "end", "public", "module", "def", "for", "in", "do", "while", "break", "if", "then", "else", "import", "extern", "return", "declare", "fun", "match", "type", "as"])
end