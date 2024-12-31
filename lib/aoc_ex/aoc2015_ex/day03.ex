defmodule AocEx.Aoc2015Ex.Day03 do
  use AocEx.Day, year: 2015, day: 3

  def locs(dirs), do: memo(dirs, {0, 0}, MapSet.new())
  def move("", _, visited), do: visited
  def move(<<"<">> <> rest, {x, y}, visited), do: memo(rest, {x - 1, y}, visited)
  def move(<<">">> <> rest, {x, y}, visited), do: memo(rest, {x + 1, y}, visited)
  def move(<<"v">> <> rest, {x, y}, visited), do: memo(rest, {x, y - 1}, visited)
  def move(<<"^">> <> rest, {x, y}, visited), do: memo(rest, {x, y + 1}, visited)
  def memo(dirs, pt, visited), do: move(dirs, pt, MapSet.put(visited, pt))

  def solve1, do: locs(input()) |> Enum.count()

  def solve2 do
    pairs = Enum.chunk_every(String.graphemes(input()), 2)
    l1 = Enum.join(for [x, _] <- pairs, do: x) |> locs()
    l2 = Enum.join(for [_, x] <- pairs, do: x) |> locs()
    Enum.count(l1) + Enum.count(l2) - Enum.count(MapSet.intersection(l1, l2))
  end
end
