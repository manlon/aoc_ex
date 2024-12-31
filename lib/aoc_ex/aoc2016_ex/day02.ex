defmodule AocEx.Aoc2016Ex.Day02 do
  use AocEx.Day, year: 2016, day: 2

  @map %{
    1 => %{"R" => 2, "D" => 4},
    2 => %{"R" => 3, "D" => 5, "L" => 1},
    3 => %{"D" => 6, "L" => 2},
    4 => %{"U" => 1, "R" => 5, "D" => 7},
    5 => %{"L" => 4, "U" => 2, "R" => 6, "D" => 8},
    6 => %{"L" => 5, "U" => 3, "D" => 9},
    7 => %{"R" => 8, "U" => 4},
    8 => %{"L" => 7, "U" => 5, "R" => 9},
    9 => %{"L" => 8, "U" => 6}
  }

  @map2 %{
    1 => %{"D" => 3},
    2 => %{"D" => 6, "R" => 3},
    3 => %{"D" => 7, "R" => 4, "L" => 2},
    4 => %{"D" => 8, "L" => 3},
    5 => %{"R" => 6},
    6 => %{"L" => 5, "R" => 7, "U" => 2, "D" => "A"},
    7 => %{"R" => 8, "L" => 6, "U" => 3, "D" => "B"},
    8 => %{"R" => 9, "L" => 7, "U" => 4, "D" => "C"},
    9 => %{"L" => 8},
    "A" => %{"R" => "B", "U" => 6},
    "B" => %{"R" => "C", "L" => "A", "U" => 7, "D" => "D"},
    "C" => %{"L" => "B", "U" => 8},
    "D" => %{"U" => "B"}
  }

  def instructions do
    input_lines() |> Enum.map(&String.graphemes/1)
  end

  def do_moves(map, moves, start \\ 5) do
    Enum.reduce(moves, [start], fn line, digits = [prev | _] ->
      digit =
        Enum.reduce(line, prev, fn move, pos ->
          Map.get(map[pos], move, pos)
        end)

      [digit | digits]
    end)
    |> Enum.reverse()
    |> tl
    |> Enum.join()
  end

  def solve1 do
    do_moves(@map, instructions())
  end

  def solve2 do
    do_moves(@map2, instructions())
  end
end
