defmodule Aoc2023Ex.Day02 do
  alias ElixirSense.Core.Parser
  use Aoc2023Ex.Day

  defmodule Parser do
    import NimbleParsec
    colors = choice([string("red"), string("green"), string("blue")])
    color_count = wrap(integer(min: 1) |> ignore(string(" ")) |> concat(colors))
    clause = wrap(color_count |> repeat(concat(ignore(string(", ")), color_count)))
    clauses = wrap(clause |> repeat(concat(ignore(string("; ")), clause)))
    line = ignore(string("Game ")) |> integer(min: 1) |> ignore(string(": ")) |> concat(clauses)

    defparsec(:parse_line_help, line)

    def parse_line(line) do
      {:ok, [gameno, clauses], _, _, _, _} = parse_line_help(line)
      {gameno, clauses}
    end
  end

  @colors %{"red" => 12, "green" => 13, "blue" => 14}

  def input_games, do: Enum.map(input_lines(), &Parser.parse_line/1)

  def solve1 do
    for {num, clauses} <- input_games(),
        Enum.all?(clauses, fn clause ->
          Enum.all?(clause, fn [count, color] ->
            count <= @colors[color]
          end)
        end) do
      num
    end
    |> Enum.sum()
  end

  def solve2 do
    for {_, clauses} <- input_games() do
      for clause <- clauses, reduce: %{} do
        acc ->
          for [count, color] <- clause, reduce: acc do
            acc ->
              {_, map} =
                Map.get_and_update(acc, color, fn c ->
                  {c, Enum.max([c || 0, count])}
                end)

              map
          end
      end
      |> Map.values()
      |> Enum.product()
    end
    |> Enum.sum()
  end
end
