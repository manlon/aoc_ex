defmodule AocEx.Aoc2019Ex do
  @moduledoc """
  Documentation for `Aoc2019Ex`.
  """

  def solve_all do
    [
      AocEx.Aoc2019Ex.Day01,
      AocEx.Aoc2019Ex.Day02,
      AocEx.Aoc2019Ex.Day03,
      AocEx.Aoc2019Ex.Day04,
      AocEx.Aoc2019Ex.Day05,
      AocEx.Aoc2019Ex.Day06,
      AocEx.Aoc2019Ex.Day07,
      AocEx.Aoc2019Ex.Day08,
      AocEx.Aoc2019Ex.Day09,
      AocEx.Aoc2019Ex.Day10,
      AocEx.Aoc2019Ex.Day11,
      AocEx.Aoc2019Ex.Day12,
      AocEx.Aoc2019Ex.Day13,
      AocEx.Aoc2019Ex.Day14,
      AocEx.Aoc2019Ex.Day15,
      AocEx.Aoc2019Ex.Day16,
      AocEx.Aoc2019Ex.Day17,
      AocEx.Aoc2019Ex.Day18,
      AocEx.Aoc2019Ex.Day19,
      AocEx.Aoc2019Ex.Day20,
      AocEx.Aoc2019Ex.Day21,
      AocEx.Aoc2019Ex.Day22,
      AocEx.Aoc2019Ex.Day23,
      AocEx.Aoc2019Ex.Day24,
      AocEx.Aoc2019Ex.Day25
    ]
    # |> Enum.filter(fn mod -> :code.module_status(mod) == :loaded end)
    |> Enum.map(fn mod ->
      case Code.ensure_compiled(mod) do
        {:module, mod} ->
          result1 = apply(mod, :part1, [])
          result2 = apply(mod, :part2, [])
          IO.inspect(day: mod, result: {result1, result2})

        {:error, _err} ->
          IO.inspect("no module #{mod}")
      end
    end)

    :ok
  end
end
