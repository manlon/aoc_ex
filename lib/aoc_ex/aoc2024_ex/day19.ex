defmodule AocEx.Aoc2024Ex.Day19 do
  def input do
    AocEx.Day.input_file_contents(2024, 19)
    |> String.split("\n\n", trim: true)
    |> then(fn [pats, targets] -> {parse_patterns(pats), parse_targets(targets)} end)
  end

  def parse_patterns(pats) do
    String.split(pats, ", ", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  def parse_targets(targets) do
    String.split(targets, "\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  def find_arrangements(target, patterns, memo) do
    if Map.has_key?(memo, target) do
      {Map.get(memo, target), memo}
    else
      pats = Enum.filter(patterns, fn p -> List.starts_with?(target, p) end)

      {num, memo} =
        Enum.reduce(pats, {0, memo}, fn pat, {acc, memo} ->
          new_target = Enum.drop(target, length(pat))
          {v, memo} = find_arrangements(new_target, patterns, memo)
          {acc + v, memo}
        end)

      {num, Map.put(memo, target, num)}
    end
  end

  def solve1 do
    {pats, targets} = input()

    {num, _} =
      Enum.reduce(targets, {0, %{[] => 1}}, fn target, {acc, memo} ->
        {v, memo} = find_arrangements(target, pats, memo)
        {acc + if(v > 0, do: 1, else: 0), memo}
      end)

    num
  end

  def solve2 do
    {pats, targets} = input()

    {num, _} =
      Enum.reduce(targets, {0, %{[] => 1}}, fn target, {acc, memo} ->
        {v, memo} = find_arrangements(target, pats, memo)
        {v + acc, memo}
      end)

    num
  end
end
