defmodule AocEx.Aoc2025Ex.Day04 do
  use AocEx.Day, day: 4, year: 2025

  def roll_map() do
    {map, _size} = input_char_map_with_size()
    Map.filter(map, fn {_, v} -> v == ?@ end)
  end

  def accessible(map) do
    for {r, _} <- map,
        neighbor_rolls = Enum.filter(eight_neighbors(r), fn n -> Map.has_key?(map, n) end),
        length(neighbor_rolls) < 4 do
      r
    end
  end

  def remove_rolls(map) do
    case accessible(map) do
      [] ->
        map

      removes ->
        Map.drop(map, removes)
        |> remove_rolls()
    end
  end

  def solve1() do
    accessible(roll_map()) |> Enum.count()
  end

  def solve2() do
    map = roll_map()
    removed_map = remove_rolls(map)
    Enum.count(map) - Enum.count(removed_map)
  end
end
