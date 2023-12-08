defmodule Aoc2023Ex.Day08 do
  use Aoc2023Ex.Day

  defmodule Parser do
    use Aoc2023Ex.Parser
    dirs = choice([string("L"), string("R")])
    dirline = wrap(repeat(dirs))
    node = ascii_string([?A..?Z], 3)
    line = wrap(node |> istr(" = (") |> wrap(node |> istr(", ") |> concat(node)) |> istr(")"))
    input = dirline |> istr("\n\n") |> wrap(separated(line, istr("\n")))
    defmatch(:parse, input)

    def parsed_input() do
      [dirs, nodes] = parse(Aoc2023Ex.Day08.input())

      nodes =
        for [n, [l, r]] <- nodes, into: %{} do
          {n, %{"L" => l, "R" => r}}
        end

      {dirs, nodes}
    end
  end

  @start "AAA"
  @finish "ZZZ"

  def travel(map, nodes, dirs, useddirs \\ [], steps \\ 0, wincond)

  def travel(map, nodes, [], useddirs, steps, wincond),
    do: travel(map, nodes, Enum.reverse(useddirs), [], steps, wincond)

  def travel(map, nodes, [d | dirs], useddirs, steps, wincond) do
    if rem(steps, 1_000_000) == 0, do: dbg(steps)

    if wincond.(nodes) do
      steps
    else
      nodes = for n <- nodes, do: map[n][d]
      travel(map, nodes, dirs, [d | useddirs], steps + 1, wincond)
    end
  end

  def won?(nodes), do: nodes == [@finish]
  # def won_ghosts?(nodes), do: Enum.all?(nodes, &String.ends_with?(&1, "Z"))

  def dist_to_end(map, node, dirs, useddirs \\ [], steps \\ 0)

  def dist_to_end(map, node, [], useddirs, steps),
    do: dist_to_end(map, node, Enum.reverse(useddirs), [], steps)

  def dist_to_end(map, node, [d | dirs], useddirs, steps) do
    if String.ends_with?(node, "Z") do
      l = length(dirs) + length(useddirs) + 1
      if rem(steps, l) != 0, do: raise("oops")
      steps
    else
      dist_to_end(map, map[node][d], dirs, [d | useddirs], steps + 1)
    end
  end

  def solve1 do
    {dirs, map} = Parser.parsed_input()
    travel(map, [@start], dirs, &won?/1)
  end

  def solve2 do
    {dirs, map} = Parser.parsed_input()
    l = length(dirs)
    nodes = Map.keys(map) |> Enum.filter(&String.ends_with?(&1, "A"))
    dists = for(n <- nodes, do: div(dist_to_end(map, n, dirs), l))
    l * Enum.product(dists)
  end
end
