defmodule AocEx.Aoc2022Ex.Day17 do
  use AocEx.Day, year: 2022, day: 17

  # @test_input ~c'>>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>'

  @rocks [
    [{2, 0}, {3, 0}, {4, 0}, {5, 0}],
    [{2, 1}, {3, 2}, {3, 1}, {3, 0}, {4, 1}],
    [{2, 0}, {3, 0}, {4, 0}, {4, 1}, {4, 2}],
    [{2, 0}, {2, 1}, {2, 2}, {2, 3}],
    [{2, 0}, {3, 0}, {2, 1}, {3, 1}]
  ]

  def print_cave(map, rock \\ nil, ht \\ nil) do
    cave_to_str(map, rock, ht)
    |> IO.puts()

    IO.puts("-------\n")
  end

  def cave_to_str(map, rock \\ nil, ht \\ nil) do
    top = highest(map) + 5
    bottom = lowest(map)

    bottom =
      if ht do
        Enum.max([top - ht, bottom])
      else
        bottom
      end

    for y <- top..bottom//-1 do
      for x <- 0..6 do
        if rock && {x, y} in rock do
          "@"
        else
          Map.get(map, {x, y}, ".")
        end
      end
      |> Enum.join()
    end
    |> Enum.join("\n")
  end

  def jets do
    String.to_charlist(input())
  end

  def translate_rock(rock, {dx, dy}) do
    Enum.map(rock, fn {rx, ry} -> {rx + dx, ry + dy} end)
  end

  def highest(map) do
    Map.keys(map)
    |> Enum.map(fn {_x, y} -> y end)
    # |> Enum.max(fn -> 0 end)
    |> Enum.max(fn -> -1 end)
  end

  def lowest(map) do
    Map.keys(map)
    |> Enum.map(fn {_x, y} -> y end)
    |> Enum.min(fn -> 0 end)
  end

  def fits?(map, rock) do
    Enum.all?(rock, fn r = {x, y} ->
      x >= 0 && x <= 6 && y >= 0 && !Map.has_key?(map, r)
    end)
  end

  def blow_rock(map, rock, jet) do
    blown =
      case jet do
        ?< -> translate_rock(rock, {-1, 0})
        ?> -> translate_rock(rock, {1, 0})
      end

    if fits?(map, blown) do
      blown
    else
      rock
    end
  end

  def settle(map, rock), do: Enum.reduce(rock, map, fn r, map -> Map.put(map, r, "#") end)

  def blocked_height(map) do
    top = highest(map)

    Enum.find(top..0//-1, 0, fn y ->
      Enum.all?(0..6, fn x ->
        Map.has_key?(map, {x, y}) or Map.has_key?(map, {x, y + 1})
      end)
    end)
  end

  def purge(map, d \\ nil) do
    h = highest(map)
    l = if d, do: h - d, else: blocked_height(map)

    Enum.reduce(map, map, fn {{x, y}, _}, map ->
      if y < l do
        Map.delete(map, {x, y})
      else
        map
      end
    end)
  end

  def elevate_map(map, n) do
    Enum.map(map, fn {{x, y}, v} ->
      {{x, y + n}, v}
    end)
    |> Map.new()
  end

  def do_rocks(map, _rocks, _jets, _mod, _jetidx, 0, _), do: map

  def do_rocks(map, rocks = [rock | _], jets, mod, jetidx, n, memo) do
    which_rock = rock
    entry_height = highest(map) + 4
    rock = translate_rock(rock, {0, entry_height})
    {rock, jets, jet_adv} = rock_fall(map, rock, jets)
    jetidx = jetidx + jet_adv

    map =
      settle(map, rock)
      |> purge()

    enc = cave_to_str(map)
    remd = rem(jetidx, mod)
    state_key = {remd, which_rock, enc}

    case memo do
      %{^state_key => {old_n, old_highest}} ->
        num_pieces = old_n - n
        cycle_height = highest(map) - old_highest
        cycles = div(n, num_pieces)
        new_n = n - cycles * num_pieces
        map = elevate_map(map, cycles * cycle_height)
        do_rocks(map, rot(rocks), jets, mod, jetidx, new_n - 1, nil)

      %{} ->
        memo = Map.put(memo, state_key, {n, highest(map)})
        do_rocks(map, rot(rocks), jets, mod, jetidx, n - 1, memo)

      nil ->
        do_rocks(map, rot(rocks), jets, mod, jetidx, n - 1, memo)
    end
  end

  def rock_fall(map, rock, jets = [jet | _], steps \\ 0) do
    # print_cave(map, rock)
    rock = blow_rock(map, rock, jet)
    fallen = translate_rock(rock, {0, -1})
    jets = rot(jets)
    steps = steps + 1

    if(fits?(map, fallen)) do
      rock_fall(map, fallen, jets, steps)
    else
      {rock, jets, steps}
    end
  end

  def rot([first | rest]), do: rest ++ [first]

  def solve1 do
    jj = jets()
    mod = length(jj)

    do_rocks(%{}, @rocks, jj, mod, 0, 2022, %{})
    |> highest()
    |> then(&(&1 + 1))
  end

  def solve2 do
    jj = jets()
    mod = length(jj)
    n = 1_000_000_000_000

    do_rocks(%{}, @rocks, jj, mod, 0, n, %{})
    |> highest()
    |> then(&(&1 + 1))
  end
end
