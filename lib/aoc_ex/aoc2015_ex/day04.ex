defmodule AocEx.Aoc2015Ex.Day04 do
  use AocEx.Day, year: 2015, day: 4

  @input "iwrupvqb"

  def md5_hex_zeros?(x, digits) do
    case :erlang.md5("#{@input}#{x}") do
      <<0::size(digits * 4), _::bitstring>> -> true
      _ -> false
    end
  end

  def find_hit(digits \\ 5) do
    Stream.iterate(1, &(&1 + 1))
    |> Stream.drop_while(&(!md5_hex_zeros?(&1, digits)))
    |> Enum.take(1)
    |> hd()
  end

  def solve1, do: find_hit()
  def solve2, do: find_hit(6)
end
