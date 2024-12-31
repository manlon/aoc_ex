defmodule AocEx.Aoc2015Ex.Day20 do
  use AocEx.Day, year: 2015, day: 20

  @input 29_000_000

  def factors_of(n) do
    upper_range = floor(:math.sqrt(n))
    factors = for x <- 1..upper_range, rem(n, x) == 0, do: [x, div(n, x)]
    List.flatten(factors) |> Enum.dedup()
  end

  def solve1 do
    Stream.iterate(1, &(&1 + 1))
    |> Stream.map(fn house ->
      presents =
        factors_of(house)
        |> Enum.map(fn n -> n * 10 end)
        |> Enum.sum()

      {house, presents}
    end)
    |> Stream.filter(fn {_, n} -> n >= @input end)
    |> Enum.take(1)
    |> hd()
    |> elem(0)
  end

  def solve2 do
    Stream.iterate(1, &(&1 + 1))
    |> Stream.map(fn house ->
      presents =
        factors_of(house)
        |> Enum.filter(fn fact -> house <= 50 * fact end)
        |> Enum.map(fn n -> n * 11 end)
        |> Enum.sum()

      {house, presents}
    end)
    |> Stream.filter(fn {_, n} -> n >= @input end)
    |> Enum.take(1)
    |> hd()
    |> elem(0)
  end
end
