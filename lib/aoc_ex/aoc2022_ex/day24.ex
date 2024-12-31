defmodule AocEx.Aoc2022Ex.Day24 do
  use AocEx.Day, year: 2022, day: 24

  def input_map do
    {map, size = {rmax, cmax}} = input_map_with_size()

    map =
      for r <- 0..rmax,
          c <- 0..cmax,
          val = map[{r, c}],
          reduce: %{} do
        new_map ->
          if r in 1..(rmax - 1) and c in 1..(cmax - 1) do
            if val in ["<", "^", ">", "v"] do
              Map.put(new_map, {r, c}, [val])
            else
              new_map
            end
          else
            Map.put(new_map, {r, c}, val)
          end
      end

    {start, "."} = Enum.find(map, fn {{r, _c}, v} -> r == 0 && v == "." end)
    {dest, "."} = Enum.find(map, fn {{r, _c}, v} -> r == rmax && v == "." end)
    {map, size, start, dest}
  end

  def tick(map, size = {rmax, cmax}) do
    for r <- 0..rmax,
        c <- 0..cmax,
        val = map[{r, c}],
        reduce: %{} do
      new_map ->
        if r in 1..(rmax - 1) and c in 1..(cmax - 1) do
          case val do
            nil ->
              new_map

            contents when is_list(contents) ->
              Enum.reduce(contents, new_map, fn pointer, map ->
                pos = next_pos(pointer, {r, c}, size)
                Map.update(map, pos, [pointer], &[pointer | &1])
              end)
          end
        else
          Map.put(new_map, {r, c}, val)
        end
    end
  end

  def possible_moves(map, pos = {r, c}, _size = {maxr, maxc}) do
    [pos, {r + 1, c}, {r - 1, c}, {r, c + 1}, {r, c - 1}]
    |> Enum.filter(fn p ->
      (!Map.has_key?(map, p) || Map.get(map, p) == ".") and r in 0..maxr and c in 0..maxc
    end)
  end

  def pathfind(map, positions, size, n, dest) do
    if dest in positions do
      {n, map}
    else
      map = tick(map, size)

      new_positions =
        Enum.flat_map(positions, fn p -> possible_moves(map, p, size) end)
        |> Enum.uniq()

      pathfind(map, new_positions, size, n + 1, dest)
    end
  end

  def wrap({0, c}, {maxr, _maxc}), do: {maxr - 1, c}
  def wrap({r, 0}, {_maxr, maxc}), do: {r, maxc - 1}
  def wrap({maxr, c}, {maxr, _maxc}), do: {1, c}
  def wrap({r, maxc}, {_maxr, maxc}), do: {r, 1}
  def wrap({r, c}, _), do: {r, c}

  def next_pos(pointer, {r, c}, {maxr, maxc}) do
    case pointer do
      "<" -> {r, c - 1}
      "^" -> {r - 1, c}
      ">" -> {r, c + 1}
      "v" -> {r + 1, c}
    end
    |> wrap({maxr, maxc})
  end

  def solve1 do
    {map, size, start, dest} = input_map()
    {n, _} = pathfind(map, [start], size, 0, dest)
    n
  end

  def solve2 do
    {map, size, start, dest} = input_map()
    {n1, map} = pathfind(map, [start], size, 0, dest)
    {n2, map} = pathfind(map, [dest], size, 0, start)
    {n3, _map} = pathfind(map, [start], size, 0, dest)
    n1 + n2 + n3
  end
end
