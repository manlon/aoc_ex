defmodule AocEx.Aoc2015Ex.Day22 do
  use AocEx.Day, year: 2015, day: 22

  @boss_hp 51
  @boss_damage 9

  @start_hp 50
  @start_mana 500

  @spells [
    {53, 4, 0, nil},
    {73, 2, 2, nil},
    {113, 0, 0, {:shield, 6}},
    {173, 0, 0, {:poison, 6}},
    {229, 0, 0, {:recharge, 5}}
  ]

  def tick_effects(effects) do
    Enum.map(effects, fn {typ, time} -> {typ, time - 1} end)
    |> Enum.filter(fn {_, time} -> time > 0 end)
  end

  def has_effect?(_effects, nil), do: false
  def has_effect?(effects, {typ, _tim}), do: has_effect?(effects, typ)
  def has_effect?(effects, e), do: Enum.any?(effects, fn {typ, _} -> typ == e end)

  # TODO perf
  def play_turn(_state = {hp, mana, effects, boss_hp}, hard?, played, best) do
    hp = if hard?, do: hp - 1, else: hp

    if cost(played) > best do
      [{:lose_prune, cost(played), played}]
    else
      if hard? && hp <= 0 do
        [{:lose, cost(played), played}]
      else
        boss_hp = if has_effect?(effects, :poison), do: boss_hp - 3, else: boss_hp

        if boss_hp <= 0 do
          [{:win, cost(played), played}]
        else
          mana = if has_effect?(effects, :recharge), do: mana + 101, else: mana
          effects = tick_effects(effects)

          choices =
            @spells
            |> Enum.filter(fn {cost, _damage, _heal, e} ->
              cost <= mana && !has_effect?(effects, e)
            end)

          if choices == [] do
            [{:lose, cost(played), played}]
          else
            Stream.flat_map(choices, fn spell = {cost, damage, heal, eff} ->
              mana = mana - cost
              hp = hp + heal
              effects = if eff, do: [eff | effects], else: effects
              boss_hp = boss_hp - damage
              spells = [spell | played]

              if boss_hp <= 0 do
                [{:win, cost(spells), spells}]
              else
                play_boss_turn({hp, mana, effects, boss_hp}, hard?, spells, best)
              end
            end)
          end
        end
      end
    end
  end

  def play_boss_turn(_state = {hp, mana, effects, boss_hp}, hard?, played, best) do
    boss_hp = if has_effect?(effects, :poison), do: boss_hp - 3, else: boss_hp

    if boss_hp <= 0 do
      [{:win, cost(played), played}]
    else
      mana = if has_effect?(effects, :recharge), do: mana + 101, else: mana
      effects = tick_effects(effects)
      boss_damage = if has_effect?(effects, :shield), do: @boss_damage - 7, else: @boss_damage
      hp = hp - boss_damage

      if hp <= 0 do
        [{:lose, cost(played), played}]
      else
        play_turn({hp, mana, effects, boss_hp}, hard?, played, best)
      end
    end
  end

  def cost(spells) do
    Enum.map(spells, fn {cost, _, _, _} -> cost end)
    |> Enum.sum()
  end

  def solve1 do
    [{_, maxcost, _}] =
      play_turn({@start_hp, @start_mana, [], @boss_hp}, false, [], :infinity)
      |> Stream.filter(fn {result, _, _} -> result == :win end)
      |> Enum.take(1)

    play_turn({@start_hp, @start_mana, [], @boss_hp}, false, [], maxcost)
    |> Stream.filter(fn {result, _, _} -> result == :win end)
    |> Enum.min()
    |> elem(1)
  end

  def solve2 do
    play_turn({@start_hp, @start_mana, [], @boss_hp}, true, [], :infinity)
    |> Stream.filter(fn {result, _, _} -> result == :win end)
    |> Enum.min()
    |> elem(1)
  end
end
