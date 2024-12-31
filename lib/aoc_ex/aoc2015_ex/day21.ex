defmodule AocEx.Aoc2015Ex.Day21 do
  use AocEx.Day, year: 2015, day: 21
  alias AocEx.Combos

  @weapons %{
    # weapon => {cost, damage, armor}
    "Dagger" => {8, 4, 0},
    "Shortsword" => {10, 5, 0},
    "Warhammer" => {25, 6, 0},
    "Longsword" => {40, 7, 0},
    "Greataxe" => {74, 8, 0}
  }
  @armor %{
    "Leather" => {13, 0, 1},
    "Chainmail" => {31, 0, 2},
    "Splintmail" => {53, 0, 3},
    "Bandedmail" => {75, 0, 4},
    "Platemail" => {102, 0, 5}
  }
  @rings %{
    "Damage +1" => {25, 1, 0},
    "Damage +2" => {50, 2, 0},
    "Damage +3" => {100, 3, 0},
    "Defense +1" => {20, 0, 1},
    "Defense +2" => {40, 0, 2},
    "Defense +3" => {80, 0, 3}
  }

  # {hp, damage, armor}
  @enemy {104, 8, 1}
  @hp 100

  def weapons_choices, do: Map.values(@weapons)
  def armor_choices, do: [{0, 0, 0}] ++ Enum.sort(Map.values(@armor))

  def rings_choices do
    rings = Map.values(@rings)

    [[]] ++
      for(r <- rings, do: [r]) ++
      Enum.to_list(Combos.pairs(rings))
  end

  def equip_sum(equip, acc \\ {0, 0, 0})
  def equip_sum([], acc), do: acc

  def equip_sum([{c, d, a} | rest], {cost, damage, armor}),
    do: equip_sum(rest, {c + cost, d + damage, a + armor})

  def equipments() do
    Stream.flat_map(weapons_choices(), fn weapon ->
      Stream.flat_map(armor_choices(), fn armor ->
        Stream.map(rings_choices(), fn rings ->
          [weapon, armor | rings]
        end)
      end)
    end)
  end

  def win?({_, damage, armor}) do
    {e_hp, e_damage, e_armor} = @enemy
    my_hit = max(damage - e_armor, 1)
    e_hit = max(e_damage - armor, 1)
    blows = ceil(e_hp / my_hit)
    e_blows = ceil(@hp / e_hit)
    blows <= e_blows
  end

  def solve1 do
    Stream.map(equipments(), &equip_sum/1)
    |> Stream.filter(&win?/1)
    |> Enum.min()
    |> elem(0)
  end

  def solve2 do
    Stream.map(equipments(), &equip_sum/1)
    |> Stream.filter(fn eq -> !win?(eq) end)
    |> Enum.max()
    |> elem(0)
  end
end
