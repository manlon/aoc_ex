defmodule AocEx.Aoc2023Ex.Day01 do
  use AocEx.Day, day: 1

  def solve1 do
    input_lines()
    |> Enum.map(&collect_ints/1)
    |> Enum.map(&ints_to_num/1)
    |> Enum.sum()
  end

  def solve2 do
    input_lines()
    |> Enum.map(&collect_ints_spelled/1)
    |> Enum.map(&ints_to_num/1)
    |> Enum.sum()
  end

  def collect_ints(s, acc \\ [])
  def collect_ints("", acc), do: Enum.reverse(acc)

  def collect_ints(<<b, rest::binary>>, acc) when b in ?0..?9 do
    collect_ints(rest, [b - ?0 | acc])
  end

  def collect_ints(<<_b, rest::binary>>, acc), do: collect_ints(rest, acc)

  def collect_ints_spelled(s, acc \\ [])
  def collect_ints_spelled(s, [a, _, c]), do: collect_ints_spelled(s, [a, c])
  def collect_ints_spelled("", acc), do: Enum.reverse(acc)

  def collect_ints_spelled(<<b, rest::binary>>, acc) when b in ?0..?9 do
    collect_ints_spelled(rest, [b - ?0 | acc])
  end

  def collect_ints_spelled(<<"one", rest::binary>>, acc),
    do: collect_ints_spelled("ne" <> rest, [1 | acc])

  def collect_ints_spelled(<<"two", rest::binary>>, acc),
    do: collect_ints_spelled("wo" <> rest, [2 | acc])

  def collect_ints_spelled(<<"three", rest::binary>>, acc),
    do: collect_ints_spelled("hree" <> rest, [3 | acc])

  def collect_ints_spelled(<<"four", rest::binary>>, acc),
    do: collect_ints_spelled("our" <> rest, [4 | acc])

  def collect_ints_spelled(<<"five", rest::binary>>, acc),
    do: collect_ints_spelled("ive" <> rest, [5 | acc])

  def collect_ints_spelled(<<"six", rest::binary>>, acc),
    do: collect_ints_spelled("ix" <> rest, [6 | acc])

  def collect_ints_spelled(<<"seven", rest::binary>>, acc),
    do: collect_ints_spelled("even" <> rest, [7 | acc])

  def collect_ints_spelled(<<"eight", rest::binary>>, acc),
    do: collect_ints_spelled("ight" <> rest, [8 | acc])

  def collect_ints_spelled(<<"nine", rest::binary>>, acc),
    do: collect_ints_spelled("ine" <> rest, [9 | acc])

  def collect_ints_spelled(<<_b, rest::binary>>, acc), do: collect_ints_spelled(rest, acc)

  def ints_to_num(ints) do
    10 * hd(ints) + Enum.at(ints, -1)
  end

  def test_input do
    """
    1abc2
    pqr3stu8vwx
    a1b2c3d4e5f
    treb7uchet
    """
  end

  def test_input_2 do
    """
    two1nine
    eightwothree
    abcone2threexyz
    xtwone3four
    4nineeightseven2
    zoneight234
    7pqrstsixteen
    """
  end
end
