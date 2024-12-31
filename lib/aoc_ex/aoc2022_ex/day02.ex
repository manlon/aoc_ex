defmodule AocEx.Aoc2022Ex.Day02 do
  use AocEx.Day, year: 2022, day: 2

  @lookup %{
    "X" => :rock,
    "Y" => :paper,
    "Z" => :scissors,
    "A" => :rock,
    "B" => :paper,
    "C" => :scissors
  }

  @result_code %{
    "X" => :lose,
    "Y" => :draw,
    "Z" => :win
  }

  @scores %{rock: 1, paper: 2, scissors: 3}

  def solve1 do
    input_lines()
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [opp, me] -> score_round(@lookup[opp], @lookup[me]) end)
    |> Enum.sum()
  end

  def solve2 do
    input_lines()
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [opp, me] ->
      score_round(@lookup[opp], resolve(@lookup[opp], @result_code[me]))
    end)
    |> Enum.sum()
  end

  def score_round(opp, me) do
    win_pts(opp, me) + @scores[me]
  end

  def win_pts(opp, opp), do: 3
  def win_pts(:rock, :paper), do: 6
  def win_pts(:rock, :scissors), do: 0
  def win_pts(:paper, :rock), do: 0
  def win_pts(:paper, :scissors), do: 6
  def win_pts(:scissors, :rock), do: 6
  def win_pts(:scissors, :paper), do: 0

  def resolve(opp, :draw), do: opp
  def resolve(:rock, :win), do: :paper
  def resolve(:rock, :lose), do: :scissors
  def resolve(:paper, :win), do: :scissors
  def resolve(:paper, :lose), do: :rock
  def resolve(:scissors, :win), do: :rock
  def resolve(:scissors, :lose), do: :paper
end
