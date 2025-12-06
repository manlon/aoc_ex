defmodule AocEx.Aoc2025Ex.Day05 do
  use AocEx.Day, day: 5, year: 2025

  def parsed_input do
    [ranges, items] = stanza_lines()

    ranges =
      for range_spec <- ranges,
          [first, last] = String.split(range_spec, "-"),
          first = String.to_integer(first),
          last = String.to_integer(last) do
        first..last
      end

    items = Enum.map(items, &String.to_integer/1)
    {ranges, items}
  end

  def combine([s1..e1//1, s2..e2//1 | rest], acc) when e1 >= s2 - 1 do
    combine([s1..max(e1, e2) | rest], acc)
  end

  def combine([r | ranges], acc) do
    combine(ranges, [r | acc])
  end

  def combine([], acc) do
    Enum.reverse(acc)
  end

  def solve1() do
    {ranges, items} = parsed_input()
    Enum.count(items, fn i -> Enum.any?(ranges, &(i in &1)) end)
  end

  def solve2() do
    {ranges, _items} = parsed_input()
    ranges = Enum.sort(ranges) |> combine([])

    for s..e//1 <- ranges, reduce: 0 do
      x -> x + e - s + 1
    end
  end
end
