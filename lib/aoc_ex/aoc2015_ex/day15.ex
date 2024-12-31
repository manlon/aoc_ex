defmodule AocEx.Aoc2015Ex.Day15 do
  use AocEx.Day, year: 2015, day: 15

  def solve1 do
    ingrs = input_line_ints()

    Stream.map(amts(100, [], 4), &score(ingrs, &1))
    |> Enum.max()
  end

  def solve2 do
    ingrs = input_line_ints()

    Stream.filter(amts(100, [], 4), &(calories(ingrs, &1) == 500))
    |> Stream.map(&score(ingrs, &1))
    |> Enum.max()
  end

  def amts(sum, acc, 1), do: [[sum | acc]]

  def amts(sum, acc, n) do
    Stream.flat_map(0..sum//1, fn x ->
      amts(sum - x, [x | acc], n - 1)
    end)
  end

  def calories(ingrs, amounts) do
    cals_per_tsp = Enum.map(ingrs, &hd(Enum.reverse(&1)))

    for {cpt, amt} <- Enum.zip(cals_per_tsp, amounts) do
      cpt * amt
    end
    |> Enum.sum()
  end

  def score(ingrs, amounts) do
    for {ingr_spec, amt} <- Enum.zip(ingrs, amounts) do
      for i <- ingr_spec, do: amt * i
    end
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.sum/1)
    |> Enum.map(&max(&1, 0))
    # ignore calories
    |> then(&tl(Enum.reverse(&1)))
    |> Enum.product()
  end
end
