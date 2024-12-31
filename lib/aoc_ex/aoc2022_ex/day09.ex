defmodule AocEx.Aoc2022Ex.Day09 do
  use AocEx.Day, year: 2022, day: 9

  def moves do
    for line <- input_lines() do
      [dir, num] = String.split(line)
      {dir, String.to_integer(num)}
    end
  end

  def solve1(n \\ 2), do: process_moves(moves(), List.duplicate({0, 0}, n), MapSet.new([{0, 0}]))
  def solve2, do: solve1(10)

  def process_moves([], _, visited), do: Enum.count(visited)
  def process_moves([{_, 0} | rest], knots, visited), do: process_moves(rest, knots, visited)

  def process_moves([{dir, n} | rest], _knots = [head | tail], visited) do
    head = move(head, {dir, 1})

    knots =
      [last | _] =
      Enum.reduce(tail, [head], fn knot, acc = [prev | _] ->
        [follow(prev, knot) | acc]
      end)

    visited = MapSet.put(visited, last)
    process_moves([{dir, n - 1} | rest], Enum.reverse(knots), visited)
  end

  def follow({rh, ch}, {rt, ct})
      when rt in (rh - 1)..(rh + 1)//1 and ct in (ch - 1)..(ch + 1)//1 do
    {rt, ct}
  end

  def follow({rh, ch}, {rt, ch}) when rh == rt + 2, do: {rt + 1, ch}
  def follow({rh, ch}, {rt, ch}) when rh == rt - 2, do: {rt - 1, ch}
  def follow({rh, ch}, {rh, ct}) when ch == ct + 2, do: {rh, ct + 1}
  def follow({rh, ch}, {rh, ct}) when ch == ct - 2, do: {rh, ct - 1}

  def follow({rh, ch}, {rt, ct}) do
    dr = if rh > rt, do: 1, else: -1
    dc = if ch > ct, do: 1, else: -1
    {rt + dr, ct + dc}
  end

  def move({r, c}, {"R", n}), do: {r, c + n}
  def move({r, c}, {"L", n}), do: {r, c - n}
  def move({r, c}, {"U", n}), do: {r + n, c}
  def move({r, c}, {"D", n}), do: {r - n, c}
end
