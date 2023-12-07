defmodule Aoc2023Ex.Day07 do
  use Aoc2023Ex.Day

  defmodule Parser do
    @face %{"T" => 10, "J" => 11, "Q" => 12, "K" => 13, "A" => 14}
    @face_jok %{@face | "J" => 0}
    def parsed_input(ranks \\ @face) do
      for line <- Aoc2023Ex.Day07.input_lines(),
          [hand, num] = String.split(line),
          num = String.to_integer(num),
          hand = String.graphemes(hand),
          hand = Enum.map(hand, fn c -> Map.get(ranks, c, nil) || String.to_integer(c) end) do
        {hand, num}
      end
    end

    def parsed_input_jokers(), do: parsed_input(@face_jok)
  end

  def hand_strength(hand) do
    freqs = Enum.frequencies(hand) |> Map.values() |> Enum.sort(:desc)

    case freqs do
      [5] -> 7
      [4, 1] -> 6
      [3, 2] -> 5
      [3, 1, 1] -> 4
      [2, 2, 1] -> 3
      [2, 1, 1, 1] -> 2
      _ -> 1
    end
  end

  @joker 0
  @other_ranks 2..14
  def joker_hand_strength(hand) do
    others = Enum.filter(hand, fn c -> c != @joker end)
    num_jokers = length(hand) - length(others)

    all_hand_strengths(num_jokers, others)
    |> Enum.max()
  end

  def all_hand_strengths(0, hold_cards), do: [hand_strength(hold_cards)]

  def all_hand_strengths(n, hold_cards) do
    Stream.flat_map(@other_ranks, fn c -> all_hand_strengths(n - 1, [c | hold_cards]) end)
  end

  def solve1 do
    Parser.parsed_input()
    |> Enum.sort_by(fn {hand, _} -> {hand_strength(hand), hand} end)
    |> Enum.with_index(1)
    |> Enum.map(fn {{_hand, score}, i} -> score * i end)
    |> Enum.sum()
  end

  def solve2 do
    Parser.parsed_input_jokers()
    |> Enum.sort_by(fn {hand, _score} -> {joker_hand_strength(hand), hand} end)
    |> Enum.with_index(1)
    |> Enum.map(fn {{_hand, score}, i} -> score * i end)
    |> Enum.sum()
  end
end
