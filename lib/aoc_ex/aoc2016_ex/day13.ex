defmodule AocEx.Aoc2016Ex.Day13 do
  use AocEx.Day, year: 2016, day: 13

  @target {31, 39}

  def bits(n), do: for(<<bit::1 <- :binary.encode_unsigned(n)>>, do: bit) |> Enum.sum()

  def is_open?({x, y}) do
    v = bits(x * x + 3 * x + 2 * x * y + y + y * y + 1362)
    rem(v, 2) == 0
  end

  def search([{pos, n} | rest], visited, target) do
    case target do
      ^pos ->
        n

      {:max, x} when n > x ->
        MapSet.size(visited)

      _ ->
        visited = MapSet.put(visited, pos)

        {new_pos, visited} =
          for neighb <- four_neighbors(pos),
              {r, c} = neighb,
              r >= 0 and c >= 0,
              neighb not in visited,
              is_open?(neighb),
              reduce: {[], visited} do
            {acc, visited} ->
              {[{neighb, n + 1} | acc], visited}
          end

        search(rest ++ new_pos, visited, target)
    end
  end

  def solve1 do
    search([{{1, 1}, 0}], MapSet.new([{1, 1}]), @target)
  end

  def solve2 do
    search([{{1, 1}, 0}], MapSet.new([{1, 1}]), {:max, 50})
  end
end
