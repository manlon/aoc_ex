defmodule AocEx.Aoc2015Ex.Day09 do
  use AocEx.Day, year: 2015, day: 9

  def dists do
    for [a, "to", b, "=", d] <- input_tokens(), reduce: %{} do
      map ->
        d = String.to_integer(d)

        Map.update(map, a, [{b, d}], &[{b, d} | &1])
        |> Map.update(b, [{a, d}], &[{a, d} | &1])
    end
  end

  def paths(dists), do: Stream.flat_map(dists, fn {loc, _dests} -> paths(dists, [loc], 0) end)

  def paths(dists, path = [loc | _], len) do
    if length(path) == Enum.count(dists) do
      [{len, path}]
    else
      Stream.flat_map(dists[loc], fn {dest, d} ->
        if dest in path do
          []
        else
          paths(dists, [dest | path], len + d)
        end
      end)
    end
  end

  def solve1 do
    paths(dists()) |> Enum.min() |> elem(0)
  end

  def solve2 do
    paths(dists()) |> Enum.max() |> elem(0)
  end
end
