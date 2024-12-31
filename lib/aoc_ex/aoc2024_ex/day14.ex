defmodule AocEx.Aoc2024Ex.Day14 do
  def input do
    AocEx.Day.input_file_contents(2024, 14)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(fn [a, b] -> {parse_rule(a), parse_rule(b)} end)
  end

  def parse_rule(rule) do
    Regex.scan(~r/^.=(-?\d+),(-?\d+)$/, rule)
    |> then(fn [[_, x, y]] -> {String.to_integer(x), String.to_integer(y)} end)
  end

  @dimx 101
  @dimy 103

  def tick({{x, y}, {dx, dy}}, ticks) do
    {x, y} = {rem(x + dx * ticks, @dimx), rem(y + dy * ticks, @dimy)}
    {rem(x + @dimx, @dimx), rem(y + @dimy, @dimy)}
  end

  def solve1() do
    positions =
      input()
      |> Enum.map(fn pair -> tick(pair, 100) end)

    midx = div(@dimx - 1, 2)
    midy = div(@dimy - 1, 2)
    q1 = Enum.count(positions, fn {x, y} -> x < midx && y < midy end)
    q2 = Enum.count(positions, fn {x, y} -> x > midx && y < midy end)
    q3 = Enum.count(positions, fn {x, y} -> x < midx && y > midy end)
    q4 = Enum.count(positions, fn {x, y} -> x > midx && y > midy end)
    q1 * q2 * q3 * q4
  end

  def map(positions) do
    for y <- 0..(@dimy - 1) do
      [
        for x <- 0..(@dimx - 1) do
          if MapSet.member?(positions, {x, y}) do
            "X"
          else
            "."
          end
        end
        | "\n"
      ]
    end
    |> IO.write()

    :ok
  end

  def solve2 do
    inp = input()

    midx = div(@dimx - 1, 2)
    midy = div(@dimy - 1, 2)

    for i <- 1..100_000_000 do
      positions =
        inp
        |> Enum.map(fn pair -> tick(pair, i) end)

      _q1 = Enum.count(positions, fn {x, y} -> x < midx && y < midy end)
      _q2 = Enum.count(positions, fn {x, y} -> x > midx && y < midy end)
      _q3 = Enum.count(positions, fn {x, y} -> x < midx && y > midy end)
      _q4 = Enum.count(positions, fn {x, y} -> x > midx && y > midy end)

      _mids = Enum.count(positions, fn {x, _y} -> x == midx end)
      # dbg(mids)

      # lefts =
      #   Enum.filter(positions, fn {x, y} -> x == 0 end)
      #   |> Enum.map(fn {x, y} -> y end)
      #   |> Enum.sort()

      # rights =
      #   Enum.filter(positions, fn {x, y} -> x == @dimx - 1 end)
      #   |> Enum.map(fn {x, y} -> y end)
      #   |> Enum.sort()

      if rem(i, 100_000) == 0 do
        dbg(i)
      end

      # if q1 == q2 && q3 == q4 && lefts == rights do
      # if q1 == q2 && q3 == q4 do
      if rem(i, 101) == rem(317, 101) do
        IO.puts("After #{i} seconds:")
        map(MapSet.new(positions))
        IO.puts("\n---\n")
        Process.sleep(200)
      end

      # end
    end

    :ok
  end
end
