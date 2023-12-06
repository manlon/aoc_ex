defmodule Aoc2023Ex.Day06 do
  use Aoc2023Ex.Day

  defmodule Parser do
    use Aoc2023Ex.Parser
    line_of_ints = repeat(int() |> ispace()) |> int()
    times = istr("Time:") |> ispace() |> concat(line_of_ints)
    dists = istr("Distance: ") |> ispace() |> concat(line_of_ints)
    defmatch(:parse, wrap(times) |> istr("\n") |> concat(wrap(dists)))

    def parse_input(input) do
      parse(input)
      |> Enum.zip()
    end

    def parse_input_2(input) do
      for list <- parse(input) do
        Enum.flat_map(list, &Integer.digits/1)
        |> Integer.undigits()
      end
      |> List.to_tuple()
    end
  end

  def dist_with_time(hold_time, race_time) do
    hold_time * (race_time - hold_time)
  end

  def num_wins(t, dist) do
    0..t
    |> Enum.count(fn n -> dist_with_time(n, t) > dist end)
  end

  def solve1 do
    Parser.parse_input(input())
    |> Enum.map(fn {t, dist} -> num_wins(t, dist) end)
    |> Enum.product()
  end

  def solve2 do
    {time, dist} = Parser.parse_input_2(input())
    num_wins(time, dist)
  end
end
