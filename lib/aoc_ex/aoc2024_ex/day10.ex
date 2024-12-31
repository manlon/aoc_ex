defmodule AocEx.Aoc2024Ex.Day10 do
  def input do
    AocEx.Day.input_file_contents(2024, 10)
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
        map = Map.put(map, {lineno, colno}, String.to_integer(val))
        maxkey = Enum.max([maxkey, {lineno, colno}])
        {map, maxkey}
      end)
    end)
  end

  @dirs [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]

  def addpos({r1, c1}, {r2, c2}), do: {r1 + r2, c1 + c2}

  def hike(_map, [], acc), do: acc

  def hike(map, [path = [loc | _] | rest], acc) do
    val = Map.get(map, loc)

    nextlocs =
      Enum.map(@dirs, fn dir -> addpos(loc, dir) end)
      |> Enum.filter(fn next -> Map.get(map, next) == val + 1 end)

    case nextlocs do
      [] ->
        hike(map, rest, [path | acc])

      _ ->
        paths = Enum.map(nextlocs, fn next -> [next | path] end)
        hike(map, paths ++ rest, acc)
    end
  end

  def reachable_peaks(map, pos) do
    _paths =
      hike(map, [[pos]], [])
      |> List.flatten()
      |> Enum.filter(fn pos -> Map.get(map, pos) == 9 end)
      |> Enum.uniq()
      |> Enum.count()
  end

  def full_trails(map, pos) do
    _paths =
      hike(map, [[pos]], [])
      |> Enum.filter(fn path -> Map.get(map, hd(path)) == 9 end)
      |> Enum.count()
  end

  def solve1 do
    {map, _} = input_map_with_size()

    starts =
      Enum.filter(map, fn {_p, v} -> v == 0 end)
      |> Enum.map(fn {p, _v} -> p end)

    Enum.map(starts, fn start -> reachable_peaks(map, start) end)
  end

  def solve2 do
    {map, _} = input_map_with_size()

    starts =
      Enum.filter(map, fn {_p, v} -> v == 0 end)
      |> Enum.map(fn {p, _v} -> p end)

    Enum.map(starts, fn start -> full_trails(map, start) end)
    |> Enum.sum()
  end
end
