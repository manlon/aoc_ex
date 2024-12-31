defmodule AocEx.Aoc2016Ex.Day16 do
  import Enum
  use AocEx.Day, year: 2016, day: 16

  @size 272
  @size2 35_651_584
  @input ~c"01111001100111011"

  def invert_reverse(s, acc \\ [])
  def invert_reverse([?0 | rest], acc), do: invert_reverse(rest, [?1 | acc])
  def invert_reverse([?1 | rest], acc), do: invert_reverse(rest, [?0 | acc])
  def invert_reverse([], acc), do: acc

  def fill(data, size \\ @size)
  def fill(data, size) when length(data) >= size, do: data
  def fill(data, size), do: fill(data ++ ~c'0' ++ invert_reverse(data), size)

  def checksum(data) when rem(length(data), 2) == 1, do: data
  def checksum(data), do: checksum(data, [])
  def checksum([c, c | rest], acc), do: checksum(rest, [?1 | acc])
  def checksum([_, _ | rest], acc), do: checksum(rest, [?0 | acc])
  def checksum([], acc), do: checksum(reverse(acc))

  def solve1 do
    fill(@input)
    |> Enum.slice(0..(@size - 1))
    |> checksum()
  end

  def solve2 do
    fill(@input, @size2)
    |> Enum.slice(0..(@size2 - 1))
    |> checksum()
  end
end
