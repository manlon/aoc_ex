defmodule AocEx.Aoc2015Ex.Day14 do
  use AocEx.Day, year: 2015, day: 14

  def tick(list, 0), do: list

  def tick(list, n) do
    for deer <- list do
      advance(deer)
    end
    |> tick(n - 1)
  end

  def tick2(list, 0), do: list

  def tick2(list, n) do
    deers =
      for {score, deer} <- list do
        {score, advance(deer)}
      end

    {_, {maxdist, _, _, _, _, _}} = Enum.max_by(deers, fn {_, {dist, _, _, _, _, _}} -> dist end)

    for deer = {score, d = {dist, _, _, _, _, _}} <- deers do
      if dist == maxdist do
        {score + 1, d}
      else
        deer
      end
    end
    |> tick2(n - 1)
  end

  def advance({dist, :fly, 0, speed, flytime, resttime}),
    do: {dist, :rest, resttime - 1, speed, flytime, resttime}

  def advance({dist, :fly, flytime, speed, totflytime, resttime}),
    do: {dist + speed, :fly, flytime - 1, speed, totflytime, resttime}

  def advance({dist, :rest, 0, speed, flytime, resttime}),
    do: {dist + speed, :fly, flytime - 1, speed, flytime, resttime}

  def advance({dist, :rest, resttime, speed, flytime, totresttime}),
    do: {dist, :rest, resttime - 1, speed, flytime, totresttime}

  def solve1 do
    for [speed, flytime, resttime] <- input_line_ints() do
      {0, :fly, flytime, speed, flytime, resttime}
    end
    |> tick(2503)
    |> Enum.max()
    |> elem(0)
  end

  def solve2 do
    for [speed, flytime, resttime] <- input_line_ints() do
      {0, {0, :fly, flytime, speed, flytime, resttime}}
    end
    |> tick2(2503)
    |> Enum.max()
    |> elem(0)
  end
end
