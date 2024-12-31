defmodule Aoc2023Ex.Day07 do
  use Aoc2023Ex.Day, day: 7

  defmodule Parser do
    @face %{"T" => 10, "J" => 11, "Q" => 12, "K" => 13, "A" => 14}
    @face_jok %{@face | "J" => 0}
    def parsed_input(ranks \\ @face) do
      for line <- Aoc2023Ex.Day07.input_lines(),
          [hand, num] = String.split(line),
          num = String.to_integer(num),
          hand = Enum.map(String.graphemes(hand), &(ranks[&1] || String.to_integer(&1))) do
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
  @ace 14
  def joker_hand_strength(hand) do
    {jokers, others} = Enum.split_with(hand, &(&1 == @joker))
    Enum.max(all_hand_strengths(length(jokers), [@ace | others], others))
  end

  def all_hand_strengths(0, _deck, hold_cards), do: [hand_strength(hold_cards)]

  def all_hand_strengths(n, deck, hold_cards) do
    Stream.flat_map(deck, &all_hand_strengths(n - 1, deck, [&1 | hold_cards]))
  end

  def score_all_hands(hands, ranker \\ &hand_strength/1) do
    hands
    |> Enum.sort_by(fn {hand, _} -> {ranker.(hand), hand} end)
    |> Enum.with_index(1)
    |> Enum.map(fn {{_hand, score}, i} -> score * i end)
    |> Enum.sum()
  end

  def solve1, do: score_all_hands(Parser.parsed_input())
  def solve2, do: score_all_hands(Parser.parsed_input_jokers(), &joker_hand_strength/1)
end
