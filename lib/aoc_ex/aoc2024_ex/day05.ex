defmodule AocEx.Aoc2024Ex.Day05 do
  def input do
    AocEx.Day.input_file_contents(2024, 5)
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.split(&1, "\n", trim: true))
    # |> tap(fn [rules, updates] -> IO.inspect(updates) end)
    |> then(fn [rules, updates] ->
      [
        Enum.map(rules, fn rule ->
          String.split(rule, "|") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
        end)
        |> MapSet.new(),
        Enum.map(updates, fn u ->
          String.split(u, ",", trim: true) |> Enum.map(&String.to_integer/1)
        end)
      ]
    end)
  end

  def pairs(list), do: pairs(list, [])

  def pairs([n | rest = [_ | _]], acc) do
    acc =
      Enum.reduce(rest, acc, fn i, acc ->
        [{n, i} | acc]
      end)

    pairs(rest, acc)
  end

  def pairs([_], acc), do: acc

  def violations(%MapSet{} = rules, nums) do
    pairs(nums)
    |> Enum.filter(fn pair -> !MapSet.member?(rules, pair) end)
  end

  def fix(rules, nums) do
    viols = violations(rules, nums)

    case viols do
      [{a, b} | _] ->
        ia = Enum.find_index(nums, &(&1 == a))
        ib = Enum.find_index(nums, &(&1 == b))

        newnums =
          nums
          |> List.replace_at(ia, b)
          |> List.replace_at(ib, a)

        fix(rules, newnums)

      [] ->
        nums
    end
  end

  def solve1 do
    [rules, updates] = input()

    updates
    |> Enum.filter(fn u ->
      pp = pairs(u)
      Enum.all?(pp, fn pair -> MapSet.member?(rules, pair) end)
    end)
    |> Enum.map(fn res -> Enum.at(res, div(length(res) - 1, 2)) end)
    |> Enum.sum()
  end

  def solve2 do
    [rules, updates] = input()
    rules = MapSet.new(rules)

    updates
    |> Enum.map(fn u -> [u, violations(rules, u)] end)
    |> Enum.filter(fn [_, viols] -> !Enum.empty?(viols) end)
    |> Enum.map(fn [nums, _] -> nums end)
    |> Enum.map(fn nums -> fix(rules, nums) end)
    |> Enum.map(fn res -> Enum.at(res, div(length(res) - 1, 2)) end)
    |> Enum.sum()
  end
end
