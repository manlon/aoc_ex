defmodule Aoc2023Ex.Day05 do
  use Aoc2023Ex.Day

  defmodule Parser do
    use Aoc2023Ex.Parser

    line_of_ints = repeat(int() |> ispace()) |> int()
    seeds_line = istr("seeds: ") |> concat(line_of_ints)
    noun = ascii_string([?a..?z], min: 1)
    map_title = noun |> istr("-to-") |> concat(noun) |> istr(" map:\n")

    int_lines = separated(wrap(line_of_ints), istr("\n"))
    map = map_title |> concat(int_lines)
    maps = separated(map, istr("\n\n"))

    input = seeds_line |> istr("\n\n") |> concat(maps)

    defmatch(:parse_seeds_line, seeds_line)
    defmatch(:parse_map, map)

    def parse_almanac(input) do
      [seed | maps] = String.split(input, "\n\n")
      seeds = parse_seeds_line(seed)
      maps = for m <- maps, do: parse_map(m)
      {seeds, maps}
    end
  end

  def solve1 do
    {seeds, maps} = Parser.parse_almanac(input())

    for(s <- seeds, do: map_seed(s, maps))
    |> Enum.min()
  end

  def solve2 do
    {seeds, maps} = Parser.parse_almanac(input())

    seed_ranges =
      Enum.chunk_every(seeds, 2)
      |> Enum.map(fn [start, l] -> {start, start + l - 1} end)

    maps = for [_, _ | map] <- maps, do: map

    pairs = for range <- seed_ranges, do: {range, maps}

    map_ranges(pairs, :infinity)
  end

  def map_seed(seed, []), do: seed

  def map_seed(seed, [[_, _ | map] | maps]) do
    range =
      Enum.find(map, fn [_deststart, srcstart, l] ->
        seed in srcstart..(srcstart + l - 1)
      end)

    case range do
      nil ->
        map_seed(seed, maps)

      [deststart, srcstart, _l] ->
        map_seed(deststart + (seed - srcstart), maps)
    end
  end

  def map_ranges([], acc), do: acc
  def map_ranges([{{s, e}, []} | rest], acc), do: map_ranges(rest, Enum.min([s, acc]))

  def map_ranges([{{s, e}, [[] | maps]} | rest], acc) do
    map_ranges([{{s, e}, maps} | rest], acc)
  end

  def map_ranges([{{s, e}, maps = [map = [[dest, src, l] | maprest] | nextmaps]} | rest], acc) do
    srcrange = src..(src + l - 1)

    cond do
      s in srcrange and e in srcrange ->
        d = dest - src
        map_ranges([{{s + d, e + d}, nextmaps} | rest], acc)

      s in srcrange ->
        split_range = [{{s, src + l - 1}, maps}, {{src + l, e}, maps}]

        map_ranges(split_range ++ rest, acc)

      e in srcrange ->
        split_range = [{{s, src - 1}, maps}, {{src, e}, maps}]
        map_ranges(split_range ++ rest, acc)

      s < src and e > src + l - 1 ->
        split_range = [{{s, src - 1}, maps}, {{src, src + l - 1}, maps}, {{src + l, e}, maps}]
        map_ranges(split_range ++ rest, acc)

      true ->
        map_ranges([{{s, e}, [maprest | nextmaps]} | rest], acc)
    end
  end
end
