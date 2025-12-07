defmodule AocEx.Aoc2025Ex.Day07 do
  use AocEx.Day, day: 7, year: 2025

  def compute_splits(map, {maxrow, maxcol}) do
    for row <- 0..maxrow, col <- 0..maxcol, reduce: {%{}, 0} do
      {paths, count} ->
        case map[{row, col}] do
          "S" ->
            {Map.put(paths, {row, col}, 1), count}

          "." ->
            above = Map.get(paths, {row - 1, col}, 0)

            left_splitter =
              if map[{row, col - 1}] == "^" do
                Map.get(paths, {row - 1, col - 1}, 0)
              else
                0
              end

            right_splitter =
              if map[{row, col + 1}] == "^" do
                Map.get(paths, {row - 1, col + 1}, 0)
              else
                0
              end

            total = above + left_splitter + right_splitter
            {Map.put(paths, {row, col}, total), count}

          "^" ->
            count = if Map.get(paths, {row - 1, col}, 0) > 0, do: count + 1, else: count
            {paths, count}

          _ ->
            {paths, count}
        end
    end
  end

  def solve1() do
    {map, size} = input_map_with_size()
    {_, count} = compute_splits(map, size)
    count
  end

  def solve2() do
    {map, size = {maxrow, _maxcol}} = input_map_with_size()
    {paths, _} = compute_splits(map, size)
    last_paths = for {{^maxrow, _}, n} <- paths, do: n
    Enum.sum(last_paths)
  end
end
