defmodule AocEx.Aoc2019Ex.Day07 do
  defmacro dbg!(clause) do
    quote do
      label = "[#{__ENV__.file}:#{__ENV__.line}] #{unquote(Macro.to_string(clause))}"
      IO.inspect(unquote(clause), label: label)
    end
  end

  def input do
    AocEx.Day.input_file_contents(2019, 7)
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
    |> :array.from_list()
  end

  def set(arr, i, v) do
    :array.set(i, v, arr)
  end

  def get(_, :undefined) do
    :undefined
  end

  def get(arr, i) do
    :array.get(i, arr)
  end

  def part1 do
    prog = input()

    settings =
      0..4
      |> Enum.to_list()
      |> permutations

    _part1 =
      settings
      |> Enum.map(fn inputs ->
        inputs
        |> Enum.reduce(0, fn setting, last_output ->
          {:stop, _, _, _, outputs} = run_program(prog, 0, [setting, last_output], [])
          hd(outputs)
        end)
      end)
      |> Enum.max()
  end

  def part2 do
    prog = input()

    setting_perms =
      5..9
      |> Enum.to_list()
      |> permutations

    _part2 =
      for settings <- setting_perms do
        inputs = [[hd(settings), 0] | Enum.map(tl(settings), fn x -> [x] end)]

        amps =
          for input <- inputs do
            {:wait, prog, 0, input, []}
          end

        run_chained_programs(amps)
      end
      |> Enum.max()
      |> hd
  end

  def run_chained_programs(chain, last_output \\ [])

  def run_chained_programs([], result) do
    result
  end

  def run_chained_programs([_unit = {_state, prog, pointer, inputs, outputs} | rest], last_output) do
    case run_program(prog, pointer, inputs ++ last_output, outputs) do
      {:stop, _, _, _, outputs} ->
        run_chained_programs(rest, outputs)

      {:wait, prog, i, inputs, outputs} ->
        run_chained_programs(rest ++ [{:wait, prog, i, inputs, []}], outputs)
    end
  end

  def permutations([]), do: [[]]

  def permutations(list),
    do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])

  def get_chunk(arr, i, n) do
    i..(i + n - 1)
    |> Enum.map(&get(arr, &1))
  end

  def decompose_op(opcode) do
    op = rem(opcode, 100)

    modes =
      div(opcode, 100)
      |> Integer.digits()
      |> Enum.reverse()
      |> Kernel.++([0])

    {op, modes}
  end

  def values(program, codes, modes) do
    Enum.zip([codes, modes])
    |> Enum.map(fn {code, mode} ->
      case mode do
        0 ->
          get(program, code)

        1 ->
          code
      end
    end)
  end

  def args(program, i, modes) do
    [p1, p2, p3] = get_chunk(program, i + 1, 3)
    [v1, v2] = values(program, [p1, p2], modes)
    [v1, v2, p3]
  end

  def run_program(program, i, inputs, outputs) do
    {op, modes} = get(program, i) |> decompose_op
    [a1, a2, a3] = args(program, i, modes)

    case op do
      1 ->
        # add
        set(program, a3, a1 + a2)
        |> run_program(i + 4, inputs, outputs)

      2 ->
        # mult
        set(program, a3, a1 * a2)
        |> run_program(i + 4, inputs, outputs)

      3 ->
        # input
        p1 = get(program, i + 1)

        case inputs do
          [] ->
            {:wait, program, i, inputs, outputs}

          [input | rest] ->
            set(program, p1, input)
            |> run_program(i + 2, rest, outputs)
        end

      4 ->
        # output
        run_program(program, i + 2, inputs, outputs ++ [a1])

      5 ->
        # jump-if-true
        pointer =
          if a1 != 0 do
            a2
          else
            i + 3
          end

        run_program(program, pointer, inputs, outputs)

      6 ->
        # jump-if-false
        pointer =
          if a1 == 0 do
            a2
          else
            i + 3
          end

        run_program(program, pointer, inputs, outputs)

      7 ->
        # less than
        result =
          if a1 < a2 do
            1
          else
            0
          end

        set(program, a3, result)
        |> run_program(i + 4, inputs, outputs)

      8 ->
        # equals
        result =
          if a1 == a2 do
            1
          else
            0
          end

        set(program, a3, result)
        |> run_program(i + 4, inputs, outputs)

      99 ->
        {:stop, program, i, inputs, outputs}
    end
  end
end
