public module Array
  def reduce[a, b](array: [b], initial: a, fn: fun(a, b): a) do
    def acc = mutable initial
    def i = mutable 0
    for item in array do
      acc = fn(*acc, item)
      i = *i + 1
    end
    return *acc
  end

  def join(sep, array) do
    def acc = mutable []
    def i = mutable 0
    while *i < Array::length(array) do
      Array::push(acc, array[*i])
      if *i < (Array::length(array) - 1) then do
        Array::push(acc, sep)
      end
      i = *i + 1
    end
    return *acc
  end

  def shift(array, value) do
    array = Array::concat([value], *array)
    return array
  end

  def sliceFromTo[a](array: [a], from: int, to: int) do
    def acc: Mutable[[a]] = mutable []
    def i: Mutable[int] = mutable from
    while *i < to do
      Array::push(acc, array[*i])
      i = *i + 1
    end
    return *acc
  end
end