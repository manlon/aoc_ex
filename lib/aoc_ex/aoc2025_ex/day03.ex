defmodule AocEx.Aoc2025Ex.Day03 do
  use AocEx.Day, day: 3, year: 2025

  def parsed_input(), do: input_line_ints() |> Enum.map(fn [i] -> Integer.digits(i) end)

  def prepend_digit(_d, :none), do: :none
  def prepend_digit(d, num), do: Integer.undigits([d | Integer.digits(num)])
  def safe_max(a, b), do: Enum.reject([a, b], &(&1 == :none)) |> Enum.max(&>=/2, fn -> :none end)
  def max_jolt(row, ct), do: max_jolt(row, ct, %{}) |> elem(0)
  def max_jolt([], _, memo), do: {:none, memo}
  def max_jolt(row, 1, memo), do: {Enum.max(row), memo}

  def max_jolt(row = [b | rest], ct, memo) do
    if Map.has_key?(memo, {row, ct}) do
      {Map.fetch!(memo, {row, ct}), memo}
    else
      {best_without_b, memo} = max_jolt(rest, ct, memo)
      {best_suffix_for_b, memo} = max_jolt(rest, ct - 1, memo)
      best = safe_max(best_without_b, prepend_digit(b, best_suffix_for_b))
      memo = Map.put(memo, {row, ct}, best)
      {best, memo}
    end
  end

  def solve1(), do: Enum.sum(Stream.map(parsed_input(), fn row -> max_jolt(row, 2) end))
  def solve2(), do: Enum.sum(Stream.map(parsed_input(), fn row -> max_jolt(row, 12) end))
end
