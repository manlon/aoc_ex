defmodule AocEx.Aoc2022Ex.Day20 do
  use AocEx.Day, year: 2022, day: 20

  def solve1 do
    inp = Enum.with_index(input_ints())
    len = length(inp)

    moved =
      move_all(inp, len)
      |> Enum.map(&elem(&1, 0))

    idx = Enum.find_index(moved, fn x -> x == 0 end)

    Enum.map([1000, 2000, 3000], fn i -> rem(i + idx, len) end)
    |> Enum.map(fn i -> Enum.at(moved, i) end)
    |> Enum.sum()
  end

  def solve2 do
    inp =
      input_ints()
      |> Enum.map(fn i -> i * 811_589_153 end)
      |> Enum.with_index()

    len = length(inp)

    moved =
      Enum.reduce(1..10, inp, fn _, inp ->
        move_all(inp, len)
      end)
      |> Enum.map(&elem(&1, 0))

    idx = Enum.find_index(moved, fn x -> x == 0 end)

    Enum.map([1000, 2000, 3000], fn i -> rem(i + idx, len) end)
    |> Enum.map(fn i -> Enum.at(moved, i) end)
    |> Enum.sum()
  end

  def move_all(list, len) do
    Enum.reduce(0..(len - 1), list, fn i, acc ->
      find_and_move(acc, i, [], len)
    end)
  end

  def move(item, n, tails, prevs, len) when n > len or n < -len do
    n = rem(n, len - 1)
    move(item, n, tails, prevs, len)
  end

  def move(item, n, [], prev, len) when n > 0 do
    move(item, n, Enum.reverse(prev), [], len)
  end

  def move(item, n, [t | tail], prev, len) when n > 0 do
    move(item, n - 1, tail, [t | prev], len)
  end

  def move(item, n, tail, [], len) when n <= 0 do
    move(item, n, [], Enum.reverse(tail), len)
  end

  def move(item, n, tail, [p | prev], len) when n < 0 do
    move(item, n + 1, [p | tail], prev, len)
  end

  def move(item, 0, tail, prev, _len) do
    Enum.reverse(prev) ++ [item | tail]
  end

  def find_and_move([{n, i} | rest], i, acc, len) do
    move({n, i}, n, rest, acc, len)
  end

  def find_and_move([x | rest], i, acc, len) do
    find_and_move(rest, i, [x | acc], len)
  end
end
