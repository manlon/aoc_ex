defmodule AocEx.Aoc2023Ex.Day13 do
  use AocEx.Day, day: 13

  def input_maps, do: for(s <- stanzas(), do: input_map_with_size(s) |> elem(0))
  def rotate(map), do: for({{r, c}, v} <- map, into: %{}, do: {{c, r}, v})

  def reflection_score(map, misses \\ 0) do
    case find_reflect_row(map, misses) do
      nil -> find_reflect_row(rotate(map), misses) + 1
      r -> (r + 1) * 100
    end
  end

  def find_reflect_row(map, misses \\ 0) do
    maxrow = Enum.max(for {{r, _}, _} <- map, do: r)

    Enum.find(0..(maxrow - 1), fn r ->
      {g1, g2} = Enum.split_with(map, fn {{mr, _}, _} -> mr > r end)
      count_misses(g1, g2, r) == misses or count_misses(g2, g1, r) == misses
    end)
  end

  def count_misses(small, big, reflect) do
    Enum.count(small, fn {{r, c}, v} -> {{2 * reflect - r + 1, c}, v} not in big end)
  end

  def solve1(), do: Enum.sum(for map <- input_maps(), do: reflection_score(map))
  def solve2(), do: Enum.sum(for map <- input_maps(), do: reflection_score(map, 1))
end
