defmodule Aoc2023Ex.Day22 do
  use Aoc2023Ex.Day

  defmodule Parser do
    use Aoc2023Ex.Parser
    brick = int() |> istr(",") |> int() |> istr(",") |> int()
    line = wrap(brick) |> istr("~") |> wrap(brick)
    defmatch(:parse_line, line)

    def parsed_input do
      Aoc2023Ex.Day22.input_lines()
      |> Enum.map(&parse_line/1)
      |> Enum.map(fn [[x1, y1, z1], [x2, y2, z2]] -> {x1..x2, y1..y2, z1..z2} end)
    end
  end

  def overlap?(brick1 = {rx1, ry1, rz1}, brick2 = {rx2, ry2, rz2}) do
    [{rx1, rx2}, {ry1, ry2}, {rz1, rz2}]
    |> Enum.all?(fn {r1, r2} -> !Range.disjoint?(r1, r2) end)
  end

  def units([[x1, y1, z1], [x2, y2, z2]]) do
    for x <- x1..x2, y <- y1..y2, z <- z1..z2, do: {x, y, z}
  end

  def ranges([[x1, y1, z1], [x2, y2, z2]]) do
    {x1..x2, y1..y2, z1..z2}
  end

  def fall(brick = {rx, ry, z1..z2}) do
    if z1 > 1 do
      {rx, ry, (z1 - 1)..(z2 - 1)}
    else
      brick
    end
  end

  def solve1 do
  end

  def solve2 do
    :ok
  end
end
