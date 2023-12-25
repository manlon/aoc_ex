defmodule Aoc2023Ex.Day17 do
  use Aoc2023Ex.Day

  def move(loc, dir, n \\ 1)
  def move({r, c}, :n, n), do: {r - n, c}
  def move({r, c}, :e, n), do: {r, c + n}
  def move({r, c}, :s, n), do: {r + n, c}
  def move({r, c}, :w, n), do: {r, c - n}
  @op_dir %{n: :s, s: :n, e: :w, w: :e}
  @start_node {:start, nil, nil}
  def make_graph(map, size = {maxr, maxc}, max_straight \\ 3, min_straight \\ 1) do
    for r <- 0..maxr,
        c <- 0..maxc,
        n <- 1..max_straight,
        d_from <- [:n, :s, :e, :w],
        d_to <- [:n, :s, :e, :w],
        d_to != @op_dir[d_from],
        n < max_straight || d_to != d_from,
        n >= min_straight || d_to == d_from,
        line_from = move({r, c}, @op_dir[d_from], n),
        in_bounds?(size, line_from),
        prev = move({r, c}, @op_dir[d_from]),
        in_bounds?(size, prev),
        next = move({r, c}, d_to),
        in_bounds?(size, next),
        n_next = if(d_to == d_from, do: n + 1, else: 1),
        from = {{r, c}, n, d_from},
        to = {next, n_next, d_to},
        state = {to, Map.get(map, next)},
        reduce: %{} do
      acc ->
        Map.update(acc, from, [state], &[state | &1])
    end
    |> Map.put(@start_node, [{{{1, 0}, 1, :s}, map[{1, 0}]}, {{{0, 1}, 1, :e}, map[{0, 1}]}])
  end

  def shortest(graph, nodes, dists, visited, goal) do
    {{curdist, curnode}, nodes} = Heap.split(nodes)
    min_dist = dists[curnode]

    {curnode_loc, _, _} = curnode

    cond do
      curnode_loc == goal ->
        curdist

      min_dist < curdist ->
        shortest(graph, nodes, dists, visited, goal)

      true ->
        neighbs = Map.get(graph, curnode, [])

        {nodes, dists} =
          for {neighb, dist} <- neighbs, neighb not in visited, reduce: {nodes, dists} do
            {nodes, dists} ->
              newdist = curdist + dist

              if newdist < dists[neighb] do
                dists = Map.put(dists, neighb, newdist)
                nodes = Heap.push(nodes, {newdist, neighb})
                {nodes, dists}
              else
                {nodes, dists}
              end
          end

        visited = MapSet.put(visited, curnode)
        shortest(graph, nodes, dists, visited, goal)
    end
  end

  def in_bounds?({maxr, maxc}, {r, c}), do: r in 0..maxr and c in 0..maxc

  def solve_path(max_straight \\ 3, min_straight \\ 1) do
    {map, size} = input_int_map_with_size()
    g = make_graph(map, size, max_straight, min_straight)
    nodes = Heap.min() |> Heap.push({0, {:start, nil, nil}})
    shortest(g, nodes, %{start: 0}, MapSet.new(), size)
  end

  def solve1, do: solve_path()
  def solve2, do: solve_path(10, 4)
end
