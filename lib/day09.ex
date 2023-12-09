defmodule Aoc2023Ex.Day09 do
  use Aoc2023Ex.Day

  def line_diffs([a, b]), do: [b - a]
  def line_diffs([a, b | rest]), do: [b - a | line_diffs([b | rest])]

  def line_diff_tower([0], acc), do: acc
  def line_diff_tower(list, acc), do: line_diff_tower(line_diffs(list), [list | acc])

  def expansion(list) do
    for row <- line_diff_tower(list, []), reduce: 0 do
      acc -> Enum.at(row, -1) + acc
    end
  end

  def left_expansion(list) do
    for [x | _] <- line_diff_tower(list, []), reduce: 0 do
      acc -> x - acc
    end
  end

  def solve1, do: Enum.sum(Enum.map(input_line_ints(), &expansion/1))

  def solve2, do: Enum.sum(Enum.map(input_line_ints(), &left_expansion/1))
end
