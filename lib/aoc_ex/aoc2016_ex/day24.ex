defmodule AocEx.Aoc2016Ex.Day24 do
  use AocEx.Day, year: 2016, day: 24

  def find_loc(map, val) do
    Enum.find(map, fn {_, v} -> v == val end)
    |> then(&elem(&1, 0))
  end

  def find_digit_dists(map, digit) do
    loc = find_loc(map, digit + ?0)
    find_dists(map, digit, [{loc, 0}], %{}, MapSet.new([loc]))
  end

  def find_all_digit_dists(map) do
    Enum.reduce(0..7, %{}, fn i, acc ->
      Map.merge(acc, find_digit_dists(map, i))
    end)
  end

  def find_dists(_, _, [], dists, _), do: dists

  def find_dists(map, start, [_pos = {loc, n} | rest], dists, seen) do
    v = map[loc]

    dists =
      if v in ?0..?9 do
        digit = v - ?0
        Map.put(dists, {start, digit}, n)
      else
        dists
      end

    {new_poss, seen} =
      for neighb <- four_neighbors(loc),
          Map.has_key?(map, neighb),
          map[loc] != ?#,
          !MapSet.member?(seen, neighb),
          reduce: {[], seen} do
        {acc, seen} ->
          {[{neighb, n + 1} | acc], MapSet.put(seen, neighb)}
      end

    find_dists(map, start, rest ++ new_poss, dists, seen)
  end

  def perms(items), do: perms(Enum.reverse(items), [])
  def perms([], order), do: [order]

  def perms(items, order) do
    Stream.flat_map(items, fn i ->
      perms(items -- [i], [i | order])
    end)
  end

  def solve1 do
    {map, _} = input_char_map_with_size()
    dists = find_all_digit_dists(map)

    perms(1..7)
    |> Stream.map(fn path ->
      Enum.chunk_every([0 | path], 2, 1, :discard)
      |> Enum.map(fn [a, b] -> dists[{a, b}] end)
      |> Enum.sum()
    end)
  end

  def solve2 do
    {map, _} = input_char_map_with_size()
    dists = find_all_digit_dists(map)

    perms(1..7)
    |> Stream.map(fn path ->
      Enum.chunk_every([0 | path] ++ [0], 2, 1, :discard)
      |> Enum.map(fn [a, b] -> dists[{a, b}] end)
      |> Enum.sum()
    end)
  end
end
