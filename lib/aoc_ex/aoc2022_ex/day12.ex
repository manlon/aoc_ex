defmodule AocEx.Aoc2022Ex.Day12 do
  use AocEx.Day, year: 2022, day: 12

  def prepare_map do
    {map, _} = input_char_map_with_size()
    {start, _} = Enum.find(map, fn {_, v} -> v == ?S end)
    {theend, _} = Enum.find(map, fn {_, v} -> v == ?E end)

    map =
      map
      |> Map.put(start, ?a)
      |> Map.put(theend, ?z)

    {map, start, theend}
  end

  def next_pos(map, position = {r, c}, seen) do
    cur_height = Map.get(map, position)

    Enum.filter(four_neighbors({r, c}), fn pos ->
      Map.has_key?(map, pos) and
        pos not in seen and
        Map.get(map, pos) <= cur_height + 1
    end)
  end

  def find_path(_, _, _positions = [], _, _), do: :infinity

  def find_path(map, n, positions, seen, target) do
    if target in positions do
      n
    else
      new_pos =
        Enum.flat_map(positions, fn p -> next_pos(map, p, seen) end)
        |> Enum.uniq()

      seen = Enum.reduce(new_pos, seen, fn p, seen -> MapSet.put(seen, p) end)
      find_path(map, n + 1, new_pos, seen, target)
    end
  end

  def solve1 do
    {map, start, theend} = prepare_map()
    find_path(map, 0, [start], MapSet.new([start]), theend)
  end

  def solve2 do
    {map, _start, theend} = prepare_map()

    Enum.filter(map, fn {_pos, c} -> c == ?a end)
    |> Enum.map(fn {pos, _} -> find_path(map, 0, [pos], MapSet.new([pos]), theend) end)
    |> Enum.min()
  end
end
