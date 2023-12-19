defmodule Aoc2023Ex.Day18 do
  use Aoc2023Ex.Day

  defmodule Parser do
    use Aoc2023Ex.Parser
    dir = choice([string("R"), string("L"), string("U"), string("D")])
    color = istr("(#") |> ascii_string([?a..?f, ?0..?9], 6) |> istr(")")
    line = dir |> ispace() |> int() |> ispace() |> concat(color)
    defmatch(:parse_line, line)

    @dir_digits %{?0 => "R", ?1 => "D", ?2 => "L", ?3 => "U"}
    def parse_big_inst(<<num::binary-size(5), dirdig>>) do
      {String.to_integer(num, 16), @dir_digits[dirdig]}
    end

    def parsed_input() do
      for l <- Aoc2023Ex.Day18.input_lines() do
        [dir, n, color] = parse_line(l)
        [dir, n, parse_big_inst(color)]
      end
    end
  end

  def move(loc, dir, n \\ 1)
  def move({r, c}, "U", n), do: {r - n, c}
  def move({r, c}, "D", n), do: {r + n, c}
  def move({r, c}, "L", n), do: {r, c - n}
  def move({r, c}, "R", n), do: {r, c + n}

  def verticals([[dir, n | _] | moves], loc = {r, c}, acc) do
    newloc = move(loc, dir, n)

    newverts =
      case dir do
        "U" ->
          [{(r - n)..r, c}]

        "D" ->
          [{r..(r + n), c}]

        _ ->
          []
      end

    verticals(moves, newloc, newverts ++ acc)
  end

  def verticals([], _loc, acc), do: acc

  def count_inside_path(moves) do
    start = {0, 0}
    verts = verticals(moves, start, [])
    minrow = Enum.min(for {x.._y, _c} <- verts, do: x)
    maxrow = Enum.max(for {_x..y, _c} <- verts, do: y)

    for r <- minrow..maxrow, reduce: 0 do
      acc ->
        if rem(r, 100_000) == 0 do
          dbg("row: #{r}")
        end

        hits = Enum.filter(verts, fn {x..y, _c} -> r in x..y end)
        acc + count_row(r, hits)
    end
  end

  def count_row(row, verticals) do
    hits =
      Enum.filter(verticals, fn {range, _c} -> row in range end)
      |> Enum.sort_by(fn {_range, c} -> c end)

    {ct, false, _} =
      for {x..y, c} <- hits, reduce: {0, false, nil} do
        {ct, insideness, last_col} ->
          # dbg({ct, insideness, last_col})

          new_insideness =
            cond do
              x == row ->
                case insideness do
                  false ->
                    :edge_top_outside

                  :edge_top_outside ->
                    false

                  :inside ->
                    :edge_top_inside

                  :edge_top_inside ->
                    :inside

                  :edge_bottom_inside ->
                    false

                  :edge_bottom_outside ->
                    :inside
                end

              y == row ->
                case insideness do
                  false ->
                    :edge_bottom_outside

                  :inside ->
                    :edge_bottom_inside

                  :edge_bottom_inside ->
                    :inside

                  :edge_bottom_outside ->
                    false

                  :edge_top_inside ->
                    false

                  :edge_top_outside ->
                    :inside
                end

              true ->
                case insideness do
                  :inside ->
                    false

                  false ->
                    :inside
                end
            end

          flip? = if !(insideness && new_insideness), do: 1, else: 0

          new_ct =
            if insideness do
              ct + (c - last_col) + flip?
            else
              ct
            end

          last_col = c

          {new_ct, new_insideness, last_col}
      end

    ct
  end

  def solve1 do
    count_inside_path(Parser.parsed_input())
  end

  def solve2 do
    moves =
      for [_, _, {n, dir}] <- Parser.parsed_input() do
        [dir, n]
      end

    count_inside_path(moves)
  end
end
