defmodule AocEx.Aoc2024Ex.Day22 do
  import Bitwise

  def mix(cur, n), do: bxor(cur, n)
  def prune(n), do: rem(n, 16_777_216)

  def input do
    AocEx.Day.input_file_contents(2024, 22)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def evolve(n) do
    n =
      mix(n * 64, n)
      |> prune()

    n =
      mix(n, div(n, 32))
      |> prune()

    n =
      mix(n, n * 2048)
      |> prune

    n
  end

  def evolve_n(n, 0), do: n
  def evolve_n(n, count), do: evolve_n(evolve(n), count - 1)

  def evolve_stream(seed), do: Stream.iterate(seed, &evolve/1)

  def diffs(nums),
    do: Stream.chunk_every(nums, 2, 1, :discard) |> Stream.map(fn [a, b] -> b - a end)

  def seq_results(seed) do
    prices =
      evolve_stream(seed)
      |> Stream.map(&rem(&1, 10))
      |> Enum.take(2000)

    diff_sequences =
      diffs(prices)
      |> Stream.chunk_every(4, 1, :discard)

    price_seqs = Stream.zip(Stream.drop(prices, 4), diff_sequences)

    Enum.reduce(price_seqs, %{}, fn {price, diffs}, acc ->
      if Map.has_key?(acc, diffs) do
        acc
      else
        Map.put(acc, diffs, price)
      end
    end)
  end

  def solve1 do
    # [1, 2, 3, 2024]
    input()
    |> Enum.reduce(%{}, fn seed, acc ->
      Map.merge(acc, seq_results(seed), fn _k, v1, v2 -> v1 + v2 end)
    end)

    # input()
    # |> Enum.map(fn n -> evolve_n(n, 2000) end)
    # |> Enum.sum()
  end
end
