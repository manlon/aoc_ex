defmodule AocEx.Aoc2016Ex.Day19 do
  use AocEx.Day, year: 2016, day: 19
  import Enum

  @num 3_012_210

  def do_steals([elf], []), do: elf
  def do_steals([], acc), do: do_steals(reverse(acc), [])
  def do_steals([elf], acc), do: do_steals([elf | reverse(acc)], [])

  def do_steals([{e1, p1}, {_e2, p2} | rest], acc) do
    do_steals(rest, [{e1, p1 + p2} | acc])
  end

  def rot(q, 0), do: q

  def rot(q, n) do
    {{:value, v}, q} = :queue.out(q)
    q = :queue.in(v, q)
    rot(q, n - 1)
  end

  def pop(q) do
    {{:value, _v}, q} = :queue.out(q)
    q
  end

  def do_steals_across(list) when is_list(list) do
    len = length(list)
    half = div(len, 2)
    do_steals_across(len, rot(:queue.from_list(list), half))
  end

  def do_steals_across(1, q) do
    {{:value, e}, _} = :queue.out(q)
    e
  end

  def do_steals_across(n, q) do
    q = pop(q)

    q =
      if rem(n, 2) == 1 do
        rot(q, 1)
      else
        q
      end

    do_steals_across(n - 1, q)
  end

  def solve1 do
    elves = for e <- 1..@num, do: {e, 1}

    do_steals(elves, [])
    |> elem(0)
  end

  def solve2 do
    do_steals_across(Enum.to_list(1..@num))
  end
end
