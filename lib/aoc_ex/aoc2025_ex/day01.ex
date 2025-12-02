defmodule AocEx.Aoc2025Ex.Day01 do
  use AocEx.Day, day: 1, year: 2025

  def parsed_input() do
    input_lines()
    |> Enum.map(fn l ->
      {if(String.starts_with?(l, "R"), do: 1, else: -1), String.slice(l, 1..-1//1)}
    end)
    |> Enum.map(fn {d, n} -> {d, String.to_integer(n)} end)
  end

  def turn([], acc), do: acc

  def turn([{dir, n} | rest], acc = [pos | _rest]) do
    newpos = rem(dir * n + pos + 100, 100)
    turn(rest, [newpos | acc])
  end

  def turn2([{dir, n} | rest], pos, acc) do
    hundos = div(n, 100)
    clicks = rem(n, 100)
    newpos = dir * clicks + pos
    pass = if pos != 0 and newpos not in 1..99, do: 1, else: 0
    turn2(rest, rem(newpos + 100, 100), acc + hundos + pass)
  end

  def turn2([], _pos, acc), do: acc

  def solve1() do
    parsed_input()
    |> turn([50])
    |> Enum.count(&(&1 == 0))
  end

  def solve2() do
    parsed_input()
    |> turn2(50, 0)
  end
end
