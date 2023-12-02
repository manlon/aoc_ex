defmodule Aoc2023Ex.Day02 do
  use Aoc2023Ex.Day

  @colors %{"red" => 12, "green" => 13, "blue" => 14}

  def input_games, do: Enum.map(input_lines(), &parse_line/1)

  def solve1 do
    input_games()
    |> Enum.filter(fn {num, clauses} ->
      Enum.all?(clauses, fn clause ->
        Enum.all?(clause, fn {color, count} ->
          count <= @colors[color]
        end)
      end)
    end)
    |> Enum.map(fn {num, _} -> num end)
    |> Enum.sum()
  end

  def solve2 do
    input_games()
    |> Enum.map(fn {_num, clauses} ->
       Enum.reduce(clauses, %{}, fn clause, acc ->
         Enum.reduce(clause, acc, fn {color, count}, acc ->
           {_, acc} = Map.get_and_update(acc, color, fn c ->
             {c, Enum.max([c || 0, count])}
           end)
           acc
         end)
       end)
       |> Map.values()
       |> Enum.product()
    end)
    |> Enum.sum()
  end

  def parse_line(<<"Game ", rest::binary>>) do
    [num, stuff] = String.split(rest, ": ", parts: 2)
    clauses = String.split(stuff, "; ")

    clauses =
      Enum.map(clauses, fn c ->
        String.split(c, ", ")
        |> Enum.map(fn s ->
          String.split(s, " ")
          |> then(fn [num, color] -> {color, String.to_integer(num)} end)
        end)
        |> Map.new()
      end)

    {String.to_integer(num), clauses}
  end
end
