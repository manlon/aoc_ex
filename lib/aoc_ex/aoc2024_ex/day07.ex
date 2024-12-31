defmodule AocEx.Aoc2024Ex.Day07 do
  def input do
    AocEx.Day.input_file_contents(2024, 7)
  end

  def input_lines(input \\ nil) do
    (input || input())
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> String.split(line, ": ") end)
    |> Enum.map(fn [target, nums] ->
      nums = Enum.map(String.split(nums, " "), &String.to_integer/1)
      {String.to_integer(target), nums}
    end)
  end

  def can_satisfy?(target, nums, allow_concat?, acc \\ [])

  def can_satisfy?(target, _, _, _) when target < 0, do: false
  def can_satisfy?(n, [n], _, acc), do: acc
  def can_satisfy?(_, [_], _, _), do: false

  def can_satisfy?(target, [n | rest], allow_concat?, acc) do
    can_satisfy_add?(target, n, rest, allow_concat?, acc) ||
      can_satisfy_mult?(target, n, rest, allow_concat?, acc) ||
      (allow_concat? && can_satisfy_concat?(target, n, rest, acc))
  end

  def can_satisfy_add?(target, n, rest, allow_concat?, acc) do
    can_satisfy?(target - n, rest, allow_concat?, [:add | acc])
  end

  def can_satisfy_mult?(target, n, rest, allow_concat?, acc) do
    if rem(target, n) == 0 do
      can_satisfy?(div(target, n), rest, allow_concat?, [:mult | acc])
    else
      false
    end
  end

  def can_satisfy_concat?(target, n, rest, acc) do
    pten = next_pow_10(n)

    if rem(target, pten) == n do
      can_satisfy?(div(target, pten), rest, true, [:concat | acc])
    else
      false
    end
  end

  def next_pow_10(n, acc \\ 1)
  def next_pow_10(0, acc), do: acc
  def next_pow_10(n, acc), do: next_pow_10(div(n, 10), acc * 10)

  def sum_satisfiable(allow_concat?) do
    input_lines()
    |> Enum.filter(fn {target, nums} ->
      can_satisfy?(target, Enum.reverse(nums), allow_concat?)
    end)
    |> Enum.map(fn {target, _} -> target end)
    |> Enum.sum()
  end

  def solve1, do: sum_satisfiable(false)
  def solve2, do: sum_satisfiable(true)
end
