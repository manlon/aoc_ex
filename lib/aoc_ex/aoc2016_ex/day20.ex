defmodule AocEx.Aoc2016Ex.Day20 do
  use AocEx.Day, year: 2016, day: 20
  import String, only: [to_integer: 1, split: 2]
  import Enum, only: [sort: 1, reverse: 1]

  def parsed_input do
    for line <- input_lines(),
        [a, b] = split(line, "-") do
      {to_integer(a), to_integer(b)}
    end
    |> sort()
  end

  def combine([i], acc), do: reverse(acc) ++ [i]

  def combine([{a, b}, {c, d} | rest], acc) when c >= a and c <= b,
    do: combine([{a, max(b, d)} | rest], acc)

  def combine([{a, b}, {c, d} | rest], acc) when c == b + 1,
    do: combine([{a, d} | rest], acc)

  def combine([{a, b}, {c, d} | rest], acc),
    do: combine([{c, d} | rest], [{a, b} | acc])

  def add_gaps([{_, 4_294_967_295}], acc), do: acc

  def add_gaps([{_, b}, {c, d} | rest], acc) do
    add_gaps([{c, d} | rest], acc + (c - b - 1))
  end

  def solve1 do
    {_, first_max} = hd(combine(parsed_input(), []))
    first_max + 1
  end

  def solve2 do
    combine(parsed_input(), [])
    |> add_gaps(0)
  end
end
