defmodule AocEx.Aoc2022Ex.Day15 do
  use AocEx.Day, year: 2022, day: 15

  def sensor_locations do
    Enum.map(input_lines(), &line_ints/1)
    |> Enum.map(fn [sx, sy, bx, by] -> {{sx, sy}, dist({sx, sy}, {bx, by})} end)
  end

  def dist({sx, sy}, {bx, by}), do: abs(sx - bx) + abs(sy - by)
  def overlap?({a, b}, {c, d}), do: c <= b and d >= a
  def merge({a, b}, {c, d}), do: {Enum.min([a, c]), Enum.max([b, d])}
  def covered?(pos, sensors), do: Enum.any?(sensors, fn {s, d} -> dist(s, pos) <= d end)

  def covered_ranges(y, sensor_locs \\ nil) do
    (sensor_locs || sensor_locations())
    |> Enum.reduce([], fn {{sx, sy}, d}, acc ->
      dy = abs(y - sy)

      if dy > d do
        acc
      else
        dx = d - dy
        [{sx - dx, sx + dx} | acc]
      end
    end)
    |> merge_overlapping([])
  end

  def merge_overlapping([], acc), do: Enum.sort(acc)

  def merge_overlapping([s | rest], acc) do
    case(Enum.find(rest, fn o -> overlap?(s, o) end)) do
      nil -> merge_overlapping(rest, [s | acc])
      other -> merge_overlapping([merge(s, other) | rest -- [other]], acc)
    end
  end

  def solve1, do: covered_ranges(2_000_000) |> then(fn [{a, b}] -> b - a end)

  def solve2 do
    sensor_locs = sensor_locations()

    sensor_locs
    |> Enum.flat_map(fn {{x, y}, d} -> [{x - (d + 1), y}, {x + d + 1, y}] end)
    |> pairs()
    |> Stream.flat_map(fn [p1, p2] -> intersect_from_points(p1, p2) end)
    |> Stream.filter(fn {x, y} -> x in 0..4_000_000 and y in 0..4_000_000 end)
    |> Stream.filter(fn loc -> !covered?(loc, sensor_locs) end)
    |> Enum.take(1)
    |> then(fn [{x, y}] -> x * 4_000_000 + y end)
  end

  def intersect_from_points({x1, y1}, {x2, y2}) do
    int1_x = div(x1 - y1 + (x2 + y2), 2)
    int1_y = int1_x + y1 - x1
    int2_x = div(x2 - y2 + (x1 + y1), 2)
    int2_y = int2_x + y2 - x2
    [{int1_x, int1_y}, {int2_x, int2_y}]
  end

  def solve2_slow do
    sensor_locs = sensor_locations()

    0..4_000_000
    |> Stream.map(fn i -> {i, covered_ranges(i, sensor_locs)} end)
    |> Stream.filter(fn {_, ranges} ->
      case ranges do
        [{a, b}] when a < 0 and b > 4_000_000 -> false
        _ -> true
      end
    end)
    |> Enum.take(1)
    |> then(fn [{y, [{_, x}, {_, _}]}] -> (x + 1) * 4_000_000 + y end)
  end
end
