defmodule Aoc2023Ex.Day10 do
  use Aoc2023Ex.Day

  @directions [ north: {-1, 0}, east: {0, 1}, south: {1, 0}, west: {0, -1} ]

  @turns %{
    "|" => %{north: :north, south: :south},
    "-" => %{east: :east, west: :west},
    "L" => %{west: :north, south: :east},
    "J" => %{south: :west, east: :north},
    "7" => %{east: :south, north: :west},
    "F" => %{north: :east, west: :south}
  }

  @animal "S"
  @left "L"
  @right "R"
  @path "#"

  def direction_lr(dir, directions \\ @directions)
  def direction_lr(dir, [{l, _}, {dir, _}, {r, _} | _]), do: {l, r}
  def direction_lr(dir, [d | rest]), do: direction_lr(dir, rest ++ [d])
  def rev(dir), do: direction_lr(dir) |> elem(0) |> direction_lr() |> elem(0)
  def add({x, y}, {dx, dy}), do: {x + dx, y + dy}

  def annotate(map, direction, pos, acc) do
    if Map.get(acc, pos) == @path do
      acc
    else
      acc = Map.put(acc, pos, @path)
      acc = annotate_dir(acc, direction, pos)
      direction = @turns[map[pos]][direction]
      acc = annotate_dir(acc, direction, pos)
      newpos = add(pos, @directions[direction])
      annotate(map, direction, newpos, acc)
    end
  end

  def annotate_dir(map, dir, pos) do
    {dl, dr} = direction_lr(dir)

    Map.put_new(map, add(pos, @directions[dl]), @left)
    |> Map.put_new(add(pos, @directions[dr]), @right)
  end

  def fill_map(map, {maxr, maxc}) do
    unfilled =
      for r <- 0..maxr, c <- 0..maxc, !Map.has_key?(map, {r, c}) do
        {r, c}
      end

    if unfilled == [] do
      map
    else
      for coord <- unfilled, reduce: map do
        map ->
          neighbs = four_neighbors(coord)

          case Enum.find(neighbs, fn c -> map[c] in [@left, @right] end) do
            nil ->
              map

            n ->
              Map.put(map, coord, map[n])
          end
      end
      |> fill_map({maxr, maxc})
    end
  end

  def starting_state do
    {map, size} = input_map_with_size()
    {animal_pos, _} = Enum.find(map, fn {_, v} -> v == @animal end)

    {pos, dir} =
      for n <- four_neighbors(animal_pos),
          pipe = map[n],
          dir <- Map.values(@turns[pipe]),
          add(n, @directions[dir]) == animal_pos do
        {n, rev(dir)}
      end
      |> hd()

    {map, size, pos, dir, %{animal_pos => @path}}
  end

  def solve1 do
    {map, _size, pos, dir, annotated} = starting_state()
    map = annotate(map, dir, pos, annotated)
    pathlen = Map.values(map) |> Enum.count(&(&1 == @path))
    div(pathlen, 2)
  end

  def solve2 do
    {map, size, pos, dir, annotated} = starting_state()

    map =
      annotate(map, dir, pos, annotated)
      |> fill_map(size)

    inside =
      if Enum.any?(map, fn {{x, y}, v} -> (x == 0 || y == 0) && v == @right end) do
        @left
      else
        @right
      end

    Enum.count(map, fn {_, v} -> v == inside end)
  end
end
