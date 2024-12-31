defmodule Aoc2023Ex.Day15 do
  use Aoc2023Ex.Day, day: 15

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

    if idx = Enum.find_index(lenses, fn {l, _fl} -> l == lbl end) do
      List.update_at(lenses, idx, fn _ -> {lbl, val} end)
    else
      lenses ++ [{lbl, val}]
    end
    |> then(&Map.put(acc, box, &1))
  end

  def process([lbl, "-"], acc) do
    Map.update(acc, hash(lbl), [], &Enum.filter(&1, fn {l, _fl} -> l != lbl end))
  end

  def solve1 do
    Enum.sum(for(i <- String.split(input(), ","), do: hash(i)))
  end

  def solve2 do
    boxes = Enum.reduce(Parser.operations(input()), %{}, &process/2)
    Enum.sum(for {box, lenses} <- boxes, do: score_box(box, lenses))
  end

  def score_box(box, lenses) do
    Enum.with_index(lenses, 1)
    |> Enum.map(fn {{_, fl}, i} -> (box + 1) * i * fl end)
    |> Enum.sum()
  end
end
