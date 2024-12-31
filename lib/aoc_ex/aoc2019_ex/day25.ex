defmodule AocEx.Aoc2019Ex.Day25 do
  use AocEx.Day, year: 2019, day: 25
  alias AocEx.Combos

  def input_prog do
    input_line_ints()
    |> hd()
    |> :array.from_list()
  end

  def setup_moves do
    [
      ~c'west\n',
      ~c'take space law space brochure\n',
      ~c'north\n',
      ~c'take loom\n',
      ~c'south\n',
      ~c'south\n',
      ~c'take hologram\n',
      ~c'west\n',
      ~c'take manifold\n',
      ~c'east\n',
      ~c'north\n',
      ~c'east\n',
      ~c'north\n',
      ~c'take mutex\n',
      ~c'east\n',
      ~c'east\n',
      ~c'east\n',
      ~c'take whirled peas\n',
      ~c'west\n',
      ~c'west\n',
      ~c'west\n',
      ~c'south\n',
      ~c'south\n',
      ~c'take cake\n',
      ~c'west\n',
      ~c'south\n',
      ~c'take easter egg\n',
      ~c'south\n'
    ]
    |> Enum.concat()
  end

  def all_items do
    [
      ~c'space law space brochure',
      ~c'loom',
      ~c'hologram',
      ~c'manifold',
      ~c'mutex',
      ~c'whirled peas',
      ~c'cake',
      ~c'easter egg'
    ]
  end

  def drop_all_items() do
    for i <- all_items() do
      ~c'drop ' ++ i ++ ~c'\n'
    end
    |> Enum.concat()
  end

  def take_items(items) do
    for i <- items do
      ~c'take ' ++ i ++ ~c'\n'
    end
    |> Enum.concat()
  end

  def solve1 do
    program = input_prog()
    setup = setup_moves() ++ ~c'inv\n'

    {:wait, prog, ctr, outputs, r} = run_until_wait(program, 0, setup, [], 0, true)

    Combos.subsets(all_items())
    |> Enum.reduce_while({prog, ctr, outputs, r}, fn set, {prog, ctr, _outputs, r} ->
      inp = drop_all_items() ++ take_items(set) ++ ~c'south\n'

      case run_until_wait(prog, ctr, inp, [], r) do
        {:wait, prog, ctr, _outputs, r} ->
          {:cont, {prog, ctr, [], r}}

        {:stop, _prog, _i, _inputs, outputs, _r} ->
          {:halt, outputs}
      end
    end)
    |> IO.puts()
  end

  def solve2 do
    :ok
  end

  def interact(prog, ctr, inputs, outputs, r) do
    case run_until_wait(prog, ctr, inputs, outputs, r) do
      {:wait, prog, ctr, outputs, r} ->
        IO.puts(outputs)

        input =
          IO.gets(">> ")
          |> String.to_charlist()

        interact(prog, ctr, input, [], r)

      {:stop, _prog, _ctr, _inputs, outputs, _r} ->
        IO.puts(outputs)
    end
  end

  def run_until_wait(
        program,
        pointer,
        inputs,
        outputs,
        r,
        print_immediate \\ false
      ) do
    case run_program(program, pointer, inputs, outputs, r) do
      stuff = {:wait, _prog, _i, _outputs, _r} ->
        stuff

      {:cont, prog, i, inputs, outputs, r} ->
        if print_immediate do
          IO.write(outputs)
          run_until_wait(prog, i, inputs, [], r, true)
        else
          run_until_wait(prog, i, inputs, outputs, r)
        end

      x ->
        x
    end
  end

  # @codenames %{
  #   1 => "ADD",
  #   2 => "MULT",
  #   3 => "INPUT",
  #   4 => "OUTPUT",
  #   5 => "JMP-TRUE",
  #   6 => "JMP-FALSE",
  #   7 => "LT",
  #   8 => "EQ",
  #   9 => "OFFSET",
  #   99 => "HALT"
  # }

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
      dbg({arr, i, v})
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

  def run_program(program, i, inputs, outputs, relative_offset),
    do: run_program(program, i, inputs, outputs, relative_offset, :infinity)

  def run_program(program, i, inputs, outputs, relative_offset, 0) do
    {:cont, program, i, inputs, outputs, relative_offset}
  end

  def run_program(program, i, inputs, outputs, relative_offset, num_insts) do
    num_insts = if num_insts == :infinity, do: num_insts, else: num_insts - 1

    [instruction, c1, _c2, c3] = get_chunk(program, i, 4)
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
        |> run_program(i + 4, inputs, outputs, relative_offset, num_insts)

      2 ->
        # mult
        set(program, a3, a1 * a2)
        |> run_program(i + 4, inputs, outputs, relative_offset, num_insts)

      3 ->
        # input
        case take_inputs(inputs) do
          [] ->
            {:wait, program, i, outputs, relative_offset}

          [input | rest] ->
            # IO.puts("processing input #{input} (#{input_left(rest)})")
            # print_game(game)
            set(program, a1, input)
            |> run_program(i + 2, rest, outputs, relative_offset, num_insts)
        end

      4 ->
        # output
        run_program(program, i + 2, inputs, outputs ++ [a1], relative_offset, num_insts)

      5 ->
        # jump-if-true
        pointer =
          if a1 != 0 do
            a2
          else
            i + 3
          end

        run_program(program, pointer, inputs, outputs, relative_offset, num_insts)

      6 ->
        # jump-if-false
        pointer =
          if a1 == 0 do
            a2
          else
            i + 3
          end

        run_program(program, pointer, inputs, outputs, relative_offset, num_insts)

      7 ->
        # less than
        result =
          if a1 < a2 do
            1
          else
            0
          end

        set(program, a3, result)
        |> run_program(i + 4, inputs, outputs, relative_offset, num_insts)

      8 ->
        # equals
        result =
          if a1 == a2 do
            1
          else
            0
          end

        set(program, a3, result)
        |> run_program(i + 4, inputs, outputs, relative_offset, num_insts)

      9 ->
        # adjust relative offset
        run_program(program, i + 2, inputs, outputs, relative_offset + a1, num_insts)

      99 ->
        {:stop, program, i, inputs, outputs, relative_offset}
    end
  end
end
