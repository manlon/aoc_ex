defmodule AocEx.Aoc2023Ex.Day21 do
  use AocEx.Day, year: 2023, day: 21

  @walkable [".", "S"]

  def input_map() do
    {map, size} = input_map_with_size()
    put_in(map[:size], size)
  end

  def map_get(map = %{size: {maxr, maxc}}, {r, c}) do
    r = rem(rem(r, maxr + 1) + maxr + 1, maxr + 1)
    c = rem(rem(c, maxc + 1) + maxc + 1, maxc + 1)
    map[{r, c}]
  end

  def moves(map, {r, c}) do
    four_neighbors({r, c})
    # |> Enum.filter(&(map_get(map, &1) in @walkable))
    |> Enum.filter(&(map[&1] in @walkable))
  end

  def reachable(map, steps), do: reachable(map, [startpos(map)], steps)
  def reachable(_map, froms, 0), do: MapSet.new(froms)

  def reachable(map, froms, steps) do
    froms =
      Enum.flat_map(froms, fn from -> moves(map, from) end)
      |> MapSet.new()

    reachable(map, froms, steps - 1)
  end

  def stableize(map, startpos \\ nil) do
    froms = [startpos || startpos(map)]
    stableize(map, froms, 0, %{odd: {0, [], false}, even: {0, [], false}})
  end

  def stableize(_map, _froms, _n, results = %{odd: {_, _, true}, even: {_, _, true}}), do: results

  def stableize(
        map,
        froms,
        n,
        results = %{odd: {_osteps, _oreachable, _}, even: {_esteps, _ereachable, _}}
      ) do
    new_reachable = reachable(map, froms, 1)
    parity = if rem(n, 2) == 0, do: :even, else: :odd
    {steps, reachable, done?} = results[parity]

    results =
      if done? do
        results
      else
        if reachable == new_reachable do
          Map.put(results, parity, {steps, reachable, true})
        else
          Map.put(results, parity, {n, new_reachable, false})
        end
      end

    stableize(map, new_reachable, n + 1, results)
  end

  def startpos(map) do
    {startpos, "S"} = Enum.find(map, fn {_pos, val} -> val == "S" end)
    startpos
  end

  def solve1 do
    map = input_map()

    reachable(map, [startpos(map)], 64)
    |> Enum.count()
  end

  def solve2 do
    map = input_map()
    {startpos, "S"} = Enum.find(map, fn {_pos, val} -> val == "S" end)

    reachable(map, [startpos], 26_501_365)
    |> Enum.count()
  end
end
