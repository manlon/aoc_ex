defmodule AocEx.Aoc2015Ex.Day05 do
  use AocEx.Day, year: 2015, day: 5
  @vowels ["a", "e", "i", "o", "u"]
  @bad ["ab", "cd", "pq", "xy"]

  def nice?(s) do
    letters = String.graphemes(s)

    length(Enum.filter(letters, fn l -> l in @vowels end)) >= 3 and
      Enum.any?(Enum.chunk_every(letters, 2, 1, :discard), fn [a, b] -> a == b end) and
      !Enum.any?(@bad, fn b -> String.contains?(s, b) end)
  end

  def nice2?(s) do
    letters = String.graphemes(s)

    has_double_pair?(s) and
      Enum.any?(Enum.chunk_every(letters, 3, 1, :discard), fn [a, _b, c] -> a == c end)
  end

  def has_double_pair?(<<a::binary-size(1), b::binary-size(1), rest::binary>>) do
    String.contains?(rest, <<a::binary, b::binary>>) or
      has_double_pair?(<<b::binary, rest::binary>>)
  end

  def has_double_pair?(_), do: false

  def solve1 do
    input_lines()
    |> Enum.count(&nice?/1)
  end

  def solve2 do
    input_lines()
    |> Enum.count(&nice2?/1)
  end
end
