defmodule AocEx.Aoc2022Ex.Day16 do
  use AocEx.Day, year: 2022, day: 16

  def input_map(input_file \\ nil) do
    String.split(input_file || input(), "\n", trim: true)
    |> Enum.map(fn line ->
      case String.split(line, [" ", "=", ",", ";"], trim: true) do
        ["Valve", src, "has", "flow", "rate", flow, _tunnel, _lead, "to", _valve | rest] ->
          {src, {String.to_integer(flow), rest}}
      end
    end)
    |> Map.new()
  end

  def all_valves(map), do: for({valve, {rate, _}} <- map, rate > 0, do: valve)

  # Floyd-Warshall
  def distances(map) do
    dists =
      Enum.reduce(map, %{}, fn {loc, {_, cnxs}}, dists ->
        Enum.reduce(cnxs, dists, fn cnx, dists -> Map.put(dists, {loc, cnx}, 1) end)
        |> Map.put({loc, loc}, 0)
      end)

    for {k, _} <- map,
        {i, _} <- map,
        {j, _} <- map,
        reduce: dists do
      dists ->
        if Map.has_key?(dists, {i, k}) and Map.has_key?(dists, {k, j}) do
          sum = dists[{i, k}] + dists[{k, j}]
          Map.update(dists, {i, j}, sum, &min(&1, sum))
        else
          dists
        end
    end
  end

  # Return a stream of {score, path} where the paths are all possible paths among valves
  def paths(map, start \\ "AA", time \\ 30) do
    paths(map, distances(map), all_valves(map), {0, [start]}, time)
  end

  def paths(_, _, _valves = [], _, _), do: []

  def paths(map, distances, valves, {accum, path = [cur | _rest]}, time_left) do
    Stream.concat(
      [{accum, path}],
      Stream.map(valves, fn v -> {v, map[v], time_left - distances[{cur, v}] - 1} end)
      |> Stream.filter(fn {_v, _, time_at_v} -> time_at_v > 0 end)
      |> Stream.flat_map(fn {v, {pressure_v, _}, time_at_v} ->
        new_accum = time_at_v * pressure_v + accum
        paths(map, distances, valves -- [v], {new_accum, [v | path]}, time_at_v)
      end)
    )
  end

  def solve1, do: Enum.max(paths(input_map(), "AA", 30)) |> elem(0)

  def solve2 do
    paths(input_map(), "AA", 26)
    |> Enum.reduce(%{}, fn {score, path}, map ->
      Map.update(map, MapSet.new(tl(Enum.sort(path))), score, &max(&1, score))
    end)
    |> pairs()
    |> Stream.filter(fn [{s1, _score1}, {s2, _score2}] -> MapSet.disjoint?(s1, s2) end)
    |> Stream.map(fn [{_, score1}, {_, score2}] -> score1 + score2 end)
    |> Enum.max()
  end
end
