defmodule AocEx.Aoc2019Ex.Day23 do
  use AocEx.Day, year: 2019, day: 23

  def input_prog do
    hd(input_line_ints())
    |> :array.from_list()
  end

  @state_idx 0..49
  @nat 255

  @idle_threshold 5
  def idle?(node_states) do
    Enum.all?(node_states, fn {_, {_prog, _ctr, _inputs, _outputs, _r, idle_ct}} ->
      idle_ct >= @idle_threshold
    end)
  end

  def nat_stream(node_states) do
    Stream.iterate(0, &(&1 + 1))
    |> Stream.transform({node_states, nil}, fn i, {node_states, last_nat} ->
      {node_states, set_last_nat, nat_delivered} = tick(node_states, i, last_nat)
      last_nat = set_last_nat || last_nat
      enum = if nat_delivered, do: [nat_delivered], else: []
      {enum, {node_states, last_nat}}
    end)
  end

  def tick(node_states), do: tick(node_states, 0, nil)

  def tick(node_states, _ticks, last_nat) do
    idle? = idle?(node_states)

    {node_states, nat_delivered} =
      if idle? do
        node_states =
          update_in(node_states, [0, Access.elem(2)], &(&1 ++ last_nat))
          |> put_in([0, Access.elem(5)], 0)

        {node_states, last_nat}
      else
        {node_states, nil}
      end

    node_states =
      for i <- @state_idx, into: %{} do
        {prog, ctr, inputs, outputs, r, idle_ct} = node_states[i]

        st =
          case run_program(prog, ctr, inputs, outputs, r, 1) do
            {:cont, prog, ctr, inputs, outputs, r} ->
              {prog, ctr, inputs, outputs, r, idle_ct}

            {:wait, prog, ctr, outputs, r} ->
              {:cont, prog, ctr, inputs, outputs, r} = run_program(prog, ctr, [-1], outputs, r, 1)
              {prog, ctr, inputs, outputs, r, idle_ct + 1}
          end

        {i, st}
      end

    {node_states, set_last_nat} =
      Enum.reduce(@state_idx, {node_states, nil}, fn i, {node_states, set_last_nat} ->
        case node_states[i] do
          {_prog, _ctr, _inputs, [o1, o2, o3 | outputs], _r, _idle?} ->
            # dbg({:packet, [tick: ticks], [from: i], [o1, o2, o3]})

            node_states =
              put_in(node_states, [i, Access.elem(3)], outputs)
              |> put_in([i, Access.elem(5)], 0)

            if o1 == @nat do
              set_last_nat = [o2, o3]
              {node_states, set_last_nat}
            else
              node_states =
                update_in(node_states, [o1, Access.elem(2)], &(&1 ++ [o2, o3]))
                |> put_in([o1, Access.elem(5)], 0)

              {node_states, set_last_nat}
            end

          _ ->
            {node_states, set_last_nat}
        end
      end)

    {node_states, set_last_nat, nat_delivered}

    # tick(node_states, ticks + 1, last_nat)
  end

  def solve1 do
    prog = input_prog()

    node_states =
      for i <- @state_idx, into: %{} do
        {i, {prog, 0, [i], [], 0, 0}}
      end

    # tick(node_states)
    nat_stream(node_states)
    |> Enum.take(1)
    |> case do
      [[_x, y]] -> y
    end
  end

  def solve2 do
    prog = input_prog()

    node_states =
      for i <- @state_idx, into: %{} do
        {i, {prog, 0, [i], [], 0, 0}}
      end

    # tick(node_states)
    nat_stream(node_states)
    |> Enum.reduce_while(nil, fn [_x, y], last ->
      if last == nil or last != y do
        {:cont, y}
      else
        {:halt, y}
      end
    end)
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
    Enum.zip([codes, modes])
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
    [_v1, _v2] = read_values(program, [p1, p2], modes, relative_offset)
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
