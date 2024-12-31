defmodule AocEx.Aoc2023Ex.Day12 do
  use AocEx.Day, day: 12

  @spring "#"
  @space "."
  @unknown "?"

  defmodule Parser do
    alias AocEx.Aoc2023Ex.Day12
    use AocEx.Parser
    item = ascii_string([??, ?#, ?.], 1)
    int_list = wrap(int() |> repeat(concat(istr(","), int())))
    line = wrap(times(item, min: 1)) |> ispace() |> concat(int_list)
    defmatch(:parse_line, line)

    def parsed do
      Day12.input_lines() |> Enum.map(&parse_line/1)
    end
  end

  def unfold(line, groups) do
    unfolded_line =
      List.duplicate(line, 5)
      |> Enum.intersperse(@unknown)
      |> List.flatten()

    unfolded_groups = List.duplicate(groups, 5) |> List.flatten()
    {unfolded_line, unfolded_groups}
  end

  def solve1 do
    for [line, groups] <- Parser.parsed() do
      count_sols(line, groups)
    end
    |> Enum.sum()
  end

  def solve2 do
    for [line, groups] <- Parser.parsed(),
        {unfold_line, unfold_groups} = unfold(line, groups) do
      count_sols(unfold_line, unfold_groups)
    end
    |> Enum.sum()
  end

  def count_sols(line, groups) do
    {c, _} = count_sols(line, groups, %{})
    c
  end

  def count_sols(_line = [], _groups = [], memo), do: {1, memo}
  def count_sols(_line = [], _groups, memo), do: {0, memo}
  def count_sols([@spring | _rest], [], memo), do: {0, memo}
  def count_sols([_ | rest], [], memo), do: count_sols(rest, [], memo)
  def count_sols([@space | rest], groups, memo), do: count_sols(rest, groups, memo)

  def count_sols(line = [x | rest], groups = [g | restgroups], memo) do
    group_sum = Enum.sum(groups)
    min_slots_remaining = group_sum + length(groups) - 1

    cond do
      Map.has_key?(memo, {line, groups}) ->
        {Map.get(memo, {line, groups}), memo}

      length(line) < min_slots_remaining ->
        {0, memo}

      x == @spring ->
        potential_group = Enum.take(line, g)
        rest_of_line = Enum.drop(line, g)

        if Enum.all?(potential_group, fn x -> x == @spring || x == @unknown end) &&
             (rest_of_line == [] || hd(rest_of_line) in [@unknown, @space]) do
          rest_of_line = Enum.drop(rest_of_line, 1)
          count_sols(rest_of_line, restgroups, memo)
        else
          {0, memo}
        end

      x == @unknown ->
        {comp_no_group, memo} = count_sols(rest, groups, memo)

        {comp_with_group, memo} =
          count_sols([@spring | rest], groups, memo)

        v = comp_no_group + comp_with_group
        memo = Map.put(memo, {line, groups}, v)
        {v, memo}
    end
  end
end
