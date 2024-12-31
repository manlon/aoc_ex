defmodule AocEx.Aoc2022Ex.Day11 do
  use AocEx.Day, year: 2022, day: 11

  def parse_input, do: Map.new(Enum.map(stanza_lines(), &parse_monkey/1))

  def parse_monkey([lbl, items, op, mod, monkey_true, monkey_false]) do
    label = hd(line_ints(lbl))
    items = line_ints(items)
    op = parse_operation(Enum.at(String.split(op, "= old "), 1))
    mod = hd(line_ints(mod))
    monkey_true = hd(line_ints(monkey_true))
    monkey_false = hd(line_ints(monkey_false))
    {label, {items, op, mod, monkey_true, monkey_false, 0}}
  end

  def parse_operation(<<op::binary-size(1), " old">>), do: {op, "old"}
  def parse_operation(<<op::binary-size(1), " ", rhs::binary>>), do: {op, String.to_integer(rhs)}

  def do_round(monkeys, mod, div_by_3, n) do
    monkeys =
      Enum.reduce(monkeys, monkeys, fn {k, _}, monkeys ->
        {items, {op, operand}, testmod, mtrue, mfalse, count} = monkeys[k]

        monkeys =
          put_in(monkeys, [k, Access.elem(0)], [])
          |> put_in([k, Access.elem(5)], count + length(items))

        Enum.reduce(items, monkeys, fn item, monkeys ->
          opval = if operand == "old", do: item, else: operand
          newval = if op == "+", do: item + opval, else: item * opval
          newval = if div_by_3, do: div(newval, 3), else: rem(newval, mod)
          new_monkey = if rem(newval, testmod) == 0, do: mtrue, else: mfalse
          update_in(monkeys, [new_monkey, Access.elem(0)], &(&1 ++ [newval]))
        end)
      end)

    if n == 1, do: monkeys, else: do_round(monkeys, mod, div_by_3, n - 1)
  end

  def solve1(n \\ 20, div_by_3 \\ true) do
    monkeys = parse_input()
    mod = Enum.product(for {_, {_, _, mod, _, _, _}} <- monkeys, do: mod)

    do_round(monkeys, mod, div_by_3, n)
    |> Enum.map(fn {_, monkey} -> elem(monkey, 5) end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
  end

  def solve2, do: solve1(10000, false)
end
