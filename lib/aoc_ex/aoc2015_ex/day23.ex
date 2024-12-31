defmodule AocEx.Aoc2015Ex.Day23 do
  use AocEx.Day, year: 2015, day: 23

  def parsed_input do
    for line <- input_tokens() do
      case line do
        ["jio", reg, num] -> ["jio", String.trim(reg, ","), String.to_integer(num)]
        ["jie", reg, num] -> ["jie", String.trim(reg, ","), String.to_integer(num)]
        ["jmp", num] -> ["jmp", String.to_integer(num)]
        x -> x
      end
    end
    |> :array.from_list()
  end

  def compute(_instructions, :undefined, reg), do: reg

  def compute(instructions, pctr, reg) do
    {reg, pctr} =
      case :array.get(pctr, instructions) do
        :undefined -> {reg, :undefined}
        ["hlf", r] -> {Map.update!(reg, r, &div(&1, 2)), pctr + 1}
        ["tpl", r] -> {Map.update!(reg, r, &(&1 * 3)), pctr + 1}
        ["inc", r] -> {Map.update!(reg, r, &(&1 + 1)), pctr + 1}
        ["jmp", n] -> {reg, pctr + n}
        ["jie", r, n] -> {reg, if(rem(reg[r], 2) == 0, do: pctr + n, else: pctr + 1)}
        ["jio", r, n] -> {reg, if(reg[r] == 1, do: pctr + n, else: pctr + 1)}
      end

    compute(instructions, pctr, reg)
  end

  def solve1 do
    reg = %{"a" => 0, "b" => 0}
    compute(parsed_input(), 0, reg)["b"]
  end

  def solve2 do
    reg = %{"a" => 1, "b" => 0}
    compute(parsed_input(), 0, reg)["b"]
  end
end
