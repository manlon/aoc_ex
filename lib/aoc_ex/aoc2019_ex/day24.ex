defmodule AocEx.Aoc2019Ex.Day24 do
  use AocEx.Day, year: 2019, day: 24

  def empty_grid do
    for r <- 0..4, c <- 0..4, reduce: %{} do
      map -> Map.put(map, {r, c}, ".")
    end
  end

  def tick(map) do
    Enum.reduce(map, %{}, fn {loc, c}, new_map ->
      neighbs =
        four_neighbors(loc)
        |> Enum.filter(&Map.has_key?(map, &1))
        |> Enum.count(fn loc -> map[loc] == "#" end)

      thing =
        case {c, neighbs} do
          {"#", 1} -> "#"
          {"#", _} -> "."
          {".", n} when n in [1, 2] -> "#"
          _ -> "."
        end

      Map.put(new_map, loc, thing)
    end)
  end

  @adjacent_down %{
    {2, 1} => for(r <- 0..4, do: {r, 0}),
    {1, 2} => for(c <- 0..4, do: {0, c}),
    {2, 3} => for(r <- 0..4, do: {r, 4}),
    {3, 2} => for(c <- 0..4, do: {4, c})
  }
  @adjacent_up Enum.reduce(@adjacent_down, %{}, fn {up, downs}, acc ->
                 Enum.reduce(downs, acc, fn down, acc ->
                   Map.update(acc, down, [up], &[up | &1])
                 end)
               end)

  def xxx do
    {@adjacent_down, @adjacent_up}
  end

  def r_neighbors(level, loc) do
    for n <- four_neighbors(loc),
        n != {2, 2},
        {r, c} = n,
        r in 0..4 and c in 0..4 do
      {level, n}
    end ++
      for n <- Map.get(@adjacent_up, loc, []) do
        {level - 1, n}
      end ++
      for n <- Map.get(@adjacent_down, loc, []) do
        {level + 1, n}
      end
  end

  def tick_recursive(map_of_maps) do
    levels = Enum.sort(Map.keys(map_of_maps))

    outer_level_num = Enum.at(levels, 0)
    inner_level_num = Enum.at(levels, -1)
    outer_level = map_of_maps[outer_level_num]
    inner_level = map_of_maps[inner_level_num]

    map_of_maps =
      if Enum.any?(Map.keys(@adjacent_up), fn loc -> outer_level[loc] == "#" end) do
        Map.put(map_of_maps, outer_level_num - 1, %{})
      else
        map_of_maps
      end

    map_of_maps =
      if Enum.any?(Map.keys(@adjacent_down), fn loc -> inner_level[loc] == "#" end) do
        Map.put(map_of_maps, inner_level_num + 1, %{})
      else
        map_of_maps
      end

    levels = Enum.sort(Map.keys(map_of_maps))

    Enum.reduce(levels, %{}, fn level, acc ->
      level_map = map_of_maps[level]

      new_level_map =
        for r <- 0..4,
            c <- 0..4,
            loc = {r, c},
            loc != {2, 2},
            reduce: %{} do
          map ->
            char = level_map[loc] || "."

            num_neighbs =
              r_neighbors(level, loc)
              |> Enum.count(fn {lvl, l} -> map_of_maps[lvl][l] == "#" end)

            thing =
              case {char, num_neighbs} do
                {"#", 1} -> "#"
                {"#", _} -> "."
                {".", n} when n in [1, 2] -> "#"
                _ -> "."
              end

            Map.put(map, loc, thing)
        end

      Map.put(acc, level, new_level_map)
    end)
  end

  def tick_until_seen(map, seen) do
    if map in seen do
      map
    else
      tick_until_seen(tick(map), MapSet.put(seen, map))
    end
  end

  def tick_n(map, 0), do: map

  def tick_n(map, n) do
    tick_n(tick_recursive(map), n - 1)
  end

  def score(map) do
    Enum.sort(map)
    |> Enum.with_index()
    |> Enum.filter(fn {{_, thing}, _i} -> thing == "#" end)
    |> Enum.map(fn {_, i} -> 2 ** i end)
    |> Enum.sum()
  end

  def count_all(map_of_maps) do
    Enum.map(map_of_maps, fn {_, map} ->
      Enum.count(map, fn {_, c} -> c == "#" end)
    end)
    |> Enum.sum()
  end

  def solve1 do
    {map, _} = input_map_with_size()

    tick_until_seen(map, MapSet.new())
    |> score()
  end

  def solve2 do
    {map, _} = input_map_with_size()
    map_of_maps = %{0 => map}

    tick_n(map_of_maps, 200)
    |> count_all()
  end
end
