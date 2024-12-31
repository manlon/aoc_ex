defmodule Aoc2023Ex.Day22 do
  use Aoc2023Ex.Day

  defmodule Parser do
    use Aoc2023Ex.Parser
    brick = int() |> istr(",") |> int() |> istr(",") |> int()
    line = wrap(brick) |> istr("~") |> wrap(brick)
    defmatch(:parse_line, line)

    def parsed_input do
      Aoc2023Ex.Day22.input_lines()
      |> Enum.map(&parse_line/1)
      |> Enum.map(&Enum.map(&1, fn x -> List.to_tuple(x) end))
      |> Enum.map(&List.to_tuple/1)
    end
  end

  def z, do: Parser.parsed_input()

  def bottom_points(brick = {{x1, y1, z1}, {x2, y2, z2}}) do
    for x <- x1..x2 do
      for y <- y1..y2 do
        {x, y, z1}
      end
    end
    |> List.flatten()
  end

  def lowest(brick = {{_, _, z}, _}), do: z

  def fall_point({x, y, z}), do: {x, y, z - 1}

  def has_point?(_brick = {{x1, y1, z1}, {x2, y2, z2}}, _pt = {xp, yp, zp}) do
    xp in x1..x2 && yp in y1..y2 && zp in z1..z2
  end

  def atop?(b1, b2) do
    bottom_points(b1)
    |> Enum.map(&fall_point/1)
    |> Enum.any?(&has_point?(b2, &1))
  end

  def lock(bricks, settled) do
    num_settled = length(settled)

    {unsettled, settled} =
      Enum.reduce(bricks, {[], settled}, fn brick, {unsettled, settled} ->
        if lowest(brick) == 1 do
          {unsettled, [brick | settled]}
        else
          if Enum.any?(settled, &atop?(brick, &1)) do
            {unsettled, [brick | settled]}
          else
            {[brick | unsettled], settled}
          end
        end
      end)

    if length(settled) == num_settled do
      {unsettled, settled}
    else
      lock(unsettled, settled)
    end
  end

  # assume bricks are not locked
  # def fall([brick | rest], settled, acc) do
  #   if(Enum.any?())
  # end

  def can_settle?(bricks) do
    {bricks, _} = lock(bricks, [])
    Enum.any?(bricks)
  end

  def fall(bricks, settled) do
  end

  def solve1 do
    pts =
      Parser.parsed_input()
      |> then(fn bricks -> lock(bricks, []) end)
  end

  def solve2 do
    :ok
  end
end
