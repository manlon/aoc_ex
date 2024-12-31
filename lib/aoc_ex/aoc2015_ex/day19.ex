defmodule AocEx.Aoc2015Ex.Day19 do
  use AocEx.Day, year: 2015, day: 19
  import Enum, only: [map: 2, reduce: 3, reverse: 1]

  def parsed_input do
    [rules, [molecule]] = stanza_lines()

    rules =
      map(rules, &String.split(&1, " => "))
      |> reduce(%{}, fn [el, x], acc ->
        Map.update(acc, el, [x], &[x | &1])
      end)

    {rules, parse_molecule(rules, molecule, [])}
  end

  def parse_molecule(rules, <<el::binary-size(2), rest::binary>>, acc)
      when is_map_key(rules, el) do
    parse_molecule(rules, rest, [el | fix(acc)])
  end

  def parse_molecule(rules, <<el::binary-size(1), rest::binary>>, acc)
      when is_map_key(rules, el) do
    parse_molecule(rules, rest, [el | fix(acc)])
  end

  def parse_molecule(rules, <<c::binary-size(1), rest::binary>>, acc) do
    parse_molecule(rules, rest, accum_non_el(c, acc))
  end

  def parse_molecule(_rules, "", acc), do: reverse(fix(acc))
  def fix({cur, acc}), do: [cur | acc]
  def fix(acc), do: acc
  def accum_non_el(c, {cur, acc}), do: {cur <> c, acc}
  def accum_non_el(c, acc), do: {c, acc}

  def replacements(_rules, str, acc, 0), do: [reverse(acc) ++ str]
  def replacements(_rules, [], _acc, n) when n > 0, do: []

  def replacements(rules, [el | rest], acc, n) when is_map_key(rules, el) do
    Stream.concat([
      Stream.flat_map(rules[el], fn swap ->
        replacements(rules, rest, [swap | acc], n - 1)
      end),
      replacements(rules, rest, [el | acc], n)
    ])
  end

  def replacements(rules, [el | rest], acc, n), do: replacements(rules, rest, [el | acc], n)

  def invert_rules(rules) do
    Enum.reduce(rules, %{}, fn {a, bs}, acc ->
      Enum.reduce(bs, acc, fn b, acc ->
        Map.put(acc, b, a)
      end)
    end)
  end

  def derive(_rules, target, target, n, "", best),
    do: min(n, best)

  def derive(_rules, _target, "", _n, _acc, _best), do: :infinity
  def derive(_rules, _target, _s, n, _acc, best) when n >= best, do: best

  # TODO is this pruning sound?
  def derive(_rules, target, s, n, _acc, best)
      when byte_size(s) - byte_size(target) + n >= best,
      do: best

  def derive(rules, target, s = <<c::binary-size(1), rest::binary>>, n, acc, best) do
    best = derive(rules, target, rest, n, acc <> c, best)

    case Enum.find(rules, fn {x, _} -> String.starts_with?(s, x) end) do
      nil ->
        best

      {x, y} ->
        s = String.slice(s, String.length(x)..-1)

        derive(rules, target, acc <> y <> s, n + 1, "", best)
    end
  end

  def solve1 do
    {rules, mol} = parsed_input()

    Enum.reduce(replacements(rules, mol, [], 1), MapSet.new(), fn seq, set ->
      MapSet.put(set, Enum.join(seq))
    end)
    |> Enum.count()
  end

  def solve2 do
    {rules, mol} = parsed_input()
    rules = invert_rules(rules)
    mol = Enum.join(mol)
    derive(rules, "e", mol, 0, "", :infinity)
  end
end
