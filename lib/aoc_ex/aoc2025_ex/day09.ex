defmodule AocEx.Aoc2025Ex.Day09 do
  use AocEx.Day, day: 9, year: 2025

  def solve1() do
    inp = input_line_ints()

    for a <- inp,
        b <- inp,
        a < b,
        [xa, ya] = a,
        [xb, yb] = b,
        x = abs(xa - xb) + 1,
        y = abs(ya - yb) + 1,
        reduce: 0 do
      curmax ->
        max(curmax, x * y)
    end
  end

  def segs_by_orientation(points) do
    [first | _] = points

    segs =
      (points ++ [first])
      |> Enum.chunk_every(2, 1, :discard)

    horiz = for [[r, c1], [r, c2]] <- segs, do: {r, min(c1, c2)..max(c1, c2)}
    vert = for [[r1, c], [r2, c]] <- segs, do: {min(r1, r2)..max(r1, r2), c}
    {horiz, vert}
  end

  def crosses(_a = [ra, ca], _b = [rb, cb], horizs, verts) do
    {top, bottom} = Enum.min_max([ra, rb])
    {left, right} = Enum.min_max([ca, cb])

    hh =
      for h = {row, colrange} <- horizs,
          row in (top + 1)..(bottom - 1)//1,
          (left + 1) in colrange or (right - 1) in colrange do
        h
      end

    vv =
      for v = {rowrange, col} <- verts,
          col in (left + 1)..(right - 1)//1,
          (top + 1) in rowrange or (bottom - 1) in rowrange do
        v
      end

    hh ++ vv
  end

  def solve2() do
    pts = input_line_ints()

    {horiz, vert} = segs_by_orientation(pts)

    for a = [ra, ca] <- pts,
        b = [rb, cb] <- pts,
        a < b,
        _top = min(ra, rb),
        _left = min(ca, cb),
        # num_borders_above =
        #  Enum.count(horiz, fn {r, crange} -> r <= top and (left + 1) in crange end),
        # rem(num_borders_above, 2) == 1,
        [] == crosses(a, b, horiz, vert),
        area = (abs(ra - rb) + 1) * (abs(ca - cb) + 1) do
      area
    end
    |> Enum.max()
  end
end
