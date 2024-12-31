defmodule AocEx.Aoc2016Ex.Day18 do
  use AocEx.Day, year: 2016, day: 18

  def next_row(s), do: next_row("." <> s <> ".", "")
  def next_row(<<"^^.", rest::binary>>, acc), do: next_row("^." <> rest, acc <> "^")
  def next_row(<<".^^", rest::binary>>, acc), do: next_row("^^" <> rest, acc <> "^")
  def next_row(<<"^..", rest::binary>>, acc), do: next_row(".." <> rest, acc <> "^")
  def next_row(<<"..^", rest::binary>>, acc), do: next_row(".^" <> rest, acc <> "^")
  def next_row(<<_, y, z, rest::binary>>, acc), do: next_row(<<y, z, rest::binary>>, acc <> ".")
  def next_row(<<_, _>>, acc), do: acc
  def count_safe(<<?., rest::binary>>, acc), do: count_safe(rest, acc + 1)
  def count_safe(<<_, rest::binary>>, acc), do: count_safe(rest, acc)
  def count_safe("", acc), do: acc

  def count_safe_in_rows(input, num_rows) do
    Enum.reduce(1..num_rows, {0, input}, fn _, {tot, s} ->
      {tot + count_safe(s, 0), next_row(s)}
    end)
    |> elem(0)
  end

  def solve1, do: count_safe_in_rows(input(), 40)
  def solve2, do: count_safe_in_rows(input(), 400_000)
end
