defmodule AocEx.Aoc2015Ex.Day18 do
  use AocEx.Day, year: 2015, day: 18

  @corners [{0, 0}, {0, 99}, {99, 0}, {99, 99}]

  def tick(map) do
    Enum.reduce(map, %{}, fn {pos, val}, acc ->
      neighbor_count =
        eight_neighbors(pos)
        |> Enum.filter(&Map.has_key?(map, &1))
        |> Enum.count(&(map[&1] == ?#))

      new_val =
        case {val, neighbor_count} do
          {?#, c} when c in [2, 3] -> ?#
          {?#, _} -> ?.
          {?., 3} -> ?#
          {?., _} -> ?.
        end

      Map.put(acc, pos, new_val)
    end)
  end

  def stick(map, stuck) do
    Enum.reduce(stuck, map, fn pos, acc -> Map.put(acc, pos, ?#) end)
  end

  def solve1 do
    {map, _} = input_char_map_with_size()

    for _ <- 1..100, reduce: map do
      map -> tick(map)
    end
    |> Enum.count(fn {_, c} -> c == ?# end)
  end

  def solve2 do
    {map, _} = input_char_map_with_size()

    for _ <- 1..100, reduce: stick(map, @corners) do
      map -> stick(tick(map), @corners)
    end
    |> Enum.count(fn {_, c} -> c == ?# end)
  end
end
