defmodule AocEx.Aoc2015Ex.Day17 do
  use AocEx.Day, year: 2015, day: 17
  import Enum, only: [count: 1]

  def solve1 do
    subsets(input_ints())
    |> Stream.filter(&(Enum.sum(&1) == 150))
    |> count()
  end

  def solve2 do
    subsets(input_ints())
    |> Stream.filter(&(Enum.sum(&1) == 150))
    |> Stream.map(&length/1)
    |> Enum.frequencies()
    |> Enum.sort()
    |> hd()
    |> elem(1)
  end
end
