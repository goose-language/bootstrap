import "library/array.goose"
module Tokens
  def init() 
    return [
      { type_: "number", regex: "^[[:digit:]]+" },
      { type_: "plus", regex: "^\\+" },
      { type_: "minus", regex: "^\\-" },
      { type_: "times", regex: "^\\*" },
      { type_: "lparen", regex: "^\\(" },
      { type_: "rparen", regex: "^\\)" },
      { type_: "bool", regex: "^(true|false)" },
      { type_: "whitespace", regex: "^([[:space:]]+)", ignore: true },
      { type_: "path", regex: "^::" },
      { type_: "identifier", regex: "^([[:alpha:]]([[:alnum:]]*))" },
      { type_: "string", regex: "^\"([^']*)\"" },
      { type_: "char", regex: "^'([^'])'" },
      { type_: "comma", regex: "^," },
      { type_: "operator", regex: "^([[:punct:]]+)" }
    ]
  
  def addReserved(rules, reserveds) do
    def rules_ = "^(" + Array::reduce(Array::join("|", reserveds), "", fun(x, y) return x + y) + ")"
    Array::shift(rules, { type_: "reserved", regex: rules_ })
    return rules
  end
end