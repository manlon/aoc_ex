defmodule AocEx.Aoc2023Ex.Day19 do
  use AocEx.Day, day: 19

  defmodule Parser do
    use AocEx.Parser

    op = choice([string("<"), string(">")])
    val = choice([string("x"), string("m"), string("a"), string("s")])
    workflow_name = ascii_string([?a..?z], min: 1)
    end_state = choice([string("A"), string("R")])

    test =
      wrap(
        val
        |> concat(op)
        |> int()
        |> istr(":")
        |> choice([end_state, workflow_name])
        |> istr(",")
      )

    workflow =
      workflow_name
      |> istr("{")
      |> wrap(times(test, min: 1))
      |> choice([end_state, workflow_name])
      |> istr("}")

    defmatch(:parse_workflow, workflow)

    part =
      istr("{x=")
      |> int()
      |> istr(",m=")
      |> int()
      |> istr(",a=")
      |> int()
      |> istr(",s=")
      |> int()
      |> istr("}")

    defmatch(:parse_part, part)

    def parsed_input(inp \\ nil) do
      [flows, parts] = inp || Aoc2023Ex.Day19.stanza_lines()

      flows =
        for flow <- flows, into: %{} do
          [name, rules, fallback] = parse_workflow(flow)
          {name, %{rules: rules, fallback: fallback}}
        end

      parts =
        for part <- parts do
          [x, m, a, s] = parse_part(part)
          %{"x" => x, "m" => m, "a" => a, "s" => s}
        end

      {flows, parts}
    end
  end

  @ends ["A", "R"]

  def do_workflow(workflows, workflow_name, part) do
    %{rules: rules, fallback: fallback} = workflows[workflow_name]
    result = Enum.find_value(rules, fallback, &rule_applies?(&1, part))
    if result in @ends, do: result, else: do_workflow(workflows, result, part)
  end

  def rule_applies?([valname, op, val, result], part) do
    partval = part[valname]

    hit? =
      case op do
        "<" -> partval < val
        ">" -> partval > val
      end

    if hit?, do: result, else: nil
  end

  @start "in"
  def solve1 do
    {workflows, parts} = Parser.parsed_input()

    for(p <- parts, do: {p, do_workflow(workflows, @start, p)})
    |> Enum.filter(fn {_part, result} -> result == "A" end)
    |> Enum.map(&Enum.sum(Map.values(elem(&1, 0))))
    |> Enum.sum()
  end

  def split_range(_range = a..b, op, val) do
    case op do
      "<" ->
        top_bound_lt = min(val - 1, b)
        bottom_bound_gte = max(val, a)
        [a..top_bound_lt//1, bottom_bound_gte..b//1]

      ">" ->
        bottom_bound_gt = max(val + 1, a)
        top_bound_lte = min(val, b)
        [bottom_bound_gt..b//1, a..top_bound_lte//1]
    end
  end

  @combinations %{"x" => 1..4000, "m" => 1..4000, "a" => 1..4000, "s" => 1..4000}

  def search_combos(workflows, [{"A", ranges} | rest], acc),
    do: search_combos(workflows, rest, acc + num_combos(ranges))

  def search_combos(workflows, [{"R", _ranges} | rest], acc),
    do: search_combos(workflows, rest, acc)

  def search_combos(workflows, [{flow, ranges} | rest], acc) do
    %{rules: rules, fallback: fallback} = workflows[flow]

    {fallback_ranges, new_states} =
      for _rule = [valname, op, val, result] <- rules, reduce: {ranges, []} do
        {ranges, acc} ->
          [yes_range, no_range] = split_range(ranges[valname], op, val)
          yes_ranges = Map.put(ranges, valname, yes_range)
          acc = [{result, yes_ranges} | acc]
          ranges = Map.put(ranges, valname, no_range)
          {ranges, acc}
      end

    new_states =
      [{fallback, fallback_ranges} | new_states]
      |> Enum.filter(fn {_, ranges} -> num_combos(ranges) > 0 end)

    search_combos(workflows, new_states ++ rest, acc)
  end

  def search_combos(_, [], acc), do: acc

  def num_combos(ranges) do
    Map.values(ranges) |> Enum.map(&Range.size/1) |> Enum.product()
  end

  def solve2 do
    {workflows, _parts} = Parser.parsed_input()
    states = [{@start, @combinations}]
    search_combos(workflows, states, 0)
  end
end
