defmodule AocEx.Aoc2025Ex.Day11 do
  use AocEx.Day, day: 11, year: 2025

  def parsed_input() do
    input_lines()
    |> Enum.map(fn line ->
      [src, dests] = String.split(line, ": ", trim: true)
      dests = MapSet.new(String.split(dests, " ", trim: true))
      {src, dests}
    end)
    |> Map.new()
  end

  @you "you"
  @out "out"
  @svr "svr"
  @dac "dac"
  @fft "fft"

  def paths(src, dest) do
    {ct, _} = paths(src, dest, parsed_input(), Map.new())
    ct
  end

  def paths(dest, dest, _, memo) do
    {1, memo}
  end

  def paths(loc, dest, map, memo) do
    if Map.has_key?(memo, loc) do
      {memo[loc], memo}
    else
      outputs =
        Map.get(map, loc, [])

      {ct, memo} =
        Enum.reduce(outputs, {0, memo}, fn next, {c1, memo} ->
          {c2, memo} = paths(next, dest, map, memo)
          {c1 + c2, memo}
        end)

      memo = Map.put(memo, loc, ct)
      {ct, memo}
    end
  end

  def solve1() do
    paths(@you, @out)
  end

  def solve2() do
    seg1 = paths(@svr, @fft)
    seg2 = paths(@fft, @dac)
    seg3 = paths(@dac, @out)

    # assert there are no paths from @dac to @fft (DAG)
    0 = paths(@dac, @fft)

    seg1 * seg2 * seg3
  end
end
