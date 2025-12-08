defmodule AocEx.Aoc2025Ex.Day08 do
  use AocEx.Day, day: 8, year: 2025

  def points do
    for line <- input_lines() do
      comma_int_list(line)
      |> List.to_tuple()
    end
  end

  def dist(_p1 = {x1, y1, z1}, _p2 = {x2, y2, z2}) do
    :math.sqrt(:math.pow(x1 - x2, 2) + :math.pow(y1 - y2, 2) + :math.pow(z1 - z2, 2))
  end

  def all_dists(pp) do
    for p1 <- pp, p2 <- pp, p1 < p2 do
      %{dist: dist(p1, p2), p1: p1, p2: p2}
    end
    |> Enum.sort()
  end

  def connect_point(_, sets, 0) do
    sets
  end

  def connect_point([%{dist: _dist, p1: p1, p2: p2} | distances], sets, num) do
    old_set_names = [sets[p1], sets[p2]]
    new_set_name = Enum.min(old_set_names)

    sets =
      Enum.reduce(sets, %{}, fn {point, set}, acc ->
        if set in old_set_names do
          Map.put(acc, point, new_set_name)
        else
          Map.put(acc, point, set)
        end
      end)

    connect_point(distances, sets, num - 1)
  end

  def connect_all([%{dist: _dist, p1: p1, p2: p2} | distances], sets) do
    old_set_names = [sets[p1], sets[p2]]
    new_set_name = Enum.min(old_set_names)

    sets =
      Enum.reduce(sets, %{}, fn {point, set}, acc ->
        if set in old_set_names do
          Map.put(acc, point, new_set_name)
        else
          Map.put(acc, point, set)
        end
      end)

    if Enum.count(Enum.uniq(Map.values(sets))) == 1 do
      {x1, _, _} = p1
      {x2, _, _} = p2
      x1 * x2
    else
      connect_all(distances, sets)
    end
  end

  def solve1() do
    pp = points()
    sets = Enum.map(pp, fn p -> {p, p} end) |> Map.new()

    connect_point(all_dists(pp), sets, 1000)
    |> Map.values()
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  def solve2() do
    pp = points()
    sets = Enum.map(pp, fn p -> {p, p} end) |> Map.new()

    connect_all(all_dists(pp), sets)
  end
end
