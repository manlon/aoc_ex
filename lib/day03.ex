defmodule Aoc2023Ex.Day03 do
  use Aoc2023Ex.Day

  @nums ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
  @dot "."

  def solve1 do
    {map, {rows, cols}} = input_map_with_size()
    {ints, syms} = find_ints(map, {0, 0}, {rows, cols}, [], %{})

    for {i, {{r, c1}, {r, c2}}} <- ints,
        {{sr, sc}, _} <- syms,
        sr in (r - 1)..(r + 1),
        sc in (c1 - 1)..(c2 + 1) do
      i
    end
    |> Enum.sum()
  end

  def solve2 do
    {map, {rows, cols}} = input_map_with_size()
    {ints, syms} = find_ints(map, {0, 0}, {rows, cols}, [], %{})

    for {{gr, gc}, "*"} <- syms do
      gear_ints =
        for {i, {{r, c1}, {r, c2}}} <- ints,
            gr in (r - 1)..(r + 1),
            gc in (c1 - 1)..(c2 + 1) do
          i
        end

      gear_ints
    end
    |> Enum.filter(fn ints -> length(ints) == 2 end)
    |> Enum.map(&Enum.product/1)
    |> Enum.sum()
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
        find_ints(map, {r, c + 1}, {rowmax, colmax}, [{i, {{row, col}, {r, c}}} | acc], syms)

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
