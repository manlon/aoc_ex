defmodule AocEx.Aoc2025Ex.Day02 do
  use AocEx.Day, day: 2, year: 2025

  def parsed_input do
    input()
    |> String.split(",")
    |> Enum.map(fn s -> String.split(s, "-") |> Enum.map(&String.to_integer/1) end)
    |> Enum.sort()
  end

  def repeat_digits(num, n) do
    Integer.digits(num)
    |> List.duplicate(n)
    |> Enum.concat()
    |> Integer.undigits()
  end

  def all_repeats_in_range(range = [_lo, hi]) do
    num_digits = Integer.digits(hi) |> Enum.count()

    Stream.flat_map(1..num_digits, fn i -> repeats_in_range(range, i) end)
    |> Stream.uniq()
  end

  def repeats_in_range(_range = [lo, hi], size) when lo <= hi do
    num_digits = Integer.digits(lo) |> Enum.count()

    this_oom =
      if size < num_digits and rem(num_digits, size) == 0 do
        top_digits = Integer.digits(lo) |> Enum.take(size) |> Integer.undigits()
        num_groups = div(num_digits, size)

        first_base =
          if repeat_digits(top_digits, num_groups) >= lo do
            top_digits
          else
            top_digits + 1
          end

        Stream.unfold(first_base, fn i ->
          repeated = repeat_digits(i, num_groups)

          if repeated > hi do
            nil
          else
            {repeated, i + 1}
          end
        end)
      else
        []
      end

    next_oom = repeats_in_range([10 ** num_digits, hi], size)
    Stream.concat(this_oom, next_oom)
  end

  def repeats_in_range(_, _), do: []

  def doubles_in_range(_range = [lo, hi]) when lo <= hi do
    num_digits = Integer.digits(lo) |> Enum.count()
    is_even? = rem(num_digits, 2) == 0
    half_size = div(num_digits, 2)

    this_oom =
      if is_even? do
        limit = min(hi, 10 ** num_digits - 1)
        repeats_in_range([lo, limit], half_size)
      else
        []
      end

    next_oom = doubles_in_range([10 ** num_digits, hi])
    Stream.concat(this_oom, next_oom)
  end

  def doubles_in_range(_), do: []

  def solve1() do
    parsed_input()
    |> Stream.flat_map(&doubles_in_range/1)
    |> Enum.sum()
  end

  def solve2() do
    parsed_input()
    |> Stream.flat_map(&all_repeats_in_range/1)
    |> Enum.sum()
  end
end
