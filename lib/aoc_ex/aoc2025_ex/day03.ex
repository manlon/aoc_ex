defmodule AocEx.Aoc2025Ex.Day03 do
  use AocEx.Day, day: 3, year: 2025

  def parsed_input() do
    input_line_ints() |> Enum.map(fn [i] -> Integer.digits(i) end)
  end

  def max_jolt([], _, memo), do: {:ninf, memo}

  def max_jolt(row, 1, memo) do
    {Enum.max(row), memo}
  end

  def max_jolt(row = [b | rest], ct, memo) do
    if Map.has_key?(memo, {row, ct}) do
      n = Map.fetch!(memo, {row, ct})
      {n, memo}
    else
      {without_b, memo} = max_jolt(rest, ct, memo)
      {with_b_rest, memo} = max_jolt(rest, ct - 1, memo)

      with_b =
        case with_b_rest do
          :ninf -> :ninf
          x -> Integer.undigits([b | Integer.digits(x)])
        end

      {best, memo} =
        if max(with_b, without_b) == :ninf do
          {min(with_b, without_b), memo}
        else
          {max(with_b, without_b), memo}
        end

      memo = Map.put(memo, {row, ct}, best)
      {best, memo}
    end
  end

  def max_jolt_val(row, ct) do
    {v, _memo} = max_jolt(row, ct, %{})
    v
  end

  def solve1() do
    parsed_input()
    |> Enum.map(fn row -> max_jolt_val(row, 2) end)
  end

  def solve2() do
    parsed_input()
    |> Enum.map(fn row -> max_jolt_val(row, 12) end)
  end
end
