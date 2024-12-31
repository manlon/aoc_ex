defmodule AocEx.Aoc2022Ex.Day18 do
  use AocEx.Day, year: 2022, day: 18

  def cubes do
    for line <- input_lines() do
      line_ints(line)
    end
    |> MapSet.new()
  end

  def range(cubes) do
    coords = Enum.flat_map(cubes, & &1)
    (Enum.min(coords) - 1)..(Enum.max(coords) + 1)
  end

  def ortho_neighbors([x, y, z], range) do
    [
      [x - 1, y, z],
      [x + 1, y, z],
      [x, y + 1, z],
      [x, y - 1, z],
      [x, y, z + 1],
      [x, y, z - 1]
    ]
    |> Enum.filter(fn [x, y, z] -> x in range and y in range and z in range end)
  end

  def solve1 do
    set = cubes()
    l = Enum.count(set)
    range = range(set)

    Enum.reduce(set, 6 * l, fn cube, n ->
      neighbs =
        ortho_neighbors(cube, range)
        |> Enum.filter(fn c -> c in set end)

      n - length(neighbs)
    end)
  end

  def solve2 do
    set = cubes()
    range = range(set)
    count_outsides(set, range, [[0, 0, 0]], MapSet.new([[0, 0, 0]]), 0)
  end

  def count_outsides(_cubes, _range, [], _seen_air, n), do: n

  def count_outsides(cubes, range, [pt | rest], seen_air, n) do
    cube_neighbors =
      ortho_neighbors(pt, range)
      |> Enum.filter(fn p -> p in cubes end)

    n = n + length(cube_neighbors)

    neighbs =
      ortho_neighbors(pt, range)
      |> Enum.filter(fn p -> p not in cubes and p not in seen_air end)

    seen_air = Enum.reduce(neighbs, seen_air, fn p, seen_air -> MapSet.put(seen_air, p) end)

    count_outsides(cubes, range, rest ++ neighbs, seen_air, n)
  end
end
