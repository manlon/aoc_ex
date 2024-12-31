defmodule AocEx.Aoc2022Ex do
  @moduledoc """
  Documentation for `Aoc2022Ex`.
  """

  def solve_all do
    [
      AocEx.Aoc2022Ex.Day01,
      AocEx.Aoc2022Ex.Day02,
      AocEx.Aoc2022Ex.Day03,
      AocEx.Aoc2022Ex.Day04,
      AocEx.Aoc2022Ex.Day05,
      AocEx.Aoc2022Ex.Day06,
      AocEx.Aoc2022Ex.Day07,
      AocEx.Aoc2022Ex.Day08,
      AocEx.Aoc2022Ex.Day09,
      AocEx.Aoc2022Ex.Day10,
      AocEx.Aoc2022Ex.Day11,
      AocEx.Aoc2022Ex.Day12,
      AocEx.Aoc2022Ex.Day13,
      AocEx.Aoc2022Ex.Day14,
      AocEx.Aoc2022Ex.Day15,
      AocEx.Aoc2022Ex.Day16,
      AocEx.Aoc2022Ex.Day17,
      AocEx.Aoc2022Ex.Day18,
      AocEx.Aoc2022Ex.Day19,
      AocEx.Aoc2022Ex.Day20,
      AocEx.Aoc2022Ex.Day21,
      AocEx.Aoc2022Ex.Day22,
      AocEx.Aoc2022Ex.Day23,
      AocEx.Aoc2022Ex.Day24,
      AocEx.Aoc2022Ex.Day25
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
      mod = Module.concat(Aoc2022Ex, "Day#{num}")

      quote do
        alias unquote(mod)
      end
    end
  end
end
