defmodule AocEx.Aoc2022Ex.Day04 do
  use AocEx.Day, year: 2022, day: 4

  def parsed do
    for line <- input_lines() do
      String.split(line, ",")
      |> Enum.map(&parse_elf/1)
    end
  end

  def parse_elf(elf) do
    String.split(elf, "-")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  def contains?({a1, a2}, {b1, b2}), do: a1 <= b1 and a2 >= b2
  def overlap?({a1, a2}, {b1, b2}), do: a1 <= b2 and b1 <= a2
  def solve1, do: Enum.count(parsed(), fn [e1, e2] -> contains?(e1, e2) or contains?(e2, e1) end)
  def solve2, do: Enum.count(parsed(), fn [e1, e2] -> overlap?(e1, e2) end)
end
