defmodule AocEx.Aoc2016Ex.Day01 do
  use AocEx.Day, year: 2016, day: 1

  def parsed_input do
    input()
    |> String.split(", ")
    |> Enum.map(fn <<c::binary-size(1), num::binary>> -> {c, String.to_integer(num)} end)
  end

  def turn(:n, "R"), do: :e
  def turn(:e, "R"), do: :s
  def turn(:s, "R"), do: :w
  def turn(:w, "R"), do: :n
  def turn(:n, "L"), do: :w
  def turn(:w, "L"), do: :s
  def turn(:s, "L"), do: :e
  def turn(:e, "L"), do: :n
  def move(:n, n, {x, y}), do: {x, y + n}
  def move(:e, n, {x, y}), do: {x + n, y}
  def move(:s, n, {x, y}), do: {x, y - n}
  def move(:w, n, {x, y}), do: {x - n, y}

  def solve1 do
    Enum.reduce(parsed_input(), {:n, {0, 0}}, fn {turn, steps}, {dir, pos} ->
      dir = turn(dir, turn)
      {dir, move(dir, steps, pos)}
    end)
    |> then(fn {_, {x, y}} -> abs(x) + abs(y) end)
  end

  def solve2 do
    Enum.reduce_while(parsed_input(), {:n, {0, 0}, MapSet.new()}, fn {turn, steps},
                                                                     {dir, pos, visited} ->
      dir = turn(dir, turn)

      {visited, pos, halted?} =
        Enum.reduce_while(1..steps, {visited, pos, false}, fn steps, {visited, _p, _halted} ->
          p = move(dir, steps, pos)

          if p in visited do
            {:halt, {visited, p, true}}
          else
            {:cont, {MapSet.put(visited, p), p, false}}
          end
        end)

      if halted? do
        {:halt, pos}
      else
        {:cont, {dir, pos, visited}}
      end
    end)
    |> then(fn {x, y} -> abs(x) + abs(y) end)
  end
end
