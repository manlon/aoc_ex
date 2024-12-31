defmodule AocEx.Aoc2015Ex.Day12 do
  use AocEx.Day, year: 2015, day: 12

  def solve1, do: Enum.sum(hd(input_line_ints()))
  def solve2, do: count(JSON.decode!(input()))

  def count(list) when is_list(list), do: Enum.sum(for i <- list, do: count(i))
  def count(n) when is_integer(n), do: n
  def count(s) when is_binary(s), do: 0

  def count(map) when is_map(map) do
    vals = Map.values(map)
    if "red" in vals, do: 0, else: count(vals)
  end
end
