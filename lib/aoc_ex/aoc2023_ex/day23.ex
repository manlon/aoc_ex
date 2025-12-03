defmodule AocEx.Aoc2023Ex.Day23 do
  use AocEx.Day, year: 2023, day: 23

  @path "."
  @dirs ["<", ">", "^", "v"]

  def neighbs(map, loc = {r, c}, slip) do
    cond do
      !slip || map[loc] == @path ->
        [{r + 1, c}, {r - 1, c}, {r, c + 1}, {r, c - 1}]
        |> Enum.filter(fn {r, c} -> map[{r, c}] in [@path | @dirs] end)

      slip ->
        case map[loc] do
          ">" -> [{r, c + 1}]
          "<" -> [{r, c - 1}]
          "^" -> [{r - 1, c}]
          "v" -> [{r + 1, c}]
        end
    end
  end

  def extend_path(map, {loc, set} = _path, slip) do
    neighbs(map, loc, slip)
    |> Enum.filter(fn n -> n not in set end)
    |> Enum.map(fn newloc -> {newloc, MapSet.put(set, newloc)} end)
  end

  def extend_paths_rev(_map, [], res, _dest, _slip, _memo), do: res

  def extend_paths_rev(map, paths = [path = {loc, set} | rest], res, dest, slip, _memo) do
    if :rand.uniform() < 0.000001 do
      dbg({length(paths), res})
    end

    if loc == dest do
      longest = max(res, Enum.count(set))
      extend_paths(map, rest, longest, dest, slip)
    else
      paths = rest ++ extend_path(map, path, slip)
      extend_paths(map, paths, res, dest, slip)
    end
  end

  def extend_paths(_map, [], res, _dest, _slip), do: res

  def extend_paths(map, paths = [path = {loc, set} | rest], res, dest, slip) do
    # {paths, res} =
    #   for path = {loc, set} <- paths, reduce: {[], res} do
    #     {newpaths, res} ->
    #       if loc == dest do
    #         {newpaths, max(res, Enum.count(set))}
    #       else
    #         {extend_path(map, path, slip) ++ newpaths, res}
    #       end
    #   end

    if :rand.uniform() < 0.000001 do
      dbg({length(paths), res})
    end

    if loc == dest do
      longest = max(res, Enum.count(set))
      extend_paths(map, rest, longest, dest, slip)
    else
      paths = rest ++ extend_path(map, path, slip)
      extend_paths(map, paths, res, dest, slip)
    end

    # {paths, res} =
    #   for path = {loc, set} <- paths, reduce: {[], res} do
    #     {newpaths, res} ->
    #       if loc == dest do
    #         {newpaths, max(res, Enum.count(set))}
    #       else
    #         {extend_path(map, path, slip) ++ newpaths, res}
    #       end
    #   end

    # dbg({length(paths), res})
    # extend_paths(map, paths, res, dest, slip)
  end

  def solve1 do
    {map, {maxr, _maxc}} = input_map_with_size()
    {start, _} = Enum.find(map, fn {{r, _c}, v} -> r == 0 && v == @path end)
    {fin, _} = Enum.find(map, fn {{r, _c}, v} -> r == maxr && v == @path end)
    {start, fin}
    paths = [{start, MapSet.new([start])}]

    extend_paths(map, paths, 0, fin, true)
  end

  def solve2 do
    {map, {maxr, _maxc}} = input_map_with_size()
    {start, _} = Enum.find(map, fn {{r, _c}, v} -> r == 0 && v == @path end)
    {fin, _} = Enum.find(map, fn {{r, _c}, v} -> r == maxr && v == @path end)
    {start, fin}
    paths = [{start, MapSet.new([start])}]

    extend_paths(map, paths, 0, fin, false)
  end
end
