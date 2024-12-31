defmodule AocEx.Aoc2022Ex.Day03 do
  use AocEx.Day, year: 2022, day: 3

  def solve1 do
    input_lines()
    |> Enum.map(&String.to_charlist/1)
    |> Enum.map(&Enum.chunk_every(&1, div(length(&1), 2)))
    |> Enum.flat_map(&intersection/1)
    |> Enum.map(&priority/1)
    |> Enum.sum()
  end

  def solve2 do
    input_lines()
    |> Enum.map(&String.to_charlist/1)
    |> Enum.chunk_every(3)
    |> Enum.flat_map(&intersection/1)
    |> Enum.map(&priority/1)
    |> Enum.sum()
  end

  def priority(c) do
    if c >= ?a do
      c - ?a + 1
    else
      c - ?A + 27
    end
  end

  def intersection([set]), do: Enum.uniq(set)

  def intersection([set1, set2 | rest]) do
    items =
      for item <- set1,
          item in set2 do
        item
      end

    intersection([items | rest])
  end
end
