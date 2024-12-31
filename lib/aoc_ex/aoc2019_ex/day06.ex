defmodule AocEx.Aoc2019Ex.Day06 do
  def input do
    AocEx.Day.input_file_contents(2019, 6)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ")"))
    |> Enum.reduce(%{}, fn [x, y], acc ->
      Map.put(acc, y, x)
    end)
  end

  def part1 do
    map = input()

    map
    |> Enum.reduce(%{"COM" => 0}, fn {moon, _planet}, acc ->
      calcpath(map, acc, moon)
    end)
    |> Map.values()
    |> Enum.sum()
  end

  def calcpath(map, paths, moon) do
    if Map.has_key?(paths, moon) do
      paths
    else
      planet = map[moon]
      paths = calcpath(map, paths, planet)
      Map.put(paths, moon, paths[planet] + 1)
    end
  end

  def part2 do
    map = input()
    san_path = path_to_root(map, "SAN")
    you_path = path_to_root(map, "YOU")
    {santa, you} = eliminate_common_ancestors(san_path, you_path)
    length(santa) + length(you)
  end

  def path_to_root(map, obj, acc \\ []) do
    if Map.has_key?(map, obj) do
      path_to_root(map, map[obj], [obj | acc])
    else
      [obj | acc]
    end
  end

  def eliminate_common_ancestors([h1 | r1], [h2 | r2]) do
    if h1 == h2 do
      eliminate_common_ancestors(r1, r2)
    else
      {r1, r2}
    end
  end
end
