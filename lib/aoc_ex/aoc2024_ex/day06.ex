defmodule AocEx.Aoc2024Ex.Day06 do
  def input do
    AocEx.Day.input_file_contents(2024, 6)
  end

  def input_map_with_size(input \\ nil) do
    (input || input())
    |> String.split("\n")
    |> Enum.map(fn line ->
      String.graphemes(line)
    end)
    |> Enum.with_index()
    |> Enum.reduce({%{}, {0, 0}}, fn {line, lineno}, {map, maxkey} ->
      Enum.reduce(Enum.with_index(line), {map, maxkey}, fn {val, colno}, {map, maxkey} ->
        map = Map.put(map, {lineno, colno}, val)
        maxkey = Enum.max([maxkey, {lineno, colno}])
        {map, maxkey}
      end)
    end)
  end

  def start_state() do
    {map, maxkey} = input_map_with_size()
    {startpos, _} = Enum.find(map, fn {_, v} -> v == "^" end)
    map = Map.put(map, startpos, ".")
    {map, MapSet.new([{startpos, {-1, 0}}]), startpos}
  end

  def addpos({r1, c1}, {r2, c2}), do: {r1 + r2, c1 + c2}

  @dirs [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]

  def solve1 do
    {map, visited, pos} = start_state()
    {:off, visited} = walk(map, visited, pos, @dirs)

    Enum.map(visited, fn {pos, _} -> pos end)
    |> Enum.uniq()
    |> Enum.count()
  end

  def walk(map, visited, pos, dirs = [dir | rest_dirs = [turn | _]]) do
    newpos = addpos(pos, dir)

    if MapSet.member?(visited, {newpos, dir}) do
      {:loop, visited}
    else
      case Map.get(map, newpos) do
        nil -> {:off, visited}
        "." -> walk(map, MapSet.put(visited, {newpos, dir}), newpos, dirs)
        "#" -> walk(map, MapSet.put(visited, {pos, turn}), pos, rest_dirs ++ [dir])
      end
    end
  end

  def solve2 do
    {map, visited, startpos} = start_state()

    Enum.reduce(map, [], fn {pos, v}, acc ->
      if v == "." do
        newmap = Map.put(map, pos, "#")

        case walk(newmap, visited, startpos, @dirs) do
          {:off, visited} -> acc
          {:loop, visited} -> [pos | acc]
        end
      else
        acc
      end
    end)
  end
end
