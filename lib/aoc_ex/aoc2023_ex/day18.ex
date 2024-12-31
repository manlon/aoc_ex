defmodule AocEx.Aoc2023Ex.Day18 do
  use AocEx.Day, year: 2023, day: 18

  defmodule Parser do
    alias AocEx.Aoc2023Ex.Day18
    use AocEx.Parser
    dir = choice([string("R"), string("L"), string("U"), string("D")])
    color = istr("(#") |> ascii_string([?a..?f, ?0..?9], 6) |> istr(")")
    line = dir |> ispace() |> int() |> ispace() |> concat(color)
    defmatch(:parse_line, line)

    @dir_digits %{?0 => "R", ?1 => "D", ?2 => "L", ?3 => "U"}
    def parse_big_inst(<<num::binary-size(5), dirdig>>) do
      {String.to_integer(num, 16), @dir_digits[dirdig]}
    end

    def parsed_input() do
      for l <- Day18.input_lines() do
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

  def verticals_and_rows(moves, loc, acc \\ {[], []})

  def verticals_and_rows([[dir, n | _] | moves], loc = {r, c}, {verts, rows}) do
    newloc = move(loc, dir, n)

    {newverts, newrows} =
      case dir do
        "U" ->
          {[{(r - n)..r, c}], []}

        "D" ->
          {[{r..(r + n), c}], []}

        _ ->
          {[], [r]}
      end

    verticals_and_rows(moves, newloc, {newverts ++ verts, newrows ++ rows})
  end

  def verticals_and_rows([], _loc, {verts, rows}), do: {verts, Enum.sort(Enum.uniq(rows))}

  def rows_with_surroundings([r], acc), do: Enum.sort(Enum.uniq([r | acc]))

  def rows_with_surroundings([r1, r2 | rest], acc) do
    acc = [r1, r1 + 1, r2 - 1 | acc]
    rows_with_surroundings([r2 | rest], acc)
  end

  def count_inside_path(moves) do
    start = {0, 0}
    {verts, rows} = verticals_and_rows(moves, start)
    rows = rows_with_surroundings(rows, [])
    acc = {_total = 0, _last_row = hd(rows) - 1, _last_row_count = 0}

    {total, _, _} =
      for r <- rows, reduce: acc do
        {total, last_row, last_row_count} ->
          hits = Enum.filter(verts, fn {x..y, _c} -> r in x..y end)
          row_count = count_row(r, hits)
          total = total + row_count + (r - last_row - 1) * last_row_count
          {total, r, row_count}
      end

    total
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
