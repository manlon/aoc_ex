defmodule AocEx.Aoc2024Ex.Day17 do
  import Bitwise

  defmodule Computer do
    import Bitwise
    defstruct iptr: 0, prog_array: nil, output: [], regs: %{}, n: 0

    def new(regs, prog) when is_list(prog) do
      regs = %{A: regs["A"], B: regs["B"], C: regs["C"]}
      %__MODULE__{prog_array: :array.from_list(prog), regs: regs, n: length(prog)}
    end

    def set_reg(comp, reg, val) do
      %{comp | regs: Map.put(comp.regs, reg, val)}
    end

    def prog(comp) do
      :array.to_list(comp.prog_array)
    end

    def combo_val(comp, val) do
      cond do
        val in 0..3 -> val
        val == 4 -> comp.regs[:A]
        val == 5 -> comp.regs[:B]
        val == 6 -> comp.regs[:C]
        true -> raise "Invalid value: #{val}"
      end
    end

    @adv 0
    @bxl 1
    @bst 2
    @jnz 3
    @bxc 4
    @out 5
    @bdv 6
    @cdv 7
    @opnames %{
      0 => "adv",
      1 => "bxl",
      2 => "bst",
      3 => "jnz",
      4 => "bxc",
      5 => "out",
      6 => "bdv",
      7 => "cdv"
    }

    @combo_ops [@adv, @bst, @out, @bdv, @cdv]

    def inspect_operand(op, operand) do
      if op in @combo_ops do
        cond do
          operand in 0..3 -> operand
          operand == 4 -> "A"
          operand == 5 -> "B"
          operand == 6 -> "C"
        end
      else
        operand
      end
    end

    def inspect_comp(comp) do
      """
      Computer<iptr: #{comp.iptr}, regs: #{inspect(comp.regs)}, output: #{inspect(comp.output)} >

      """
    end

    def inspect_prog(comp = %__MODULE__{}) do
      prog(comp)
      |> Enum.chunk_every(2)
      |> Enum.map(fn [op, operand] ->
        opname = @opnames[op]
        "#{opname} #{inspect_operand(op, operand)}"
      end)
      |> Enum.join("\n")
    end

    def run_op(comp) do
      if comp.iptr + 1 >= comp.n do
        {:halt, {Enum.reverse(comp.output), comp}}
      else
        op = :array.get(comp.iptr, comp.prog_array)
        operand = :array.get(comp.iptr + 1, comp.prog_array)
        # dbg(op: @opnames[op], operand: operand, regs: comp.regs)
        regs = comp.regs

        {regs, iptr, output} =
          case op do
            @adv ->
              num = comp.regs[:A]
              denom = 2 ** combo_val(comp, operand)
              {%{regs | A: div(num, denom)}, comp.iptr + 2, []}

            @bxl ->
              {%{regs | B: bxor(regs[:B], operand)}, comp.iptr + 2, []}

            @bst ->
              {%{regs | B: rem(combo_val(comp, operand), 8)}, comp.iptr + 2, []}

            @jnz ->
              if comp.regs[:A] == 0 do
                {regs, comp.iptr + 2, []}
              else
                {regs, operand, []}
              end

            @bxc ->
              {%{regs | B: bxor(regs[:B], regs[:C])}, comp.iptr + 2, []}

            @out ->
              val = rem(combo_val(comp, operand), 8)
              {regs, comp.iptr + 2, [val]}

            @bdv ->
              num = comp.regs[:A]
              denom = 2 ** combo_val(comp, operand)
              {%{regs | B: div(num, denom)}, comp.iptr + 2, []}

            @cdv ->
              num = comp.regs[:A]
              denom = 2 ** combo_val(comp, operand)
              {%{regs | C: div(num, denom)}, comp.iptr + 2, []}
          end

        # dbg(regs: regs, output: output)
        {:cont, %{comp | regs: regs, iptr: iptr, output: output ++ comp.output}}
      end
    end

    def run(comp) do
      case(run_op(comp)) do
        {:halt, output} -> output
        {:cont, comp} -> run(comp)
      end
    end
  end

  def input do
    AocEx.Day.input_file_contents(2024, 17)
    |> String.split("\n\n", trim: true)
    |> then(fn [regs, prog] ->
      {Enum.map(String.split(regs, "\n"), &parse_reg/1) |> Map.new(), parse_prog(prog)}
    end)
    |> then(fn {regs, prog} -> Computer.new(regs, prog) end)
  end

  def parse_reg(reg) do
    Regex.scan(~r/Register (.): (\d+)$/, reg)
    |> then(fn [[_, x, y]] -> {x, String.to_integer(y)} end)
  end

  def parse_prog(prog) do
    Regex.scan(~r/Program: (.*)$/, prog)
    |> then(fn [[_, prog]] ->
      String.split(prog, ",", trim: true) |> Enum.map(&String.to_integer/1)
    end)
  end

  def set_reg_and_run(comp, n, debug \\ false) do
    comp2 = Computer.set_reg(comp, :A, n)
    {output, comp2} = Computer.run(comp2)

    if debug do
      prog = Computer.prog(comp)
      dbg(n)
      dbg(out: output, prog: prog)
      dbg(regs: comp2.regs)
    end

    output
  end

  def munge(n) do
    Integer.digits(n, 2)
    |> Enum.chunk_every(3)
    |> Enum.reverse()
    |> List.flatten()
    |> Integer.undigits(2)
  end

  def detect_quine(comp, n \\ 1, step \\ 1, limit \\ :inf)
  def detect_quine(_, _, _, 0), do: :fail

  def detect_quine(comp, n, step, limit) do
    # munged = munge(n)
    munged = n
    output = set_reg_and_run(comp, munged)
    # IO.inspect({n, munged, output}, charlists: :as_lists)
    lim = if limit == :inf, do: :inf, else: limit - 1

    prog = Computer.prog(comp)

    if(List.ends_with?(prog, output)) do
      IO.inspect({"partial", n, Integer.to_string(n, 2), prog, output}, charlists: :as_lists)
    end

    if output == Computer.prog(comp) do
      munged
    else
      detect_quine(comp, n + step, step, lim)
    end
  end

  def solve1 do
    # comp = Computer.new(%{"A" => 2024, "B" => 0, "C" => 0}, [0, 1, 5, 4, 3, 0])
    comp = input()
    {output, _} = Computer.run(comp)
  end

  def solve2(start \\ 0) do
    comp = input()
    # dbg(Computer.prog(comp))
    # 13800000
    # detect_quine(comp, start)
    # heap =
    #   Heap.new()
    #   |> Heap.push({0, []})

    heap = [{0, []}]

    grow_until_quine(comp, heap)
  end

  def grow_until_quine(comp, q = [{n, output} | rest]) do
    dbg(length(q))
    prog = Computer.prog(comp)

    if output == prog do
      n
    else
      nextvals = boop(comp, n)
      grow_until_quine(comp, nextvals ++ rest)
    end
  end

  def boop(comp, previnput) do
    prog = Computer.prog(comp)
    shifted = previnput <<< 3

    0..7
    |> Enum.map(fn n ->
      val = shifted + n
      {val, set_reg_and_run(comp, val)}
    end)
    |> Enum.filter(fn {n, output} -> List.ends_with?(prog, output) end)
  end
end
