defmodule AocEx.Aoc2016Ex.Day11 do
  use AocEx.Day, year: 2016, day: 11
  import AocEx.Combos, only: [combos: 2]

  # @input """
  # The first floor contains a polonium generator, a thulium generator, a thulium-compatible microchip, a promethium generator, a ruthenium generator, a ruthenium-compatible microchip, a cobalt generator, and a cobalt-compatible microchip.
  # The second floor contains a polonium-compatible microchip and a promethium-compatible microchip.
  # The third floor contains nothing relevant.
  # The fourth floor contains nothing relevant.
  # """

  @start %{
    0 => [
      {:g, :polonium},
      {:g, :thulium},
      {:m, :thulium},
      {:g, :promethium},
      {:g, :ruthenium},
      {:m, :ruthenium},
      {:g, :cobalt},
      {:m, :cobalt}
    ],
    1 => [{:m, :polonium}, {:m, :promethium}],
    2 => [],
    3 => []
  }

  def start_state, do: @start

  def chips(stuff) do
    for item = {type, _} <- stuff, type == :m do
      item
    end
  end

  def gens(stuff) do
    for item = {type, _} <- stuff, type == :g do
      item
    end
  end

  def covered?({:m, var}, stuff), do: {:g, var} in stuff

  def compat?(stuff) when is_map(stuff) do
    Map.values(stuff)
    |> Enum.all?(&compat?/1)
  end

  def compat?(stuff) when is_list(stuff) do
    chips = chips(stuff)
    Enum.all?(chips, &covered?(&1, stuff))
  end

  def move(state, items, src, dest) do
    Map.update!(state, src, &(&1 -- items))
    |> Map.update!(dest, &(items ++ &1))
  end

  def find_floor(state, item) do
    Enum.find(state, fn {_, stuff} ->
      item in stuff
    end)
    |> elem(0)
  end

  def hash(n, state) do
    floor_s =
      3..0//-1
      |> Enum.map(fn i ->
        gens = gens(state[i])

        for {:g, what} <- gens do
          find_floor(state, {:m, what})
        end
        |> Enum.sort()
        |> Enum.join()
      end)
      |> Enum.join("|")

    "#{n}:#{floor_s}"
  end

  def done?(floor, state) do
    (floor == 3 && state[0] == []) and state[1] == [] and state[2] == []
  end

  def bfs([{n, floor, state} | rest], visited) do
    if done?(floor, state) do
      n
    else
      on_floor = state[floor]

      floor_up = if floor + 1 <= 3, do: [floor + 1], else: []

      floor_down =
        if floor - 1 >= 0 and Enum.any?(0..(floor - 1), &(!Enum.empty?(state[&1]))) do
          [floor - 1]
        else
          []
        end

      floors = floor_up ++ floor_down
      items = combos(on_floor, 1) ++ combos(on_floor, 2)

      {new_states, visited} =
        for f <- floors,
            take <- items,
            new_state = move(state, take, floor, f),
            hash = hash(f, new_state),
            reduce: {[], visited} do
          {acc, visited} ->
            if hash in visited do
              {acc, visited}
            else
              if rem(MapSet.size(visited), 1000) == 0 do
                dbg({n, length(rest), Enum.count(visited), hash})
              end

              {[{n + 1, f, new_state} | acc], MapSet.put(visited, hash)}
            end
        end

      bfs(rest ++ new_states, visited)
    end
  end

  def solve1 do
    bfs([{0, 0, @start}], MapSet.new())
  end

  def solve2 do
    state =
      @start
      |> Map.update!(
        0,
        &[{:g, :elerium}, {:m, :elerium}, {:g, :dilithium}, {:m, :dilithium} | &1]
      )

    bfs([{0, 0, state}], MapSet.new())
  end
end
