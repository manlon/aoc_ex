defmodule AocEx.Aoc2016Ex.Day25 do
  use AocEx.Day, year: 2016, day: 25

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
        ["out", x] -> {:out, x}
      end
    end
    |> :array.from_list()
  end

  def get_arg(_reg, arg) when is_integer(arg), do: arg
  def get_arg(reg, c), do: reg[c]

  def compute(_, :halt, regs, output), do: {regs, output}

  def compute(prog, pctr, regs, output) do
    {regs, pctr, prog, output} =
      case :array.get(pctr, prog) do
        {:cpy, x, y} when is_integer(x) ->
          {Map.put(regs, y, x), pctr + 1, prog, output}

        {:cpy, x, y} when is_integer(x) and is_integer(y) ->
          {regs, pctr + 1, prog, output}

        {:cpy, x, y} ->
          {Map.put(regs, y, regs[x]), pctr + 1, prog, output}

        {:inc, x} ->
          {Map.update!(regs, x, &(&1 + 1)), pctr + 1, prog, output}

        {:dec, x} ->
          {Map.update!(regs, x, &(&1 - 1)), pctr + 1, prog, output}

        {:jnz, x, y} ->
          {regs, if(get_arg(regs, x) != 0, do: pctr + get_arg(regs, y), else: pctr + 1), prog,
           output}

        {:out, x} ->
          val = get_arg(regs, x)
          output = [val | output]

          if fail?(output) do
            {regs, :halt, prog, output}
          else
            {regs, pctr + 1, prog, output}
          end

        :undefined ->
          {regs, :halt, prog, output}
      end

    compute(prog, pctr, regs, output)
  end

  def fail?([i]) when i in [1, 0], do: false
  def fail?([1, 0 | _]), do: false
  def fail?([0, 1 | _]), do: false
  def fail?(_), do: true

  @regs %{"a" => 0, "b" => 0, "c" => 0, "d" => 0}

  def solve1 do
    Enum.map(0..1000, fn i ->
      IO.puts(i)
      compute(parsed_input(), 0, Map.put(@regs, "a", i), [])
    end)
  end

  def solve2 do
    :ok
  end
end
