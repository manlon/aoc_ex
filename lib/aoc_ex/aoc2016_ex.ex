defmodule AocEx.Aoc2016Ex do
  @moduledoc """
  Documentation for `Aoc2016Ex`.
  """

  def solve_all do
    [
      AocEx.Aoc2016Ex.Day01,
      AocEx.Aoc2016Ex.Day02,
      AocEx.Aoc2016Ex.Day03,
      AocEx.Aoc2016Ex.Day04,
      AocEx.Aoc2016Ex.Day05,
      AocEx.Aoc2016Ex.Day06,
      AocEx.Aoc2016Ex.Day07,
      AocEx.Aoc2016Ex.Day08,
      AocEx.Aoc2016Ex.Day09,
      AocEx.Aoc2016Ex.Day10,
      # AocEx.Aoc2016Ex.Day11,
      AocEx.Aoc2016Ex.Day12,
      AocEx.Aoc2016Ex.Day13,
      AocEx.Aoc2016Ex.Day14,
      AocEx.Aoc2016Ex.Day15,
      AocEx.Aoc2016Ex.Day16,
      AocEx.Aoc2016Ex.Day17,
      AocEx.Aoc2016Ex.Day18,
      AocEx.Aoc2016Ex.Day19,
      AocEx.Aoc2016Ex.Day20,
      AocEx.Aoc2016Ex.Day21,
      AocEx.Aoc2016Ex.Day22,
      AocEx.Aoc2016Ex.Day23,
      AocEx.Aoc2016Ex.Day24,
      AocEx.Aoc2016Ex.Day25
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
