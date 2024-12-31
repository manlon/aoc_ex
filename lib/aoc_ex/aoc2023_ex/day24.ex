defmodule AocEx.Aoc2023Ex.Day24 do
  use AocEx.Day, day: 24

  defmodule Parser do
    use AocEx.Parser
    i = ascii_string([?-, ?0..?9], min: 1) |> map({String, :to_integer, []})
    coord = wrap(i |> istr(", ") |> concat(i) |> istr(", ") |> concat(i))
    line = coord |> istr(" @ ") |> concat(coord)
    defmatch(:parse_line, line)
  end

  def xyisect(p1 = [[x1, y1, z1], [dx1, dy1, dz1]], p2 = [[x2, y2, z2], [dx2, dy2, dz2]]) do
    # x1 + t * dx1 = y1 + t * dy1

    # x1 - y1 = t * (dy1 - dx1)

    # y = mx + b
    # y = (dy1/dx1)x + b
    # y1 = (dy1/dx1)x1 + b
    # b = y1 - (dy1/dx1)x1
  end

  def solve1 do
    # x1 + t * dx1 = x2 + t * dx2
    # t * dx1 - t * dx2 = x2 - x1
    # t * (dx1 - dx2) = x2 - x1

    # y1 + t * dy1 = y2 + t * dy2
  end

  def solve2 do
    :ok
  end
end
