defmodule AocEx.Aoc2024Ex.Day18 do
  def input do
    AocEx.Day.input_file_contents(2024, 18)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(fn [a, b] -> {String.to_integer(a), String.to_integer(b)} end)
  end

  defmodule Mem do
    @dirs [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]
    defstruct mem: MapSet.new(), max: {70, 70}

    def addpos({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}

    def new(memlocs) do
      %__MODULE__{mem: MapSet.new(memlocs)}
    end

    def neighbs(_m = %__MODULE__{mem: mem, max: {maxx, maxy}}, pt = {_x, _y}) do
      for d <- @dirs,
          newpt = addpos(pt, d),
          newpt not in mem,
          {nx, ny} = newpt,
          nx in 0..maxx,
          ny in 0..maxy do
        newpt
      end
    end
  end

  def find_path(mem, queue, dists) do
    # dbg(Enum.count(queue))
    goaldist = Map.get(dists, mem.max, :inf)

    if Heap.empty?(queue) do
      :fail
    else
      {{dist, pos}, queue} = Heap.split(queue)

      if dist >= goaldist do
        goaldist
      else
        newdist = dist + 1

        neighbs =
          Mem.neighbs(mem, pos)
          |> Enum.filter(fn p -> newdist < Map.get(dists, p, :inf) end)

        {queue, dists} =
          Enum.reduce(neighbs, {queue, dists}, fn pos, {queue, dists} ->
            queue = Heap.push(queue, {newdist, pos})
            dists = Map.put(dists, pos, newdist)
            {queue, dists}
          end)

        find_path(mem, queue, dists)
      end
    end
  end

  def solve1 do
    mem =
      input()
      |> Enum.take(1024)
      |> Mem.new()

    q = Heap.new()
    q = Heap.push(q, {0, {0, 0}})
    dists = Map.put(%{}, {0, 0}, 0)
    find_path(mem, q, dists)
  end

  def solve2 do
    inp = input()

    Enum.reduce_while(1024..length(inp), nil, fn n, _ ->
      mem = Enum.take(inp, n) |> Mem.new()
      q = Heap.new()
      q = Heap.push(q, {0, {0, 0}})
      dists = Map.put(%{}, {0, 0}, 0)
      res = find_path(mem, q, dists)

      if res == :fail do
        {:halt, n}
      else
        {:cont, nil}
      end
    end)
    |> then(fn n -> Enum.at(inp, n - 1) end)
    |> then(fn {a, b} -> "#{a},#{b}" end)
    |> IO.puts()
  end
end
