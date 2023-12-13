defmodule Aoc2023Ex.Day13 do
  use Aoc2023Ex.Day

  def input_maps, do: stanzas() |> Enum.map(&input_map_with_size/1)

  def find_reflect({map, size}, ignore \\ nil) do
    {r, c} =
      case ignore do
        nil -> {nil, nil}
        [row: r] -> {r, nil}
        [col: c] -> {nil, c}
      end

    if rr = find_reflect_row({map, size}, r) do
      [row: rr]
    else
      if cc = find_reflect_col({map, size}, c) do
        [col: cc]
      else
        nil
      end
    end
  end

  def find_reflect_row({map, {maxrow, _}}, ignore \\ nil) do
    0..(maxrow - 1)
    |> Enum.filter(&(&1 != ignore))
    |> Enum.find(fn r ->
      {g1, g2} = Enum.split_with(map, fn {{mr, _}, _} -> mr > r end)
      {big, small} = if length(g1) > length(g2), do: {g1, g2}, else: {g2, g1}
      Enum.all?(small, fn {{mr, mc}, x} -> {{2 * r - mr + 1, mc}, x} in big end)
    end)
  end

  def find_reflect_col({map, {_, maxcol}}, ignore \\ nil) do
    0..(maxcol - 1)
    |> Enum.filter(&(&1 != ignore))
    |> Enum.find(fn c ->
      {g1, g2} = Enum.split_with(map, fn {{_, mc}, _} -> mc > c end)
      {big, small} = if length(g1) > length(g2), do: {g1, g2}, else: {g2, g1}
      Enum.all?(small, fn {{mr, mc}, x} -> {{mr, 2 * c - mc + 1}, x} in big end)
    end)
  end

  def maps_with_reflects() do
    for {map, size} <- input_maps(), do: {map, size, find_reflect({map, size})}
  end

  def solve1() do
    for {_map, _size, refl} <- maps_with_reflects(), reduce: 0 do
      total ->
        case refl do
          [row: r] -> total + 100 * (r + 1)
          [col: c] -> total + (c + 1)
        end
    end
  end

  @swap %{"#" => ".", "." => "#"}
  def unsmudged(map), do: Stream.map(map, fn {loc, x} -> Map.update!(map, loc, &@swap[&1]) end)

  def solve2 do
    for {map, size, ignore} <- maps_with_reflects(), reduce: 0 do
      total ->
        unsmudged(map)
        |> Enum.find_value(fn m -> find_reflect({m, size}, ignore) end)
        |> case do
          [row: r] -> total + 100 * (r + 1)
          [col: c] -> total + (c + 1)
        end
    end
  end
end
