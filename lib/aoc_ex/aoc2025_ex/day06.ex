defmodule AocEx.Aoc2025Ex.Day06 do
  use AocEx.Day, day: 6, year: 2025

  def problems do
    input_tokens() |> Enum.zip |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(fn [op | args] ->
      [op | Enum.reverse(Enum.map(args, &String.to_integer/1))]
    end)
  end

  def problems2 do
    # @sss
    input_lines()
    |> Enum.map(fn line -> Enum.reverse(String.graphemes(line)) end)
    |> Enum.zip()
    |> Enum.reduce([[]], fn tup, [cur | rest] ->
      str =  Tuple.to_list(tup) |> Enum.join()
      if String.trim(str) == "" do
        [[] , cur | rest]
      else
        op = String.at(str, -1)
        num = String.slice(str, 0..-2//1) |> String.trim() |> String.to_integer()
        cur = if op in ["*", "+"] do
          [op, num | cur]
        else
          [num | cur]
        end
        [cur | rest]
      end
   end)
  end

  def compute(["*" | args]), do: Enum.product(args)
  def compute(["+" | args]), do: Enum.sum(args)

  def solve1() do
    Enum.map(problems(), &compute/1) |> Enum.sum()
  end

  def solve2() do
    Enum.map(problems2(), &compute/1) |> Enum.sum()
  end
end
