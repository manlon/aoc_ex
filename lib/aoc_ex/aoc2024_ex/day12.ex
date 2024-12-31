defmodule AocEx.Aoc2024Ex.Day12 do
  def input do
    AocEx.Day.input_file_contents(2024, 12)
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

  @dirs [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]

  def addpos({r1, c1}, {r2, c2}), do: {r1 + r2, c1 + c2}
  def abspos({r, c}), do: {abs(r), abs(c)}
  def possort({r, c}, {1, 0}), do: {r, c}
  def possort({r, c}, {0, 1}), do: {c, r}

  def regions(map), do: regions(map, [], [], [])
  def regions(map, working, cur_region, acc)

  def regions(map, [], [], acc) do
    if Enum.empty?(map) do
      acc
    else
      regions(map, [Map.keys(map) |> hd()], [], acc)
    end
  end

  def regions(map, [], cur_region, acc) do
    regions(map, [], [], [Enum.uniq(cur_region) | acc])
  end

  def regions(map, [loc | rest], cur_region, acc) do
    {val, map} = Map.pop(map, loc)

    neighbs =
      for dir <- @dirs,
          nextloc = addpos(loc, dir),
          nextval = Map.get(map, nextloc),
          nextval == val,
          nextval not in rest do
        nextloc
      end

    regions(map, neighbs ++ rest, [loc | cur_region], acc)
  end

  def perim(map, region) do
    set = MapSet.new(region)

    Enum.reduce(region, 0, fn loc, acc ->
      fence =
        @dirs
        |> Enum.map(fn dir -> addpos(loc, dir) end)
        |> Enum.filter(fn next -> !MapSet.member?(set, next) end)
        |> Enum.count()

      fence + acc
    end)
  end

  def sides(map, region) do
    set = MapSet.new(region)

    Enum.reduce(region, %{}, fn loc, acc ->
      @dirs
      |> Enum.map(fn dir -> {dir, addpos(loc, dir)} end)
      |> Enum.filter(fn {dir, next} -> !MapSet.member?(set, next) end)
      |> Enum.group_by(fn {dir, next} -> dir end)
      |> Enum.reduce(acc, fn {dir, nexts}, acc ->
        nexts = Enum.map(nexts, fn {dir, next} -> next end)
        Map.update(acc, dir, nexts, fn x -> nexts ++ x end)
      end)
    end)
    |> Enum.map(fn {dir, locs} -> {dir, Enum.sort_by(locs, &possort(&1, abspos(dir)))} end)
    |> Enum.map(fn {dir, locs} -> {dir, combine_sides(locs)} end)
    |> Enum.flat_map(fn {dir, locs} -> locs end)
  end

  def adjacent?(a, b) do
    Enum.any?(@dirs, fn dir -> addpos(a, dir) == b end)
  end

  def combine_sides(locs), do: combine_sides(locs, [], [])
  def combine_sides([], cur_side, acc), do: [cur_side | acc]
  def combine_sides([loc | rest], [], acc), do: combine_sides(rest, [loc], acc)

  def combine_sides([loc | rest], cur_side = [last_loc | _], acc) do
    if adjacent?(loc, last_loc) do
      combine_sides(rest, [loc | cur_side], acc)
    else
      combine_sides(rest, [loc], [cur_side | acc])
    end
  end

  def solve1 do
    {map, _} = input_map_with_size()

    regions(map)
    |> Enum.map(fn r -> length(r) * perim(map, r) end)
    |> Enum.sum()
  end

  def solve2 do
    {map, _} = input_map_with_size()

    regions(map)
    |> Enum.map(fn r -> length(r) * length(sides(map, r)) end)
    |> Enum.sum()
  end
end
