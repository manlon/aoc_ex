defmodule AocEx.Aoc2023Ex.Day08 do
  use AocEx.Day, day: 8

  defmodule Parser do
    alias AocEx.Aoc2023Ex.Day08
    use AocEx.Parser
    dirs = choice([string("L"), string("R")])
    dirline = wrap(repeat(dirs))
    node = ascii_string([?A..?Z], 3)
    line = wrap(node |> istr(" = (") |> wrap(node |> istr(", ") |> concat(node)) |> istr(")"))
    input = dirline |> istr("\n\n") |> wrap(separated(line, istr("\n")))
    defmatch(:parse, input)

    def parsed_input() do
      [dirs, nodes] = parse(Day08.input())

      nodes =
        for [n, [l, r]] <- nodes, into: %{} do
          {n, %{"L" => l, "R" => r}}
        end

      {dirs, nodes}
    end
  end

  def rotate(q) do
    {{:value, v}, q} = :queue.out(q)
    {v, :queue.in(v, q)}
  end

  def travel(map, node \\ "AAA", dirs, steps \\ 0)
  def travel(_, "ZZZ", _, steps), do: steps

  def travel(map, node, dirs, steps) do
    {d, dirs} = rotate(dirs)
    travel(map, map[node][d], dirs, steps + 1)
  end

  def dist_to_end(map, node, dirs, steps \\ 0) do
    if String.ends_with?(node, "Z") do
      l = :queue.len(dirs)
      if rem(steps, l) != 0, do: raise("oops")
      steps
    else
      {d, dirs} = rotate(dirs)
      dist_to_end(map, map[node][d], dirs, steps + 1)
    end
  end

  def solve1 do
    {dirs, map} = Parser.parsed_input()
    travel(map, :queue.from_list(dirs))
  end

  def solve2 do
    {dirs, map} = Parser.parsed_input()
    l = length(dirs)
    nodes = Map.keys(map) |> Enum.filter(&String.ends_with?(&1, "A"))
    dirs = :queue.from_list(dirs)
    dists = for(n <- nodes, do: div(dist_to_end(map, n, dirs), l))
    l * Enum.product(dists)
  end
end
