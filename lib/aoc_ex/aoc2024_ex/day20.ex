defmodule AocEx.Aoc2024Ex.Day20 do
  @start "S"
  @fin "E"
  @empty "."

  def input do
    AocEx.Day.input_file_contents(2024, 20)
  end

  def input_map_with_size(input \\ nil) do
    (input || input())
    |> String.split("\n")
    |> Enum.map(fn line ->
      String.graphemes(line)
    end)
    |> Enum.with_index()
    |> Enum.reduce({%{}, {0, 0}}, fn {line, lineno}, {map, maxkey} ->
      Enum.reduce(Enum.with_index(line), {map, maxkey}, fn {val, colno}, {map, maxkey} ->
        map = Map.put(map, {lineno, colno}, val)
        maxkey = Enum.max([maxkey, {lineno, colno}])
        {map, maxkey}
      end)
    end)
  end

  def input_map_with_endpoints(input \\ nil) do
    {map, _} = input_map_with_size(input)
    {start, @start} = Enum.find(map, fn {_, val} -> val == @start end)
    {fin, @fin} = Enum.find(map, fn {_, val} -> val == @fin end)

    map =
      Map.put(map, start, @empty)
      |> Map.put(fin, @empty)

    {map, {start, fin}}
  end

  def addpos({r1, c1}, {r2, c2}), do: {r1 + r2, c1 + c2}
  def distance({r1, c1}, {r2, c2}), do: abs(r1 - r2) + abs(c1 - c2)

  def points_in_range(map, pt = {r, c}, d) do
    for nr <- (r - d)..(r + d) do
      for nc <- (c - d)..(c + d),
          np = {nr, nc},
          distance(pt, np) <= d,
          Map.get(map, np) == @empty do
        np
      end
    end
    |> List.flatten()
  end

  def find_track(map, acc = [pt | _rest]) do
    neighbs =
      points_in_range(map, pt, 1)

    seen = Enum.take(acc, 2)

    case Enum.filter(neighbs, fn n -> n not in seen end) do
      [] -> acc
      [n] -> find_track(map, [n | acc])
    end
  end

  def find_cheats(map, dists, pt, jump_dist \\ 2, cutoff \\ 100) do
    points_in_range(map, pt, jump_dist)
    |> Enum.filter(fn c -> dists[pt] - dists[c] - distance(pt, c) >= cutoff end)
    |> Enum.map(fn c -> {pt, c} end)
  end

  def solve1 do
    {map, {start, _fin}} = input_map_with_endpoints()

    track_points = find_track(map, [start])

    dist_map =
      track_points
      |> Enum.with_index()
      |> Map.new()

    Enum.flat_map(track_points, fn pt -> find_cheats(map, dist_map, pt) end)
    |> Enum.count()
  end

  def solve2 do
    {map, {start, _fin}} = input_map_with_endpoints()

    track_points = find_track(map, [start])

    dist_map =
      track_points
      |> Enum.with_index()
      |> Map.new()

    Enum.flat_map(track_points, fn pt -> find_cheats(map, dist_map, pt, 20) end)
    |> Enum.count()
  end
end
