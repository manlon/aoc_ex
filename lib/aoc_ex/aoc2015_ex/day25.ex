defmodule AocEx.Aoc2015Ex.Day25 do
  use AocEx.Day, year: 2015, day: 25

  def target, do: input_line_ints() |> then(fn [[r, c]] -> {r, c} end)
  def triangle(n), do: div(n * (n + 1), 2)
  def index({row, col}), do: triangle(col + row - 1) - (row - 1)
  def code(n), do: code(20_151_125, n - 1)
  def code(val, 0), do: val
  def code(val, n), do: code(rem(val * 252_533, 33_554_393), n - 1)
  def code_at(pos), do: code(index(pos))
  def solve1, do: code_at(target())
  def solve2, do: :ok
end
