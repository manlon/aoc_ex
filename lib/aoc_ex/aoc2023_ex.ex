defmodule AocEx.Aoc2023Ex do
  @moduledoc """
  Documentation for `Aoc2023Ex`.
  """

  def solve_all do
    [
      AocEx.Aoc2023Ex.Day01,
      AocEx.Aoc2023Ex.Day02,
      AocEx.Aoc2023Ex.Day03,
      AocEx.Aoc2023Ex.Day04,
      AocEx.Aoc2023Ex.Day05,
      AocEx.Aoc2023Ex.Day06,
      AocEx.Aoc2023Ex.Day07,
      AocEx.Aoc2023Ex.Day08,
      AocEx.Aoc2023Ex.Day09,
      AocEx.Aoc2023Ex.Day10,
      AocEx.Aoc2023Ex.Day11,
      AocEx.Aoc2023Ex.Day12,
      AocEx.Aoc2023Ex.Day13,
      AocEx.Aoc2023Ex.Day14,
      AocEx.Aoc2023Ex.Day15,
      AocEx.Aoc2023Ex.Day16,
      AocEx.Aoc2023Ex.Day17,
      AocEx.Aoc2023Ex.Day18,
      AocEx.Aoc2023Ex.Day19,
      AocEx.Aoc2023Ex.Day20,
      AocEx.Aoc2023Ex.Day21,
      AocEx.Aoc2023Ex.Day22,
      AocEx.Aoc2023Ex.Day23,
      AocEx.Aoc2023Ex.Day24,
      AocEx.Aoc2023Ex.Day25
    ]
    # |> Enum.filter(fn mod -> :code.module_status(mod) == :loaded end)
    |> Enum.map(fn mod ->
      case Code.ensure_compiled(mod) do
        {:module, mod} ->
          result = apply(mod, :solve_timed, [])
          IO.inspect(day: mod, result: result)

        {:error, _err} ->
          IO.inspect("no module #{mod}")
      end
    end)

    :ok
  end
end
