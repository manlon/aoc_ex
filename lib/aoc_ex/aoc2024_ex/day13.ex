defmodule AocEx.Aoc2024Ex.Day13 do
  def input do
    AocEx.Day.input_file_contents(2024, 13)
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn block -> String.split(block, "\n", trim: true) end)
    |> Enum.map(fn [b1, b2, p] -> {parse_button(b1), parse_button(b2), parse_prize(p)} end)
  end

  def parse_button(button) do
    Regex.scan(~r/^Button .: X\+(\d+), Y\+(\d+)$/, button)
    |> then(fn [[_, x, y]] -> {String.to_integer(x), String.to_integer(y)} end)
  end

  def parse_prize(prize) do
    Regex.scan(~r/^Prize: X=(\d+), Y=(\d+)$/, prize)
    |> then(fn [[_, x, y]] -> {String.to_integer(x), String.to_integer(y)} end)
  end

  def find_fast(_pyld = {{xa, ya}, {xb, yb}, {xF, yF}}) do
    num = xa * (yF * xb - xF * yb)
    denom = ya * xb - xa * yb

    if rem(num, denom) == 0 do
      x_from_a = div(num, denom)

      if rem(x_from_a, xa) == 0 do
        push_a = div(x_from_a, xa)
        push_b = div(xF - x_from_a, xb)
        [{push_a, push_b}]
      else
        []
      end
    else
      []
    end
  end

  @adj 10_000_000_000_000
  def adjust({btna, btnb, {xF, yF}}), do: {btna, btnb, {xF + @adj, yF + @adj}}

  def score({a, b}), do: 3 * a + b

  def best_score(scores) do
    case scores do
      [] -> 0
      [i] -> score(i)
    end
  end

  def solve1 do
    input()
    |> Enum.map(&find_fast/1)
    |> Enum.map(&best_score/1)
    |> Enum.sum()
  end

  def solve2 do
    input()
    |> Enum.map(&adjust/1)
    |> Enum.map(&find_fast/1)
    |> Enum.map(&best_score/1)
    |> Enum.sum()
  end
end
