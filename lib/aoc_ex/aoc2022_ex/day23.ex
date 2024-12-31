defmodule AocEx.Aoc2022Ex.Day23 do
  use AocEx.Day, year: 2022, day: 23

  @elf "#"

  def input_map do
    {map, _} = input_map_with_size()

    Enum.filter(map, fn {_, c} -> c == @elf end)
    |> Map.new()
  end

  @dirs [:n, :s, :w, :e]

  def no_neighbors?(map, {r, c}) do
    coords =
      for rr <- (r - 1)..(r + 1),
          cc <- (c - 1)..(c + 1),
          {rr, cc} != {r, c} do
        {rr, cc}
      end

    all_open?(map, coords)
  end

  def all_open?(map, coords) do
    Enum.all?(coords, fn x -> Map.get(map, x) != @elf end)
  end

  def adjs({r, c}, :n), do: for(cc <- (c - 1)..(c + 1), do: {r - 1, cc})
  def adjs({r, c}, :s), do: for(cc <- (c - 1)..(c + 1), do: {r + 1, cc})
  def adjs({r, c}, :w), do: for(rr <- (r - 1)..(r + 1), do: {rr, c - 1})
  def adjs({r, c}, :e), do: for(rr <- (r - 1)..(r + 1), do: {rr, c + 1})

  def neighb({r, c}, nil), do: {r, c}
  def neighb({r, c}, :n), do: {r - 1, c}
  def neighb({r, c}, :s), do: {r + 1, c}
  def neighb({r, c}, :w), do: {r, c - 1}
  def neighb({r, c}, :e), do: {r, c + 1}

  def round(map, directions, numrounds), do: round(map, directions, 0, numrounds)
  def round(map, _directions, round, numrounds) when round >= numrounds, do: map

  def round(map, directions = [d | rest_dir], n, numrounds) do
    {proposals, stays} =
      Enum.reduce(map, {%{}, []}, fn {pos, _}, {proposals, stays} ->
        if no_neighbors?(map, pos) do
          {proposals, [pos | stays]}
        else
          direction =
            Enum.find(directions, fn dir ->
              pts = adjs(pos, dir)
              all_open?(map, pts)
            end)

          case direction do
            nil ->
              {proposals, [pos | stays]}

            dir ->
              new_pos = neighb(pos, dir)
              props = Map.update(proposals, new_pos, [pos], fn existing -> [pos | existing] end)
              {props, stays}
          end
        end
      end)

    new_map = Enum.reduce(stays, %{}, fn stay, map -> Map.put(map, stay, @elf) end)

    new_map =
      Enum.reduce(proposals, new_map, fn {dest, sources}, map ->
        case sources do
          [_source] ->
            Map.put(map, dest, @elf)

          sources ->
            Enum.reduce(sources, map, fn src, map ->
              Map.put(map, src, @elf)
            end)
        end
      end)

    if new_map == map do
      {:stop, n + 1, map}
    else
      round(new_map, rest_dir ++ [d], n + 1, numrounds)
    end
  end

  def num_empties(map) do
    keys = Map.keys(map)
    minr = Enum.min(Stream.map(keys, fn {r, _c} -> r end))
    maxr = Enum.max(Stream.map(keys, fn {r, _c} -> r end))
    minc = Enum.min(Stream.map(keys, fn {_r, c} -> c end))
    maxc = Enum.max(Stream.map(keys, fn {_r, c} -> c end))
    (maxr - minr + 1) * (maxc - minc + 1) - Enum.count(map)
  end

  def solve1 do
    map = round(input_map(), @dirs, 10)
    num_empties(map)
  end

  def solve2 do
    {:stop, numrounds, _map} = round(input_map(), @dirs, :infinity)
    numrounds
  end
end
