defmodule AocEx.Aoc2023Ex.Day14 do
  use AocEx.Day, year: 2023, day: 14

  @rock "O"
  @empty "."

  def roll(map, size, direction) do
    for pt <- pts(direction, size), reduce: %{} do
      result ->
        neighb = dir(direction, pt)

        if map[pt] == @rock and result[neighb] == @empty do
          Map.put(result, neighb, @rock)
          |> Map.put(pt, @empty)
        else
          Map.put(result, pt, map[pt])
        end
    end
  end

  def pts(:north, {maxr, maxc}), do: for(r <- 0..maxr, c <- 0..maxc, do: {r, c})
  def pts(:south, {maxr, maxc}), do: for(r <- maxr..0//-1, c <- 0..maxc, do: {r, c})
  def pts(:west, {maxr, maxc}), do: for(c <- 0..maxc, r <- 0..maxr, do: {r, c})
  def pts(:east, {maxr, maxc}), do: for(c <- maxc..0//-1, r <- 0..maxr, do: {r, c})

  def dir(:north, {r, c}), do: {r - 1, c}
  def dir(:south, {r, c}), do: {r + 1, c}
  def dir(:west, {r, c}), do: {r, c - 1}
  def dir(:east, {r, c}), do: {r, c + 1}

  def roll_until_stable(map, size, direction) do
    map2 = roll(map, size, direction)

    if map == map2 do
      map
    else
      roll_until_stable(map2, size, direction)
    end
  end

  def load(map, maxr) do
    for {{r, _}, @rock} <- map, reduce: 0 do
      acc ->
        acc + maxr - r + 1
    end
  end

  def solve1(inp \\ nil) do
    {map, size = {maxr, _}} = inp || input_map_with_size()
    map = roll_until_stable(map, size, :north)
    load(map, maxr)
  end

  @target_n 4 * 1_000_000_000

  def solve2(inp \\ nil) do
    {map, size = {maxr, _}} = inp || input_map_with_size()

    cyc = Stream.cycle([:north, :west, :south, :east])

    Enum.reduce_while(cyc, {map, %{}, 0}, fn dir, {map, memo, n} ->
      map = roll_until_stable(map, size, dir)
      s = row_col_map_to_s(map)
      n = n + 1
      if rem(n, 100) == 0, do: dbg(n)

      cond do
        n == @target_n ->
          {:halt, load(map, maxr)}

        Map.has_key?(memo, s) ->
          cyc_len = n - memo[s]
          n = div(@target_n - n, cyc_len) * cyc_len + n
          dbg("found cycle skipping to n=#{n}")
          {:cont, {map, %{}, n}}

        true ->
          {:cont, {map, Map.put(memo, s, n), n}}
      end
    end)
  end
end
