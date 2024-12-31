defmodule AocEx.Aoc2019Ex.Day14 do
  defmacro dbg!(clause) do
    quote do
      label = "[#{__ENV__.file}:#{__ENV__.line}] #{unquote(Macro.to_string(clause))}"
      IO.inspect(unquote(clause), label: label)
    end
  end

  def input do
    AocEx.Day.input_file_contents(2019, 14)
    |> parse_input
  end

  def parse_input(s) do
    s
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.reduce(%{}, fn [inputs, [c, name]], acc ->
      Map.put(acc, name, {c, inputs})
    end)
  end

  def parse_line(line) do
    line
    |> String.split(" => ")
    |> case do
      [inputs, output] ->
        inputs =
          String.split(inputs, ", ")
          |> Enum.map(&parse_chemical/1)

        [inputs, parse_chemical(output)]
    end
  end

  def parse_chemical(chem) do
    chem
    |> String.split(" ")
    |> case do
      [num, name] ->
        [String.to_integer(num), name]
    end
  end

  def part1 do
    ore_for(input(), 1)
  end

  def part2 do
    inp = input()
    ddd(inp, 1, 1)
  end

  def ore_for(inp, fuel) do
    {%{"ORE" => x}, _} = react(inp, %{"FUEL" => fuel}, %{})
    x
  end

  @trillion 1_000_000_000_000

  def ddd(inp, i, _last_try) do
    ore = ore_for(inp, i)

    if ore < @trillion do
      ddd(inp, 2 * i, i)
    else
      binary(inp, div(i, 2), i)
    end
  end

  def binary(inp, lower, upper) do
    guess = div(upper - lower, 2) + lower
    ore = ore_for(inp, guess)

    if ore > @trillion do
      binary(inp, lower, guess)
    else
      if ore_for(inp, guess + 1) > @trillion do
        guess
      else
        binary(inp, guess, upper)
      end
    end
  end

  def rounds(need, made_in_qty) do
    r = div(need, made_in_qty)

    if rem(need, made_in_qty) > 0 do
      r + 1
    else
      r
    end
  end

  def react(rules, required_outputs, extras) do
    if Map.keys(required_outputs) == ["ORE"] do
      {required_outputs, extras}
    else
      item = (Map.keys(required_outputs) -- ["ORE"]) |> hd
      needed = required_outputs[item]
      required_outputs = Map.delete(required_outputs, item)

      have_extra = Map.get(extras, item, 0)
      use_from_extras = Enum.min([have_extra, needed])
      extras = Map.put(extras, item, have_extra - use_from_extras)
      needed = needed - use_from_extras

      {item_made_in_qty, item_inputs} = rules[item]

      required_rounds = rounds(needed, item_made_in_qty)

      required_outputs =
        Enum.reduce(item_inputs, required_outputs, fn [iqty, iname], acc ->
          required_new_units = iqty * required_rounds

          Map.update(acc, iname, required_new_units, fn v ->
            v + required_new_units
          end)
        end)

      extra_items = item_made_in_qty * required_rounds - needed
      extras = Map.update(extras, item, extra_items, fn v -> v + extra_items end)

      react(rules, required_outputs, extras)
    end
  end
end
