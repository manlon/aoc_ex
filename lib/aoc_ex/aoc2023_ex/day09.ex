defmodule AocEx.Aoc2023Ex.Day09 do
  use AocEx.Day, day: 9

  def expand([]), do: {0, 0}

  def expand(line) do
    {l, r} = expand(line_diffs(line))
    {hd(line) - l, Enum.at(line, -1) + r}
  end

  def line_diffs([a, b | rest]), do: [b - a | line_diffs([b | rest])]
  def line_diffs(_), do: []

  def solve1, do: Enum.sum(for line <- input_line_ints(), {_, r} = expand(line), do: r)
  def solve2, do: Enum.sum(for line <- input_line_ints(), {l, _} = expand(line), do: l)
end
