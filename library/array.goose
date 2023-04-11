public module Array
  def reduce(array, initial, fn) do
    def acc = initial
    def i = 0
    while i < Array::length(array) do
      acc = fn(IO::clone(acc), array[i])
      i = i + 1
    end
    return acc
  end
  def join(sep, array) do
    def acc = []
    def i = 0
    while i < Array::length(array) do
      Array::push(acc, array[i])
      if i < (Array::length(array) - 1) then do
        Array::push(acc, sep)
      end
      i = i + 1
    end
    return acc
  end

  def shift(array, value) do
    def acc = [value]
    def i = 0
    while i < Array::length(array) do
      Array::push(acc, array[i])
      i = i + 1
    end
    array = acc
    return array
  end

  def sliceFromTo(array, from, to) do
    def acc = []
    def i = from
    while i < to do
      Array::push(acc, array[i])
      i = i + 1
    end
    return acc
  end
end