defmodule AocEx.Aoc2025Ex.Day10 do
  import AocEx.Combos, only: [subsets_asc: 1]

  use AocEx.Day, day: 10, year: 2025

  def parse_lights(s) do
    String.slice(s, 1..-2//1)
    |> String.graphemes()
    |> Enum.map(fn c -> %{"#" => 1, "." => 0}[c] end)
    |> Enum.with_index()
    |> Enum.map(fn {v, i} -> {i, v} end)
    |> Map.new()
  end

  def parse_joltage(s) do
    parse_num_list(s)
    |> Enum.with_index()
    |> Enum.map(fn {v, i} -> {i, v} end)
    |> Map.new()
  end

  def parse_num_list(s) do
    String.slice(s, 1..-2//1)
    |> String.split(",")
    |> Enum.map(fn n -> String.to_integer(n) end)
  end

  def parse_line(line) do
    pieces = String.split(line, " ")
    [lights | pieces] = pieces
    {buttons, [joltage]} = Enum.split(pieces, -1)
    lights = parse_lights(lights)
    buttons = Enum.map(buttons, &parse_num_list/1)
    joltage = parse_joltage(joltage)
    {lights, buttons, joltage}
  end

  def parsed_input() do
    input_lines()
    |> Enum.map(&parse_line/1)
  end

  def flip(lightmap, buttons) do
    Enum.reduce(buttons, lightmap, fn button, lightmap ->
      Enum.reduce(button, lightmap, fn b, lightmap ->
        Map.put(lightmap, b, rem(lightmap[b] + 1, 2))
      end)
    end)
  end

  def solve1() do
    for i <- parsed_input() do
      {lightmap, buttons, _} = i

      subsets_asc(buttons)
      |> Stream.drop_while(fn button_set ->
        lightmap = flip(lightmap, button_set)
        Enum.any?(lightmap, fn {_, v} -> v != 0 end)
      end)
      |> Enum.take(1)
      |> hd()
      |> Enum.count()
    end
  end

  def configure_joltage({_, buttons, joltage}) do
    required_counters =
      for {k, v} <- joltage, v > 0, do: k

    subsets_asc(buttons)
    |> Stream.filter(fn button_set ->
      buttons = Enum.uniq(List.flatten(button_set))
      Enum.all?(required_counters, fn k -> k in buttons end)
    end)
  end

  def solve2() do
    [i | _] = parsed_input()
    configure_joltage(i)
  end
end
