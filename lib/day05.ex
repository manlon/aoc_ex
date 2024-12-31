defmodule Aoc2023Ex.Day05 do
  use Aoc2023Ex.Day, day: 5

  defmodule Parser do
    use Aoc2023Ex.Parser

    line_of_ints = repeat(int() |> ispace()) |> int()
    seeds_line = istr("seeds: ") |> concat(line_of_ints)
    noun = ascii_string([?a..?z], min: 1)
    map_title = noun |> istr("-to-") |> concat(noun) |> istr(" map:\n")

    int_lines = separated(wrap(line_of_ints), istr("\n"))
    map = ignore(map_title) |> concat(int_lines)
    # maps = separated(map, istr("\n\n"))
    # input = seeds_line |> istr("\n\n") |> concat(maps)

    defmatch(:parse_seeds_line, seeds_line)
    defmatch(:parse_map, map)

    def parse_almanac(input) do
      [seed | maps] = String.split(input, "\n\n")
      seeds = parse_seeds_line(seed)

      maps =
        for m <- maps do
          for [dest, src, l] <- parse_map(m) do
            {src..(src + l - 1), dest - src}
          end
        end

      {seeds, maps}
    end
  end

  def solve1 do
    {seeds, maps} = Parser.parse_almanac(input())

    for(s <- seeds, do: {{s, s}, maps})
    |> map_ranges(:infinity)
  end

  def solve2 do
    {seeds, maps} = Parser.parse_almanac(input())

    seed_ranges =
      Enum.chunk_every(seeds, 2)
      |> Enum.map(fn [start, l] -> {start, start + l - 1} end)

    for(range <- seed_ranges, do: {range, maps})
    |> map_ranges(:infinity)
  end

  def map_ranges([], acc), do: acc
  def map_ranges([{{s, _e}, []} | rest], acc), do: map_ranges(rest, Enum.min([s, acc]))
  def map_ranges([{r, [[] | maps]} | rest], acc), do: map_ranges([{r, maps} | rest], acc)

  def map_ranges([{{s, e}, maps = [[{r = rs..re, d} | mapranges] | nextmaps]} | rest], acc) do
    cond do
      s in r and e in r ->
        map_ranges([{{s + d, e + d}, nextmaps} | rest], acc)

      s in r ->
        split_range = [{{s, re}, maps}, {{re + 1, e}, maps}]
        map_ranges(split_range ++ rest, acc)

      e in r ->
        split_range = [{{s, rs - 1}, maps}, {{rs, e}, maps}]
        map_ranges(split_range ++ rest, acc)

      s < rs and e > re ->
        split_range = [{{s, rs - 1}, maps}, {{rs, re}, maps}, {{re + 1, e}, maps}]
        map_ranges(split_range ++ rest, acc)

      true ->
        map_ranges([{{s, e}, [mapranges | nextmaps]} | rest], acc)
    end
  end
end
