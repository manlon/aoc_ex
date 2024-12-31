defmodule AocEx.Aoc2024Ex.Day16 do
  def input do
    AocEx.Day.input_file_contents(2024, 16)
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

  @dirs [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]
  @start "S"
  @fin "E"
  @wall "#"
  @empty "."
  @startdir {0, 1}
  @turncost 1000
  @movecost 1

  def addpos({r1, c1}, {r2, c2}), do: {r1 + r2, c1 + c2}
  def abspos({r, c}), do: {abs(r), abs(c)}
  def possort({r, c}, {1, 0}), do: {r, c}
  def possort({r, c}, {0, 1}), do: {c, r}

  def find_path(map, queue, dists, paths, goalpos) do
    # dbg(Enum.count(queue))
    goaldist = Map.get(dists, goalpos, :inf)

    {{dist, pos = {loc, dir}}, queue} = Heap.split(queue)

    # dbg({Heap.size(queue), :os.system_time(:millisecond)})
    # dbg(pos)
    # dbg(queue)
    # dbg(dists)

    curpaths = Map.get(paths, pos)
    # dbg(curpaths)

    if dist > goaldist do
      {goaldist, Map.get(paths, goalpos)}
    else
      turns =
        for d <- @dirs,
            newdist = dist + @turncost,
            newpos = {loc, d},
            newdist <= Map.get(dists, newpos, :inf) do
          {newdist, newpos}
        end

      movedist = dist + @movecost
      moveloc = addpos(loc, dir)
      movepos = {moveloc, dir}
      # dbg(Map.get(map, moveloc))
      # dbg(Map.get(dists, movepos, :inf))

      positions =
        turns ++
          if Map.get(map, moveloc) == @empty && movedist <= Map.get(dists, movepos, :inf) do
            [{movedist, movepos}]
          else
            []
          end

      # dbg(positions)

      # dbg(positions)
      # dbg(queue)
      # dbg(dists)

      {queue, dists, paths} =
        Enum.reduce(positions, {queue, dists, paths}, fn dpos = {dist, pos},
                                                         {queue, dists, paths} ->
          prevdist = Map.get(dists, pos, :inf)
          # dbg(prevdist)

          # dbg({prevdist == dist, prevdist, dist})
          keep_paths = if prevdist == dist, do: Map.get(paths, pos), else: MapSet.new()
          # dbg(keep_paths)

          newpaths =
            MapSet.union(curpaths, keep_paths)
            |> MapSet.put(pos)

          paths = Map.put(paths, pos, newpaths)

          queue = Heap.push(queue, dpos)
          dists = Map.put(dists, pos, dist)
          {queue, dists, paths}
        end)

      find_path(map, queue, dists, paths, goalpos)
    end

    # case Heap.pop(queue) do
    #   nil ->
    #     raise "wat"

    #   {dist, pos} ->
    #     nil
    # end
  end

  def solve1 do
    {map, _} = input_map_with_size()

    {startloc, @start} = Enum.find(map, fn {_, v} -> v == @start end)
    {endloc, @fin} = Enum.find(map, fn {_, v} -> v == @fin end)

    map =
      Map.put(map, startloc, @empty)
      |> Map.put(endloc, @empty)

    startpos = {startloc, @startdir}

    # by insepction
    goalpos = {endloc, {0, 1}}

    heap =
      Heap.new()
      |> Heap.push({0, startpos})

    dists = %{startpos => 0}
    paths = %{startpos => MapSet.new([startpos])}
    find_path(map, heap, dists, paths, goalpos)
  end

  def solve2 do
  end
end
