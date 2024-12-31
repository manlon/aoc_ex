defmodule AocEx.Aoc2022Ex.Day08 do
  use AocEx.Day, year: 2022, day: 8

  def solve1 do
    {map, maxcoord} = input_int_map_with_size()

    Enum.count(map, fn {pos, val} ->
      sightlines(map, pos, maxcoord)
      |> Enum.any?(fn line ->
        Enum.all?(line, fn ht -> ht < val end)
      end)
    end)
  end

  def solve2 do
    {map, maxcoord} = input_int_map_with_size()

    for {pos, val} <- map do
      Enum.product(for(l <- sightlines(map, pos, maxcoord), do: count_until(l, val)))
    end
    |> Enum.max()
  end

  def sightlines(map, {r, c}, {maxr, maxc}) do
    [
      for(rr <- (r - 1)..0//-1, do: Map.get(map, {rr, c})),
      for(rr <- (r + 1)..maxr//1, do: Map.get(map, {rr, c})),
      for(cc <- (c - 1)..0//-1, do: Map.get(map, {r, cc})),
      for(cc <- (c + 1)..maxc//1, do: Map.get(map, {r, cc}))
    ]
  end

  def count_until(list, n, ct \\ 0)
  def count_until([], _n, ct), do: ct
  def count_until([i | _], n, ct) when i >= n, do: ct + 1
  def count_until([_ | rest], n, ct), do: count_until(rest, n, ct + 1)
end
