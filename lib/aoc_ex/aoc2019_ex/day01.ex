defmodule AocEx.Aoc2019Ex.Day01 do
  def input do
    AocEx.Day.input_file_contents(2019, 1)
    |> String.split("\n", trim: true)
    |> Stream.map(&String.to_integer/1)
  end

  def part1 do
    input()
    |> Enum.map(&(div(&1, 3) - 2))
    |> Enum.sum()
  end

  def req(x) do
    f = div(x, 3) - 2

    if f <= 0 do
      0
    else
      f + req(f)
    end
  end

  def part2 do
    input()
    |> Enum.map(&req/1)
    |> Enum.sum()
  end
end
