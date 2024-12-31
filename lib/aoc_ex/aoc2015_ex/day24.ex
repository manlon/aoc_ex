defmodule AocEx.Aoc2015Ex.Day24 do
  use AocEx.Day, year: 2015, day: 24

  def sets(nums, target), do: sets(nums, [], target)

  # TODO: perf
  def sets(nums, cur, target) do
    Stream.concat(
      Stream.unfold(nums, fn
        [] ->
          nil

        [num | rest] ->
          cur = [num | cur]
          sum = Enum.sum(cur)

          cond do
            sum > target ->
              {[], rest}

            sum == target ->
              {[cur], rest}

            true ->
              {sets(rest, cur, target), rest}
          end
      end)
    )
  end

  def find_best(nums, num_partitions) do
    total = Enum.sum(nums)
    target = div(total, num_partitions)

    {_, small_groups} =
      Enum.reduce(sets(nums, target), {:infinity, []}, fn part, {min, parts} ->
        len = length(part)

        cond do
          len < min -> {len, [part]}
          len == min -> {len, [part | parts]}
          true -> {min, parts}
        end
      end)

    for(group <- small_groups, do: Enum.product(group))
    |> Enum.min()
  end

  def solve1, do: find_best(input_ints(), 3)
  def solve2, do: find_best(input_ints(), 4)
end
