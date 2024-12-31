defmodule AocEx.Aoc2016Ex.Day15 do
  use AocEx.Day, year: 2016, day: 15
  import Enum

  def parsed_input do
    for [disc, n, 0, pos] <- input_line_ints() do
      {disc, n, pos}
    end
  end

  def find_chinese_remainder(rem_modulus_pairs) do
    [{start, jump} | rest] = sort_by(rem_modulus_pairs, &elem(&1, 1), :desc)
    big_mod = product(map(rem_modulus_pairs, &elem(&1, 1)))

    find(start..big_mod//jump, fn i ->
      all?(rest, fn {r, m} -> rem(i, m) == r end)
    end)
  end

  def fix(positions) do
    for {pos, mod, cur} <- positions do
      rem = mod - (pos + cur)
      rem = if rem < 0, do: rem + mod, else: rem
      {rem, mod}
    end
  end

  def solve1 do
    fix(parsed_input()) |> find_chinese_remainder()
  end

  def solve2 do
    fix(parsed_input() ++ [{7, 11, 0}]) |> find_chinese_remainder()
  end
end
