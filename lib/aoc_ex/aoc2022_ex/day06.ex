defmodule AocEx.Aoc2022Ex.Day06 do
  use AocEx.Day, year: 2022, day: 6

  def uniqs_pos(list, ct, n) do
    if length(Enum.uniq(Enum.take(list, ct))) == ct do
      n
    else
      uniqs_pos(tl(list), ct, n + 1)
    end
  end

  def solve1, do: uniqs_pos(String.graphemes(input()), 4, 4)
  def solve2, do: uniqs_pos(String.graphemes(input()), 14, 14)
end
