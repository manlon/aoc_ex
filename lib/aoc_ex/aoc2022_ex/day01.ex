defmodule AocEx.Aoc2022Ex.Day01 do
  use AocEx.Day, year: 2022, day: 1

  def top_elves_sum(n \\ 1) do
    input()
    |> String.split("\n\n")
    |> Enum.map(fn grp -> String.split(grp) |> Enum.map(&String.to_integer/1) end)
    |> Enum.map(&Enum.sum/1)
    |> Enum.sort(:desc)
    |> Enum.take(n)
    |> Enum.sum()
  end

  def solve1 do
    top_elves_sum(1)
  end

  def solve2 do
    top_elves_sum(3)
  end
end
