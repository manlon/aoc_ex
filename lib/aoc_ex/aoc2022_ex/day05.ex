defmodule AocEx.Aoc2022Ex.Day05 do
  use AocEx.Day, year: 2022, day: 5

  def instructions do
    input()
    |> String.split("\n\n")
    |> Enum.at(1)
    |> String.split("\n")
    |> Enum.map(fn line ->
      ["move", amt, "from", src, "to", dest] = String.split(line)
      {String.to_integer(amt), src, dest}
    end)
  end

  def initial_state() do
    input()
    |> String.split("\n\n")
    |> Enum.at(0)
    |> String.split("\n")
    |> Enum.reverse()
    |> Enum.map(&String.graphemes/1)
    |> Enum.zip_reduce(Map.new(), fn [lbl | rest], map ->
      Map.put(map, lbl, Enum.drop_while(Enum.reverse(rest), &(&1 == " ")))
    end)
  end

  def perform_instr({amt, src, dest}, stacks, order_fn \\ &Enum.reverse/1) do
    {top, stacks} = Map.get_and_update!(stacks, src, &Enum.split(&1, amt))
    Map.update!(stacks, dest, &(order_fn.(top) ++ &1))
  end

  def solve1(reducer \\ &perform_instr/2) do
    stacks = Enum.reduce(instructions(), initial_state(), reducer)
    Enum.join(for i <- 1..9, do: hd(stacks[to_string(i)]))
  end

  def solve2, do: solve1(fn i, st -> perform_instr(i, st, & &1) end)
end
