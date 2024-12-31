defmodule AocEx.Aoc2016Ex.Day17 do
  use AocEx.Day, year: 2016, day: 17
  import Enum

  @code "yjjvjgan"
  # @code "ihgpwlah"
  @dirs ~c'UDLR'
  @open ~c'bcdef'
  @start {0, 0}
  @target {3, 3}

  def locks(path) do
    :erlang.md5("#{@code}#{path}")
    |> Base.encode16(case: :lower)
    |> String.slice(0..3)
    |> String.to_charlist()
    |> map(&(&1 in @open))
    |> then(&zip(@dirs, &1))
    |> Map.new()
  end

  def possible_moves({x, y}, path) do
    locks = locks(path)

    [{?L, {x - 1, y}}, {?U, {x, y - 1}}, {?R, {x + 1, y}}, {?D, {x, y + 1}}]
    |> filter(fn {_, {x, y}} -> x >= 0 and y >= 0 and x <= 3 and y <= 3 end)
    |> filter(fn {dir, _} -> locks[dir] end)
  end

  def search([{@target, path} | _rest], acc, 1), do: [reverse(path) | acc]
  def search([], acc, _), do: acc
  def search([{@target, path} | rest], acc, nil), do: search(rest, [reverse(path) | acc], nil)

  def search([{loc, path} | rest], acc, n) do
    new_states =
      for {dir, new_loc} <- possible_moves(loc, reverse(path)) do
        {new_loc, [dir | path]}
      end

    search(rest ++ new_states, acc, n)
  end

  def solve1, do: hd(search([{@start, ~c''}], [], 1))
  def solve2, do: length(hd(search([{@start, ~c''}], [], nil)))
end
