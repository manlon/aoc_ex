defmodule AocEx.Aoc2015Ex.Day01 do
  use AocEx.Day, year: 2015, day: 1

  def count(s), do: count(s, 0)
  def count(<<"(">> <> rest, n), do: count(rest, n + 1)
  def count(<<")">> <> rest, n), do: count(rest, n - 1)
  def count("", n), do: n

  def find(s, target), do: find(s, target, 0, 0)
  def find(_s, target, n, target), do: n
  def find(<<"(">> <> rest, target, n, cur), do: find(rest, target, n + 1, cur + 1)
  def find(<<")">> <> rest, target, n, cur), do: find(rest, target, n + 1, cur - 1)

  def solve1 do
    count(input())
  end

  def solve2 do
    find(input(), -1)
  end
end
