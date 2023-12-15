defmodule Aoc2023Ex.Day15 do
  use Aoc2023Ex.Day

  defmodule Parser do
    use Aoc2023Ex.Parser
    label = ascii_string([?a..?z], min: 1)
    predicate = choice([string("=") |> int(), string("-")])
    defmatch(:operations, separated(wrap(concat(label, predicate)), istr(",")))
  end

  def hash(str, acc \\ 0)
  def hash("", acc), do: acc

  def hash(<<x, rest::binary>>, acc) do
    acc = rem((acc + x) * 17, 256)
    hash(rest, acc)
  end

  def process([lbl, "=", val], acc) do
    box = hash(lbl)
    lenses = Map.get(acc, box, [])

    {lenses, updated?} =
      Enum.reduce(lenses, {[], false}, fn {l, fl}, {acc, updated?} ->
        if l == lbl do
          {acc ++ [{lbl, val}], true}
        else
          {acc ++ [{l, fl}], updated?}
        end
      end)

    lenses =
      if updated? do
        lenses
      else
        lenses ++ [{lbl, val}]
      end

    Map.put(acc, box, lenses)
  end

  def process([lbl, "-"], acc) do
    box = hash(lbl)
    lenses = Map.get(acc, box, [])
    lenses = Enum.filter(lenses, fn {l, _fl} -> l != lbl end)
    Map.put(acc, box, lenses)
  end

  def solve1 do
    input()
    |> String.split(",")
    |> Enum.map(&hash/1)
    |> Enum.sum()
  end

  def solve2 do
    filt =
      for x <- Parser.operations(input()), reduce: %{} do
        acc ->
          process(x, acc)
      end

    for {box, lenses} <- filt do
      score_box(box, lenses)
    end
    |>  Enum.sum()
  end

  def score_box(box, lenses) do
    Enum.with_index(lenses, 1)
    |> Enum.map(fn {{_, fl}, i} -> i * fl end)
    |> Enum.map(fn x -> (box + 1) * x end)
    |> Enum.sum()
  end
end
