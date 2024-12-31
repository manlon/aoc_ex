defmodule AocEx.Aoc2016Ex.Day23 do
  use AocEx.Day, year: 2016, day: 23

  def parse_val(val) when val in ["a", "b", "c", "d"], do: val
  def parse_val(val), do: String.to_integer(val)

  def parsed_input do
    for line <- input_tokens() do
      case line do
        ["cpy", x, y] -> {:cpy, parse_val(x), y}
        ["inc", x] -> {:inc, x}
        ["dec", x] -> {:dec, x}
        ["jnz", x, y] -> {:jnz, parse_val(x), parse_val(y)}
        ["tgl", x] -> {:tgl, x}
      end
    end
    |> :array.from_list()
  end

  def get_arg(_reg, arg) when is_integer(arg), do: arg
  def get_arg(reg, c), do: reg[c]

  def compute(_, :halt, regs), do: regs

  def compute(prog, pctr, regs) do
    {regs, pctr, prog} =
      case :array.get(pctr, prog) do
        {:cpy, x, y} when is_integer(x) ->
          {Map.put(regs, y, x), pctr + 1, prog}

        {:cpy, x, y} when is_integer(x) and is_integer(y) ->
          {regs, pctr + 1, prog}

        {:cpy, x, y} ->
          {Map.put(regs, y, regs[x]), pctr + 1, prog}

        {:inc, x} ->
          {Map.update!(regs, x, &(&1 + 1)), pctr + 1, prog}

        {:dec, x} ->
          {Map.update!(regs, x, &(&1 - 1)), pctr + 1, prog}

        {:jnz, x, y} ->
          {regs, if(get_arg(regs, x) != 0, do: pctr + get_arg(regs, y), else: pctr + 1), prog}

        {:tgl, x} ->
          idx = get_arg(regs, x) + pctr

          instr = :array.get(idx, prog)

          prog =
            if instr == :undefined do
              prog
            else
              :array.set(idx, toggle(instr), prog)
            end

          {regs, pctr + 1, prog}

        :undefined ->
          {regs, :halt, prog}
      end

    compute(prog, pctr, regs)
  end

  def toggle({:inc, x}), do: {:dec, x}
  def toggle({_, x}), do: {:inc, x}
  def toggle({:jnz, x, y}), do: {:cpy, x, y}
  def toggle({_, x, y}), do: {:jnz, x, y}

  @regs %{"a" => 7, "b" => 0, "c" => 0, "d" => 0}
  def solve1 do
    parsed_input()
    |> compute(0, @regs)
    |> Map.get("a")
  end

  def solve2 do
    parsed_input()
    |> compute(0, Map.put(@regs, "a", 12))
    |> Map.get("a")
  end
end
