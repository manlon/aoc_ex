defmodule AocEx.Aoc2022Ex.Day25 do
  use AocEx.Day, year: 2022, day: 25

  def snafu_to_d(s) when is_binary(s) do
    String.to_charlist(s)
    |> snafu_to_d()
  end

  def snafu_to_d(chars, acc \\ 0)
  def snafu_to_d([], acc), do: acc

  def snafu_to_d([c | rest], acc) do
    digit =
      case c do
        ?0 -> 0
        ?1 -> 1
        ?2 -> 2
        ?- -> -1
        ?= -> -2
      end

    snafu_to_d(rest, acc * 5 + digit)
  end

  def d_to_snafu(d, acc \\ [])

  def d_to_snafu(0, acc), do: acc

  def d_to_snafu(d, acc) do
    dig = rem(d, 5)
    rest = div(d - dig, 5)

    {char, carry} =
      case dig do
        0 -> {?0, 0}
        1 -> {?1, 0}
        2 -> {?2, 0}
        3 -> {?=, 1}
        4 -> {?-, 1}
      end

    d_to_snafu(rest + carry, [char | acc])
  end

  def solve1 do
    input_lines()
    |> Enum.map(&snafu_to_d/1)
    |> Enum.sum()
    |> d_to_snafu()
  end

  def solve2 do
    :ok
  end
end
