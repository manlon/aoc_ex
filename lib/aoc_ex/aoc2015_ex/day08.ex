defmodule AocEx.Aoc2015Ex.Day08 do
  use AocEx.Day, year: 2015, day: 8

  def dec_length(<<"\"", s::binary>>), do: dec_length(s, 0)
  def dec_length(<<"\\\\", rest::binary>>, acc), do: dec_length(rest, acc + 1)
  def dec_length(<<"\\\"", rest::binary>>, acc), do: dec_length(rest, acc + 1)
  def dec_length(<<"\\x", _, _, rest::binary>>, acc), do: dec_length(rest, acc + 1)
  def dec_length("\"", acc), do: acc
  def dec_length(<<_, rest::binary>>, acc), do: dec_length(rest, acc + 1)

  def enc_length(s), do: enc_length(s, 1)
  def enc_length("", acc), do: acc + 1
  def enc_length(<<"\"", rest::binary>>, acc), do: enc_length(rest, acc + 2)
  def enc_length(<<"\\", rest::binary>>, acc), do: enc_length(rest, acc + 2)
  def enc_length(<<_, rest::binary>>, acc), do: enc_length(rest, acc + 1)

  def parsed_input() do
    for line <- input_lines(), do: {String.length(line), dec_length(line), enc_length(line)}
  end

  def solve1 do
    for {l, d, _} <- parsed_input(), reduce: 0 do
      x -> x + (l - d)
    end
  end

  def solve2 do
    for {l, _, e} <- parsed_input(), reduce: 0 do
      x -> x + (e - l)
    end
  end
end
