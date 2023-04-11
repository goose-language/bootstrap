
module Lexer 
  def tokenize[a](rules: [{ type_: string, regex: string, ignore: bool }], input: string) do
    if Array::length(input) == 0 then return []
    for rule in rules do
      def res = Regex::get(input, rule.regex)
      if Array::length(res) > 0 then do
        if Array::has(rule, "ignore") && rule.ignore then 
            return Lexer::tokenize(rules, Array::slice(input, Array::length(res)))
        else 
          return Array::concat(
            [{ type_: rule.type_, value: res }], 
            Lexer::tokenize(rules, Array::slice(input, Array::length(res))))
      end
    end
    return []
  end
end