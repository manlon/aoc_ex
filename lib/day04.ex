defmodule Aoc2023Ex.Day04 do
  use Aoc2023Ex.Day

  defmodule Parser do
    import NimbleParsec
    nums = repeat(ignore(repeat(string(" "))) |> integer(min: 1))
    halves = wrap(nums) |> ignore(string(" |")) |> concat(wrap(nums))

    line =
      ignore(string("Card"))
      |> ignore(repeat(string(" ")))
      |> integer(min: 1)
      |> ignore(string(":"))
      |> concat(halves)

    defparsec(:parse_line_help, line)

    def parse_line(line) do
      {:ok, [num, a, b], _, _, _, _} = parse_line_help(line)
      {num, a, b}
    end

    def parsed_lines, do: Enum.map(Aoc2023Ex.Day04.input_lines(), &parse_line/1)
  end

  def solve1 do
    for {_, wins, nums} <- Parser.parsed_lines(),
        hits = Enum.count(nums, &Enum.member?(wins, &1)) do
      if hits == 0, do: 0, else: 2 ** (hits - 1)
    end
    |> Enum.sum()
  end

  def solve2 do
    lines = Parser.parsed_lines()

    card_counts =
      for({n, _, _} <- lines, do: {n, 1}) |> Map.new()

    for {num, wins, nums} <- lines, reduce: card_counts do
      counts ->
        hits = Enum.count(nums, &Enum.member?(wins, &1))
        Enum.reduce((num+1)..(num+hits)//1, counts, fn n, acc ->
          Map.update(acc, n, 0, &(&1 + counts[num]))
        end)
    end
    |> Map.values()
    |> Enum.sum()
  end
end
