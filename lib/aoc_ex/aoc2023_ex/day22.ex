defmodule AocEx.Aoc2023Ex.Day22 do
  use AocEx.Day, year: 2023, day: 22

  defmodule Parser do
    alias AocEx.Aoc2023Ex.Day22
    use AocEx.Parser
    brick = int() |> istr(",") |> int() |> istr(",") |> int()
    line = wrap(brick) |> istr("~") |> wrap(brick)
    defmatch(:parse_line, line)

    def parsed_input do
      Day22.input_lines()
      |> Enum.map(&parse_line/1)
      |> Enum.map(&Enum.map(&1, fn x -> List.to_tuple(x) end))
      |> Enum.map(&List.to_tuple/1)
    end
  end

  def downone(_brick = {{rx, ry, _rz = minz..maxz//1}, id}) do
    {{rx, ry, (minz - 1)..(maxz - 1)}, id}
  end

  def base(_brick = {{_xr, _yr, _zr = minz.._maxz//1}, _}), do: minz

  def intersect_at_base?(brick, bricks) do
    z = base(brick)
    {{bx, by, _bz}, _} = brick

    Enum.any?(bricks, fn _b = {{o_x, o_y, o_z}, _} ->
      z in o_z && !(Range.disjoint?(bx, o_x) || Range.disjoint?(by, o_y))
    end)
  end

  def fall(bricks), do: fall(bricks, [])

  def fall([brick = {{_, _, minz.._//1}, _} | rest], acc) when minz <= 1 do
    fall(rest, [brick | acc])
  end

  def fall([brick | rest], acc) do
    fallen = downone(brick)
    blocked? = intersect_at_base?(fallen, rest) || intersect_at_base?(fallen, acc)

    if blocked? do
      fall(rest, [brick | acc])
    else
      {true, [fallen | rest] ++ acc}
    end
  end

  def fall([], acc) do
    {false, Enum.reverse(acc)}
  end

  def settle(bricks) do
    case fall(bricks) do
      {true, new_bricks} -> settle(new_bricks)
      {false, new_bricks} -> new_bricks
    end
  end

  def brick_ranges do
    Enum.map(Parser.parsed_input(), fn {{x1, y1, z1}, {x2, y2, z2}} ->
      {x1..x2, y1..y2, z1..z2}
    end)
    |> Enum.with_index()
  end

  def safe_disint do
    bricks = settle(brick_ranges())

    for i <- 0..(length(bricks) - 1),
        reduce: [] do
      acc ->
        brick = Enum.at(bricks, i)
        bricks = List.delete_at(bricks, i)

        case fall(bricks) do
          {true, _} -> acc
          {false, _} -> [brick | acc]
        end
    end
  end

  def disint_count do
    bricks = settle(brick_ranges())

    dbg(:settled)

    bricks_idx = Enum.with_index(bricks)

    Task.async_stream(
      bricks_idx,
      fn {brick, _i} ->
        remain_bricks = List.delete(bricks, brick)
        settled = settle(remain_bricks)
        moved = length(remain_bricks -- settled)
        moved
      end,
      ordered: false
    )
    |> Enum.map(fn {:ok, v} -> v end)
  end

  def solve1 do
    safe_disint() |> length()
  end

  def solve2 do
    disint_count() |> Enum.sum()
  end
end
