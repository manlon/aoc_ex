defmodule AocEx.Aoc2015Ex.Day02 do
  use AocEx.Day, year: 2015, day: 2

  def solve1 do
    input_line_ints()
    |> Enum.map(fn [a, b, c] ->
      sides = [a * b, b * c, c * a]
      small = Enum.min(sides)
      2 * Enum.sum(sides) + small
    end)
    |> Enum.sum()
  end

  def solve2 do
    input_line_ints()
    |> Enum.map(fn [a, b, c] ->
      vol = a * b * c
      perim = Enum.min([2 * (a + b), 2 * (b + c), 2 * (c + a)])
      vol + perim
    end)
    |> Enum.sum()
  end
end
