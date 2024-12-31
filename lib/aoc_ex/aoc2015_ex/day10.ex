defmodule AocEx.Aoc2015Ex.Day10 do
  use AocEx.Day, year: 2015, day: 10
  @input ~c'3113322113'

  def chunk([i | items]), do: chunk(items, [[i]])
  def chunk([], acc), do: Enum.reverse(acc)
  def chunk([i | rest], [[i | resti] | acc]), do: chunk(rest, [[i, i | resti] | acc])
  def chunk([i | rest], [others | acc]), do: chunk(rest, [[i], others | acc])

  def look_say(numstr, n \\ 1)
  def look_say(numstr, 0), do: numstr

  def look_say(numstr, n) do
    chunk(numstr)
    |> Enum.flat_map(fn list = [i | _] -> :erlang.integer_to_list(length(list)) ++ [i] end)
    |> look_say(n - 1)
  end

  def solve1 do
    length(look_say(@input, 40))
  end

  def solve2 do
    length(look_say(@input, 50))
  end
end
