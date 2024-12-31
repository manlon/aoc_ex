defmodule AocEx.Aoc2023Ex.Day06 do
  use AocEx.Day, year: 2023, day: 6

  defmodule Parser do
    alias AocEx.Aoc2023Ex.Day06
    use AocEx.Parser
    line_of_ints = repeat(int() |> ispace()) |> int()
    times = istr("Time:") |> ispace() |> concat(line_of_ints)
    dists = istr("Distance: ") |> ispace() |> concat(line_of_ints)
    defmatch(:parse, wrap(times) |> istr("\n") |> concat(wrap(dists)))

    def parsed_input() do
      Enum.zip(parse(Day06.input()))
    end

    def parsed_input_2() do
      for list <- parse(Day06.input()) do
        Enum.flat_map(list, &Integer.digits/1)
        |> Integer.undigits()
      end
      |> List.to_tuple()
    end
  end

  def num_wins(time, dist) do
    z1 = (-time + (time ** 2 - 4 * dist) ** 0.5) / -2
    z2 = (-time - (time ** 2 - 4 * dist) ** 0.5) / -2
    floor(z2) - ceil(z1) + 1
  end

  def solve1 do
    for {t, dist} <- Parser.parsed_input() do
      num_wins(t, dist)
    end
    |> Enum.product()
  end

  def solve2 do
    {time, dist} = Parser.parsed_input_2()
    num_wins(time, dist)
  end
end
