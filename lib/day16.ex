defmodule Aoc2023Ex.Day16 do
  use Aoc2023Ex.Day

  @dirs %{up: {-1, 0}, down: {1, 0}, left: {0, -1}, right: {0, 1}}
  @reflections %{
    "/" => %{up: :right, down: :left, left: :down, right: :up},
    "\\" => %{up: :left, down: :right, left: :up, right: :down}
  }
  @splits %{
    "-" => %{down: [:left, :right], up: [:left, :right]},
    "|" => %{left: [:up, :down], right: [:up, :down]}
  }

  def in_map?({maxr, maxc}, {r, c}), do: r in 0..maxr and c in 0..maxc
  def add({a, b}, {c, d}), do: {a + c, b + d}

  def beam(_map, _size, _beams = [], seen), do: Enum.count(seen)

  def beam(map, size, [{loc, dir} | heads], seen) do
    seen = Map.update(seen, loc, [dir], &Enum.uniq([dir | &1]))
    pt = map[loc]
    new_dir = get_in(@reflections, [pt, dir]) || dir
    new_dirs = get_in(@splits, [pt, dir]) || [new_dir]

    new_pts =
      Enum.map(new_dirs, fn d -> {add(@dirs[d], loc), d} end)
      |> Enum.filter(fn {x, _} -> in_map?(size, x) end)
      |> Enum.filter(fn {x, d} -> d not in Map.get(seen, x, []) end)

    beam(map, size, new_pts ++ heads, seen)
  end

  def solve1 do
    {map, size} = input_map_with_size()
    start = [{{0, 0}, :right}]
    beam(map, size, start, %{})
  end

  def solve2 do
    {map, size = {maxr, maxc}} = input_map_with_size()

    starts =
      for(c <- 0..maxc, do: {{0, c}, :down}) ++
        for(c <- 0..maxc, do: {{maxr, c}, :up}) ++
        for(r <- 0..maxr, do: {{r, 0}, :right}) ++
        for(r <- 0..maxr, do: {{r, maxc}, :left})

    for(loc <- starts, do: beam(map, size, [loc], %{}))
    |> Enum.max()
  end
end
