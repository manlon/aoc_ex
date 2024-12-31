defmodule AocEx.Aoc2024Ex.Day04 do
  use AocEx.Day, day: 4, year: 2024

  @dirs [{1, 0}, {-1, 0}, {0, 1}, {0, -1}, {1, 1}, {1, -1}, {-1, 1}, {-1, -1}]

  def addpos({r1, c1}, {r2, c2}), do: {r1 + r2, c1 + c2}

  @word String.graphemes("XMAS")
  def solve1 do
    {map, _} = input_map_with_size()

    Enum.map(map, fn {pos, _} ->
      Enum.count(@dirs, fn dir -> find(map, pos, @word, dir) end)
    end)
    |> Enum.sum()
  end

  def find(map, pos, [letter | rest], dir) do
    if letter == map[pos] do
      find(map, addpos(pos, dir), rest, dir)
    else
      false
    end
  end

  def find(_map, _pos, [], _dir), do: true

  def solve2 do
    {map, _} = input_map_with_size()

    Enum.filter(map, fn {_, c} -> c == "A" end)
    |> Enum.map(fn {pos, _} ->
      coord_pairs = [[{1, -1}, {-1, 1}], [{-1, -1}, {1, 1}]]

      Enum.map(coord_pairs, fn pair ->
        Enum.map(pair, fn dir -> map[addpos(pos, dir)] end)
        |> Enum.sort()
      end)
    end)
    |> Enum.count(fn v -> v == [["M", "S"], ["M", "S"]] end)
  end
end
