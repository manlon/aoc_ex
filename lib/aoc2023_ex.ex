defmodule Aoc2023Ex do
  @moduledoc """
  Documentation for `Aoc2023Ex`.
  """
  use Aoc2023Ex.Day

  def solve_all do
    [
      Aoc2023Ex.Day01,
      Aoc2023Ex.Day02,
      Aoc2023Ex.Day03,
      Aoc2023Ex.Day04,
      Aoc2023Ex.Day05,
      Aoc2023Ex.Day06,
      Aoc2023Ex.Day07,
      Aoc2023Ex.Day08,
      Aoc2023Ex.Day09,
      Aoc2023Ex.Day10,
      Aoc2023Ex.Day11,
      Aoc2023Ex.Day12,
      Aoc2023Ex.Day13,
      Aoc2023Ex.Day14,
      Aoc2023Ex.Day15,
      Aoc2023Ex.Day16,
      Aoc2023Ex.Day17,
      Aoc2023Ex.Day18,
      Aoc2023Ex.Day19,
      Aoc2023Ex.Day20,
      Aoc2023Ex.Day21,
      Aoc2023Ex.Day22,
      Aoc2023Ex.Day23,
      Aoc2023Ex.Day24,
      Aoc2023Ex.Day25
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

  def make_module(day) do
    num = String.pad_leading(Integer.to_string(day), 2, "0")
    mod_name = "Day#{num}"
    file = "lib/day#{num}.ex"

    if File.exists?(file) do
      IO.puts("file #{file} already exists, skipping")
    else
      src =
        File.read!("lib/template.ex")
        |> String.replace("Template", mod_name)

      File.write!(file, src)
      Code.compile_file(file)
    end
  end

  defmacro reload! do
    IEx.Helpers.recompile()

    for i <- 1..25 do
      num = String.pad_leading(Integer.to_string(i), 2, "0")
      mod = Module.concat(Aoc2023Ex, "Day#{num}")

      quote do
        alias unquote(mod)
      end
    end
  end
end
