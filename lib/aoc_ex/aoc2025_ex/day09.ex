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

  def solve2() do
    segs =
      input_line_ints()
      |> Enum.chunk_every(2)
      |> Enum.map(fn [[r, c1], [r, c2]] ->
        {r, c1..c2}
      end)
  end
end
