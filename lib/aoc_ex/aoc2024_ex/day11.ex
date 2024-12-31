defmodule AocEx.Aoc2024Ex.Day11 do
  def input do
    AocEx.Day.input_file_contents(2024, 11)
    |> String.trim()
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  def count_blink([], memo, acc), do: {acc, memo}

  def count_blink([stone | rest], memo = %{}, acc) when is_map_key(memo, stone) do
    result = Map.get(memo, stone)
    count_blink(rest, memo, acc + result)
  end

  def count_blink([stone = {_num, _iters} | rest], memo = %{}, acc) do
    {n, memo} =
      case stone do
        {_n, 0} ->
          {1, memo}

        {0, i} ->
          count_blink([{1, i - 1}], memo, 0)

        {n, i} ->
          digits = Integer.digits(n)
          len = length(digits)

          if rem(len, 2) == 0 do
            numdig = div(len, 2)

            [left, right] =
              [Enum.take(digits, numdig), Enum.drop(digits, numdig)]
              |> Enum.map(&Integer.undigits/1)

            count_blink([{left, i - 1}, {right, i - 1}], memo, 0)
          else
            count_blink([{n * 2024, i - 1}], memo, 0)
          end
      end

    memo = Map.put(memo, stone, n)
    count_blink(rest, memo, acc + n)
  end

  def do_blinks(n) do
    input()
    |> Enum.map(fn i -> {i, n} end)
    |> count_blink(%{}, 0)
    |> elem(0)
  end

  def solve1, do: do_blinks(25)
  def solve2, do: do_blinks(75)
end
