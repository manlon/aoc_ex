defmodule AocEx.Aoc2015Ex.Day16 do
  use AocEx.Day, year: 2015, day: 16
  import String, only: [trim: 2, to_integer: 1]

  @target %{
    "children" => 3,
    "cats" => 7,
    "samoyeds" => 2,
    "pomeranians" => 3,
    "akitas" => 0,
    "vizslas" => 0,
    "goldfish" => 5,
    "trees" => 3,
    "cars" => 2,
    "perfumes" => 1
  }

  def trim_punc(s), do: trim(s, ":") |> trim(",")

  def parsed_input do
    for line <- input_tokens(),
        toks = Enum.map(line, &trim_punc/1),
        ["Sue", id, thing1, n1, thing2, n2, thing3, n3] = toks do
      {to_integer(id),
       [{thing1, to_integer(n1)}, {thing2, to_integer(n2)}, {thing3, to_integer(n3)}]}
    end
  end

  def solve1 do
    parsed_input()
    |> Enum.find(fn {_, stuff} ->
      Enum.all?(stuff, &(&1 in @target))
    end)
    |> elem(0)
  end

  def solve2 do
    parsed_input()
    |> Enum.find(fn {_, stuff} ->
      Enum.all?(stuff, fn {thing, n} ->
        case thing do
          "cats" -> n > @target[thing]
          "trees" -> n > @target[thing]
          "pomeranians" -> n < @target[thing]
          "goldfish" -> n < @target[thing]
          thing -> n == @target[thing]
        end
      end)
    end)
    |> elem(0)
  end
end
