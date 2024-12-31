defmodule Aoc2023Ex.Day11 do
  use Aoc2023Ex.Day, day: 11
  @space "."
  @galaxy "#"

  def find_blanks(map, {maxrow, maxcol}) do
    rows =
      Enum.filter(0..maxrow, fn r ->
        stuff = for {{^r, _}, x} <- map, do: x
        Enum.all?(stuff, &(&1 == @space))
      end)

    cols =
      Enum.filter(0..maxcol, fn c ->
        stuff = for {{_, ^c}, x} <- map, do: x
        Enum.all?(stuff, &(&1 == @space))
      end)

    {rows, cols}
  end

  def dist_with_blanks({r1, c1}, {r2, c2}, {blank_rows, blank_cols}, blank_size \\ 1) do
    vert = abs(r1 - r2)
    vert_blanks = Enum.count(blank_rows, fn r -> r in r1..r2 end)
    horiz = abs(c1 - c2)
    horiz_blanks = Enum.count(blank_cols, fn c -> c in c1..c2 end)
    vert + vert_blanks * blank_size + horiz + horiz_blanks * blank_size
  end

  def galaxy_pair_dists(gap_expansion \\ 1) do
    {map, size} = input_map_with_size()
    blanks = find_blanks(map, size)
    galaxies = for {pos, @galaxy} <- map, do: pos

    Aoc2023Ex.Combos.pairs(galaxies)
    |> Stream.map(fn [g1, g2] -> dist_with_blanks(g1, g2, blanks, gap_expansion) end)
    |> Enum.sum()
  end

  def solve1, do: galaxy_pair_dists()
  def solve2, do: galaxy_pair_dists(999_999)
end
