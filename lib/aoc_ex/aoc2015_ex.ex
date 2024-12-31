defmodule AocEx.Aoc2015Ex do
  @moduledoc """
  Documentation for `Aoc2015Ex`.
  """
  def solve_all do
    [
      AocEx.Aoc2015Ex.Day01,
      AocEx.Aoc2015Ex.Day02,
      AocEx.Aoc2015Ex.Day03,
      AocEx.Aoc2015Ex.Day04,
      AocEx.Aoc2015Ex.Day05,
      AocEx.Aoc2015Ex.Day06,
      AocEx.Aoc2015Ex.Day07,
      AocEx.Aoc2015Ex.Day08,
      AocEx.Aoc2015Ex.Day09,
      AocEx.Aoc2015Ex.Day10,
      AocEx.Aoc2015Ex.Day11,
      AocEx.Aoc2015Ex.Day12,
      AocEx.Aoc2015Ex.Day13,
      AocEx.Aoc2015Ex.Day14,
      AocEx.Aoc2015Ex.Day15,
      AocEx.Aoc2015Ex.Day16,
      AocEx.Aoc2015Ex.Day17,
      AocEx.Aoc2015Ex.Day18,
      AocEx.Aoc2015Ex.Day19,
      AocEx.Aoc2015Ex.Day20,
      AocEx.Aoc2015Ex.Day21,
      AocEx.Aoc2015Ex.Day22,
      AocEx.Aoc2015Ex.Day23,
      AocEx.Aoc2015Ex.Day24,
      AocEx.Aoc2015Ex.Day25
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

      :ok
    end)
  end
end
