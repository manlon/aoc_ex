defmodule AocEx.Aoc2022Ex.Day07 do
  use AocEx.Day, year: 2022, day: 7

  def parse_input do
    input = Enum.map(input_lines(), &String.split/1)
    parse_input(input, [], Map.new())
  end

  def parse_input([["$", "cd", ".."] | input], path = [_ | parent], result) do
    result = Map.update!(result, parent, &(&1 + Map.get(result, path)))
    parse_input(input, parent, result)
  end

  def parse_input([["$", "cd", dirname], ["$", "ls"] | input], path, result) do
    path = [dirname | path]
    {input, _dirs, files} = parse_dir_entries(input)
    filesum = Enum.sum(for {size, _} <- files, do: size)
    result = Map.put(result, path, filesum)
    parse_input(input, path, result)
  end

  def parse_input([], ["/"], result), do: result
  def parse_input([], path, result), do: parse_input([["$", "cd", ".."]], path, result)

  def parse_dir_entries(_input, dirs \\ [], files \\ [])

  def parse_dir_entries([["dir", dirname] | input], dirs, files) do
    parse_dir_entries(input, [dirname | dirs], files)
  end

  def parse_dir_entries(input = [["$" | _] | _], dirs, files), do: {input, dirs, files}
  def parse_dir_entries([], dirs, files), do: {[], dirs, files}

  def parse_dir_entries([[size, fname] | input], dirs, files) do
    parse_dir_entries(input, dirs, [{String.to_integer(size), fname} | files])
  end

  def solve1 do
    parse_input()
    |> Map.values()
    |> Enum.filter(fn x -> x <= 100_000 end)
    |> Enum.sum()
  end

  def solve2 do
    map = parse_input()
    required = map[["/"]] - 70_000_000 + 30_000_000

    Map.values(map)
    |> Enum.filter(fn x -> x >= required end)
    |> Enum.min()
  end
end
