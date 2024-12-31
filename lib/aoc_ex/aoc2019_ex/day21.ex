defmodule AocEx.Aoc2019Ex.Day21 do
  defmacro dbg!(clause) do
    quote do
      label = "[#{__ENV__.file}:#{__ENV__.line}] #{unquote(Macro.to_string(clause))}"
      IO.inspect(unquote(clause), label: label)
    end
  end

  def input do
    AocEx.Day.input_file_contents(2019, 20)
    |> parse_input()
  end

  def parse_input(s) do
    s
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
    |> :array.from_list(0)
  end

  def solve1 do
    program = input()
  end

  def solve2 do
    program = input()
  end

  @codenames %{
    1 => "ADD",
    2 => "MULT",
    3 => "INPUT",
    4 => "OUTPUT",
    5 => "JMP-TRUE",
    6 => "JMP-FALSE",
    7 => "LT",
    8 => "EQ",
    9 => "OFFSET",
    99 => "HALT"
  }

  def read_values(program, codes, modes, relative_offset) do
    List.zip([codes, modes])
    |> Enum.map(fn {code, mode} ->
      case mode do
        0 ->
          get(program, code)

        1 ->
          code

        2 ->
          get(program, code + relative_offset)
      end
    end)
  end

  def write_addr(code, mode, relative_offset) do
    case mode do
      0 ->
        code

      1 ->
        IO.inspect("wut")
        nil

      2 ->
        code + relative_offset
    end
  end

  def args(program, i, modes, relative_offset) do
    [p1, p2] = get_chunk(program, i + 1, 2)
    [v1, v2] = read_values(program, [p1, p2], modes, relative_offset)
  end

  def take_inputs(inputs) do
    # case inputs do
    #  [] ->
    #    []
    #  [[_, 0] | rest] ->
    #    take_inputs(rest)
    #  [[val, count] | rest] ->
    #    [val,  [val, count - 1] | rest]
    # end
    inputs
  end

  def get(_, :undefined) do
    :undefined
  end

  def get(arr, i) do
    :array.get(i, arr)
  end

  def set(arr, i, v) do
    if i < 0 do
      IO.puts("ohnoes")
      dbg!({arr, i, v})
    end

    :array.set(i, v, arr)
  end

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
      |> Kernel.++([0, 0])

    {op, modes}
  end

  def run(program, inp) do
    run_until_wait(program, 0, inp, [], 0, [])
  end

  def inp do
    """
    NOT A J
    NOT B T
    AND T J
    NOT C T
    AND T J
    AND D J
    NOT B T
    WALK
    """
    |> String.to_charlist()
  end

  def run_until_wait(program, pointer, inputs, outputs, r, processed_inputs) do
    case run_program(program, pointer, inputs, outputs, r, processed_inputs) do
      {:wait, prog, i, outputs, r, processed_inputs} = w ->
        w

      {:cont, prog, i, inputs, outputs, r, processed_inputs} ->
        run_until_wait(prog, i, inputs, outputs, r, processed_inputs)

      {:stop, _prog, _i, _inputs, outputs, _r, _processed_inputs} ->
        IO.puts(outputs)
        :stop

      x ->
        x
    end
  end

  def run_program(program, i, inputs, outputs, relative_offset, last_input) do
    [instruction, c1, c2, c3] = get_chunk(program, i, 4)
    {op, modes} = decompose_op(instruction)

    # opname = @codenames[op]

    [a1, a2, a3] =
      case op do
        3 ->
          # input write-to arg is the first arg
          [m1 | _] = modes
          [write_addr(c1, m1, relative_offset), nil, nil]

        opcode when opcode in [4, 9] ->
          [a1 | _] = args(program, i, modes, relative_offset)
          [a1, nil, nil]

        99 ->
          [nil, nil, nil]

        _ ->
          # everything else uses the third arg
          [a1, a2] = args(program, i, modes, relative_offset)
          [_, _, m3 | _] = modes
          a3 = write_addr(c3, m3, relative_offset)
          [a1, a2, a3]
      end

    case op do
      1 ->
        # add
        set(program, a3, a1 + a2)
        |> run_program(i + 4, inputs, outputs, relative_offset, last_input)

      2 ->
        # mult
        set(program, a3, a1 * a2)
        |> run_program(i + 4, inputs, outputs, relative_offset, last_input)

      3 ->
        # input
        case take_inputs(inputs) do
          [] ->
            {:wait, program, i, outputs, relative_offset, last_input}

          [input | rest] ->
            # IO.puts("processing input #{input} (#{input_left(rest)})")
            # print_game(game)
            set(program, a1, input)
            |> run_program(i + 2, rest, outputs, relative_offset, [input | last_input])
        end

      4 ->
        # output
        {:cont, program, i + 2, inputs, outputs ++ [a1], relative_offset, last_input}

      5 ->
        # jump-if-true
        pointer =
          if a1 != 0 do
            a2
          else
            i + 3
          end

        run_program(program, pointer, inputs, outputs, relative_offset, last_input)

      6 ->
        # jump-if-false
        pointer =
          if a1 == 0 do
            a2
          else
            i + 3
          end

        run_program(program, pointer, inputs, outputs, relative_offset, last_input)

      7 ->
        # less than
        result =
          if a1 < a2 do
            1
          else
            0
          end

        set(program, a3, result)
        |> run_program(i + 4, inputs, outputs, relative_offset, last_input)

      8 ->
        # equals
        result =
          if a1 == a2 do
            1
          else
            0
          end

        set(program, a3, result)
        |> run_program(i + 4, inputs, outputs, relative_offset, last_input)

      9 ->
        # adjust relative offset
        run_program(program, i + 2, inputs, outputs, relative_offset + a1, last_input)

      99 ->
        {:stop, program, i, inputs, outputs, relative_offset, last_input}
    end
  end
end
