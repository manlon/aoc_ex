defmodule AocEx.Aoc2019Ex.Day03 do
  def input do
    AocEx.Day.input_file_contents(2019, 3)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ",", trim: true))
  end

  def part1 do
    [w1, w2] =
      input()
      |> Enum.map(&wire_points/1)
      |> Enum.map(&MapSet.new/1)

    MapSet.intersection(w1, w2)
    |> Enum.map(fn {x, y} -> abs(x) + abs(y) end)
    |> Enum.min()
  end

  def part2 do
    [w1, w2] =
      input()
      |> Enum.map(&wire_points/1)

    [s1, s2] =
      [w1, w2]
      |> Enum.map(&MapSet.new/1)

    ints = MapSet.intersection(s1, s2)

    _p1 =
      ints
      |> Enum.map(fn {x, y} -> abs(x) + abs(y) end)
      |> Enum.min()

    p2 =
      ints
      |> Enum.map(fn pos ->
        Enum.find_index(w1, &(&1 == pos)) + Enum.find_index(w2, &(&1 == pos)) + 2
      end)
      |> Enum.min()

    p2
  end

  def go3 do
    [w1, w2] =
      input()
      |> Enum.map(&wire_points_map/1)

    ints = intersection(w1, w2)

    p1 =
      ints
      |> Enum.map(fn {x, y} -> abs(x) + abs(y) end)
      |> Enum.min()

    p2 =
      ints
      |> Enum.map(fn pos -> w1[pos] + w2[pos] end)
      |> Enum.min()

    {p1, p2}
  end

  def intersection(map1, map2) do
    Map.take(map1, Map.keys(map2))
    |> Map.keys()
  end

  def wire_points_map(description) do
    _points = wire_points_map(description, {0, 0}, 0, %{})
  end

  def wire_points_map([], _, _, map), do: map

  def wire_points_map([segment | rest], pos, dist, acc) do
    <<dir::binary-size(1)>> <> steps = segment
    steps = String.to_integer(steps)
    {pos, dist, acc} = append_segment_map(dir, steps, pos, dist, acc)
    wire_points_map(rest, pos, dist, acc)
  end

  def append_segment_map(_dir, 0, pos, dist, acc), do: {pos, dist, acc}

  def append_segment_map(dir, steps, _pos = {x, y}, dist, map) do
    {dx, dy} =
      case dir do
        "U" ->
          {0, 1}

        "D" ->
          {0, -1}

        "L" ->
          {-1, 0}

        "R" ->
          {1, 0}
      end

    new_pos = {x + dx, y + dy}
    dist = dist + 1

    map =
      if Map.has_key?(map, new_pos) do
        map
      else
        Map.put(map, new_pos, dist)
      end

    append_segment_map(dir, steps - 1, new_pos, dist, map)
  end

  def wire_points(description) do
    wire_points(description, {0, 0}, [])
  end

  def wire_points([], _, acc), do: Enum.reverse(acc)

  def wire_points([segment | rest], pos, acc) do
    <<dir::binary-size(1)>> <> steps = segment
    steps = String.to_integer(steps)
    {pos, acc} = append_segment(dir, steps, pos, acc)
    wire_points(rest, pos, acc)
  end

  def append_segment(_dir, 0, pos, acc), do: {pos, acc}

  def append_segment(dir, steps, _pos = {x, y}, acc) do
    {dx, dy} =
      case dir do
        "U" ->
          {0, 1}

        "D" ->
          {0, -1}

        "L" ->
          {-1, 0}

        "R" ->
          {1, 0}
      end

    new_pos = {x + dx, y + dy}
    append_segment(dir, steps - 1, new_pos, [new_pos | acc])
  end
end
