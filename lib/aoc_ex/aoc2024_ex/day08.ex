defmodule AocEx.Aoc2024Ex.Day08 do
  def input do
    AocEx.Day.input_file_contents(2024, 8)
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

  def pairs(list), do: pairs(list, [])

  def pairs([n | rest = [_ | _]], acc) do
    acc =
      Enum.reduce(rest, acc, fn i, acc ->
        [{n, i} | acc]
      end)

    pairs(rest, acc)
  end

  def pairs([_], acc), do: acc

  def addpos({r1, c1}, {r2, c2}), do: {r1 + r2, c1 + c2}
  def subpos({r1, c1}, {r2, c2}), do: {r1 - r2, c1 - c2}

  def on_map?(_maxes = {maxr, maxc}, _point = {r, c}) do
    r >= 0 && r <= maxr && c >= 0 && c <= maxc
  end

  def antinodes(a, b, maxes) do
    [
      subpos(a, b)
      |> addpos(a),
      subpos(b, a) |> addpos(b)
    ]
    |> Enum.filter(&on_map?(maxes, &1))
  end

  def line_points(a, b, maxes) do
    {dr, dc} = subpos(b, a)
    factor = Integer.gcd(dr, dc)
    {dr, dc} = {div(dr, factor), div(dc, factor)}
    dirs = [{dr, dc}, {-dr, -dc}]

    dirs
    |> Enum.flat_map(fn move ->
      follow_line(a, move, maxes)
    end)
    |> Enum.uniq()
  end

  def follow_line(pt, move, maxes, acc \\ []) do
    if on_map?(maxes, pt) do
      newpt = addpos(pt, move)
      follow_line(newpt, move, maxes, [pt | acc])
    else
      acc
    end
  end

  def solve1 do
    {map, maxes} = input_map_with_size()
    ants = Map.values(map) |> Enum.uniq() |> Enum.filter(&(&1 != "."))

    Enum.reduce(ants, [], fn ant, acc ->
      positions =
        Enum.filter(map, fn {_, v} -> v == ant end)
        |> Enum.map(fn {pos, _} -> pos end)

      anodes =
        pairs(positions)
        |> Enum.flat_map(fn {a, b} -> antinodes(a, b, maxes) end)

      anodes ++ acc
    end)
    |> Enum.uniq()
    |> Enum.count()
  end

  def solve2 do
    {map, maxes} = input_map_with_size()
    ants = Map.values(map) |> Enum.uniq() |> Enum.filter(&(&1 != "."))

    Enum.reduce(ants, [], fn ant, acc ->
      positions =
        Enum.filter(map, fn {_, v} -> v == ant end)
        |> Enum.map(fn {pos, _} -> pos end)

      anodes =
        pairs(positions)
        |> Enum.flat_map(fn {a, b} -> line_points(a, b, maxes) end)

      anodes ++ acc
    end)
    |> Enum.uniq()
    |> Enum.count()
  end
end
