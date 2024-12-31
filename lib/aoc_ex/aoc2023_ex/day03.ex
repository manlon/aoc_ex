defmodule AocEx.Aoc2023Ex.Day03 do
  use AocEx.Day, day: 3

  @nums ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
  @dot "."

  def solve1 do
    {ints, syms} = parse_map()

    for {loc, _} <- syms, the_int <- ints[loc], reduce: MapSet.new() do
      map ->
        MapSet.put(map, the_int)
    end
    |> Enum.reduce(0, fn {n, _}, acc -> acc + n end)
  end

  def solve2 do
    {ints, syms} = parse_map()

    for {loc, "*"} <- syms, hits = ints[loc], length(hits) == 2, reduce: 0 do
      acc ->
        [{n1, _}, {n2, _}] = hits
        n1 * n2 + acc
    end
  end

  def parse_map() do
    {map, {rows, cols}} = input_map_with_size()
    find_ints(map, {0, 0}, {rows, cols}, %{}, %{})
  end

  def find_ints(map, {row, col}, {rowmax, colmax}, acc, syms) when col > colmax do
    find_ints(map, {row + 1, 0}, {rowmax, colmax}, acc, syms)
  end

  def find_ints(_map, {row, _col}, {rowmax, _colmax}, acc, syms) when row > rowmax do
    {acc, syms}
  end

  def find_ints(map, {row, col}, {rowmax, colmax}, acc, syms) do
    char = Map.get(map, {row, col})

    cond do
      char == @dot ->
        find_ints(map, {row, col + 1}, {rowmax, colmax}, acc, syms)

      char in @nums ->
        {i, {r, c}} = consume_int(map, {row, col}, {rowmax, colmax}, [])

        acc =
          for adjr <- Enum.max([0, r - 1])..Enum.min([r + 1, rowmax]),
              adjc <- Enum.max([0, col - 1])..Enum.min([c + 1, colmax]),
              reduce: acc do
            acc ->
              Map.update(acc, {adjr, adjc}, [{i, {row, col}}], &[{i, {row, col}} | &1])
          end

        find_ints(map, {r, c + 1}, {rowmax, colmax}, acc, syms)

      true ->
        find_ints(map, {row, col + 1}, {rowmax, colmax}, acc, Map.put(syms, {row, col}, char))
    end
  end

  def consume_int(_map, {row, col}, {_rowmax, colmax}, acc) when col > colmax do
    {Integer.undigits(Enum.reverse(acc)), {row, col - 1}}
  end

  def consume_int(map, {row, col}, {rowmax, colmax}, acc) do
    i = Map.get(map, {row, col})

    if i in @nums do
      consume_int(map, {row, col + 1}, {rowmax, colmax}, [String.to_integer(i) | acc])
    else
      {Integer.undigits(Enum.reverse(acc)), {row, col - 1}}
    end
  end
end
