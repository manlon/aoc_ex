defmodule AocEx.Aoc2022Ex.Day19 do
  use AocEx.Day, year: 2022, day: 19

  def blueprints do
    for [id, o_o, c_o, ob_o, ob_c, g_o, g_ob] <- input_line_ints(),
        into: %{} do
      {id,
       [
         {{0, 0, 0, 1}, {g_o, 0, g_ob, 0}},
         {{0, 0, 1, 0}, {ob_o, ob_c, 0, 0}},
         {{0, 1, 0, 0}, {c_o, 0, 0, 0}},
         {{1, 0, 0, 0}, {o_o, 0, 0, 0}}
       ]}
    end
  end

  # 4-vector math helpers
  def add({a1, b1, c1, d1}, {a2, b2, c2, d2}), do: {a1 + a2, b1 + b2, c1 + c2, d1 + d2}
  def mult(scalar, {v1, v2, v3, v4}), do: {scalar * v1, scalar * v2, scalar * v3, scalar * v4}
  def sub(a, b), do: add(a, mult(-1, b))
  def dot({a1, a2, a3, a4}, {b1, b2, b3, b4}), do: {a1 * b1, a2 * b2, a3 * b3, a4 * b4}
  def max_vec({a, b, c, d}, {w, x, y, z}), do: {max(a, w), max(b, x), max(c, y), max(d, z)}
  def max_robots(bp), do: for({_, costs} <- bp, do: costs) |> Enum.reduce(&max_vec/2)
  def elsum({a, b, c, d}), do: a + b + c + d

  # divide function to calculate time to generate amt of a resource with given number of robots
  def safe_div(amt, _) when amt <= 0, do: 0
  def safe_div(_, 0), do: :infinity
  def safe_div(amt, robots) when rem(amt, robots) == 0, do: div(amt, robots)
  def safe_div(amt, robots), do: div(amt, robots) + 1

  # time needed to earn the _resources vector with the given numbers of _robots
  def time_to_earn(_resources = {c1, c2, c3, c4}, _robots = {r1, r2, r3, r4}) do
    Enum.max([safe_div(c1, r1), safe_div(c2, r2), safe_div(c3, r3), safe_div(c4, r4)])
  end

  # Assume we can only build one robot per round. Then there is no use
  # considering building a robot if we already have as many as the maximum cost
  # in that resource, because we already have enough robots to afford anything
  # in one tick of that resource.
  def filter_maxed_robots(bp, max_robots, robots) do
    Enum.filter(bp, fn
      # always consider building geode bots
      {{_, _, _, 1}, _} -> true
      {robot_vec, _} -> elsum(dot(robot_vec, robots)) < elsum(dot(robot_vec, max_robots))
    end)
  end

  # true if can't surpass best even if we buy a geode robot on every remaining tick
  defguard lacks_potential?(n, geodes, gbots, best)
           when div(n * (n - 1), 2) + n * gbots + geodes <= best

  # result if we build no more robots
  def result_without_builds({n, {_, _, _, geodes}, {_, _, _, gbots}}), do: n * gbots + geodes

  def search(bp, time), do: dfs(bp, max_robots(bp), {time, {0, 0, 0, 0}, {1, 0, 0, 0}}, 0)

  def dfs(_, _, {n, _inv = {_, _, _, geodes}, _robots = {_, _, _, gbots}}, best)
      when lacks_potential?(n, geodes, gbots, best),
      do: best

  def dfs(bp, max_robots, state = {n, inventory, robots}, best) do
    best = max(result_without_builds(state), best)

    filter_maxed_robots(bp, max_robots, robots)
    |> Enum.reduce(best, fn {robot_vec, cost_vec}, best ->
      remaining_cost = sub(cost_vec, inventory)

      case time_to_earn(remaining_cost, robots) do
        # can't build this robot with robots we have
        :infinity ->
          best

        # can't build this robot in time
        ticks when n - ticks < 2 ->
          best

        # we'll have the resources for this robot after ticks, will build after ticks + 1
        ticks ->
          ticks = ticks + 1
          new_inventory = add(sub(inventory, cost_vec), mult(ticks, robots))
          new_robots = add(robots, robot_vec)
          dfs(bp, max_robots, {n - ticks, new_inventory, new_robots}, best)
      end
    end)
  end

  def solve1 do
    Enum.sum(for({id, bp} <- blueprints(), do: id * search(bp, 24)))
  end

  def solve2 do
    bps = blueprints()
    Enum.product(for(id <- [1, 2, 3], do: search(Map.get(bps, id), 32)))
  end
end
