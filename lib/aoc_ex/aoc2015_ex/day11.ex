defmodule AocEx.Aoc2015Ex.Day11 do
  use AocEx.Day, year: 2015, day: 11
  import Enum

  @input ~c'hepxcrrq'

  def incr(s), do: incr(reverse(s), [])
  def incr([?z | rest], acc), do: incr(rest, [?a | acc])
  def incr([c | rest], acc), do: reverse([c + 1 | rest]) ++ acc

  def has_straight?([a, b, c | _]) when b == a + 1 and c == b + 1, do: true
  def has_straight?([_ | rest]), do: has_straight?(rest)
  def has_straight?([]), do: false

  def has_iol?(s), do: any?(s, &(&1 in ~c'iol'))

  def has_pair?([c, c | rest]), do: {true, rest}
  def has_pair?([_ | rest]), do: has_pair?(rest)
  def has_pair?([]), do: false

  def has_two_pair?(s) do
    case has_pair?(s) do
      false -> false
      {true, rest} -> has_pair?(rest)
    end
  end

  def valid?(s), do: has_straight?(s) && !has_iol?(s) && has_two_pair?(s)

  def find_next_valid(word) do
    if valid?(word) do
      word
    else
      find_next_valid(incr(word))
    end
  end

  def solve1, do: find_next_valid(@input)
  def solve2, do: find_next_valid(incr(solve1()))
end
