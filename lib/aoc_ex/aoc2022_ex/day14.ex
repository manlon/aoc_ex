defmodule AocEx.Aoc2022Ex.Day14 do
  use AocEx.Day, year: 2022, day: 14
  @source {500, 0}

  def input_map do
    Enum.reduce(input_lines(), %{}, fn l, acc ->
      Enum.chunk_every(String.split(l, " -> "), 2, 1, :discard)
      |> Enum.reduce(acc, fn pair, acc ->
        Enum.reduce(segment_points(Enum.map(pair, &line_ints/1)), acc, &block!/2)
      end)
    end)
  end

  def block!(pos, map), do: put_in(map[pos], "#")
  def segment_points([[x1, y1], [x2, y2]]), do: segment_points({x1, y1}, {x2, y2})
  def segment_points({x1, y}, {x2, y}) when x1 < x2, do: Enum.map(x1..x2//1, &{&1, y})
  def segment_points({x, y1}, {x, y2}) when y1 < y2, do: Enum.map(y1..y2//1, &{x, &1})
  def segment_points(p1, p2), do: segment_points(p2, p1)

  def add_sand(map, _pos, source, _maxy, _floor?, n) when is_map_key(map, source), do: n
  def add_sand(_map, _pos = {_x, y}, _source, maxy, _floor = false, n) when y == maxy + 1, do: n

  def add_sand(map, pos = {_x, y}, source, maxy, _floor = true, n) when y == maxy + 1,
    do: add_sand(block!(pos, map), source, source, maxy, true, n + 1)

  def add_sand(map, pos = {x, y}, source, maxy, floor?, n) do
    case Enum.find([{x, y + 1}, {x - 1, y + 1}, {x + 1, y + 1}], &(!Map.has_key?(map, &1))) do
      nil -> add_sand(block!(pos, map), source, source, maxy, floor?, n + 1)
      pos -> add_sand(map, pos, source, maxy, floor?, n)
    end
  end

  def solve1(floor? \\ false) do
    map = input_map()
    {_maxx, maxy} = Enum.max(Map.keys(map))
    add_sand(map, @source, @source, maxy, floor?, 0)
  end

  def solve2, do: solve1(true)
end
