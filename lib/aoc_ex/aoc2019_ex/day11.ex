defmodule AocEx.Aoc2019Ex.Day11 do
  defmacro dbg!(clause) do
    quote do
      label = "[#{__ENV__.file}:#{__ENV__.line}] #{unquote(Macro.to_string(clause))}"
      IO.inspect(unquote(clause), label: label)
    end
  end

  def input do
    AocEx.Day.input_file_contents(2019, 11)
    |> parse_input
  end

  def parse_input(s) do
    s
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
    |> :array.from_list(0)
  end

  def set(arr, i, v) do
    if i < 0 do
      IO.puts("ohnoes")
      dbg!({arr, i, v})
    end

    :array.set(i, v, arr)
  end

  def get(_, :undefined) do
    :undefined
  end

  def get(arr, i) do
    :array.get(i, arr)
  end

  def turn(dir, inst) do
    case dir do
      {0, 1} ->
        case inst do
          # left
          0 ->
            {-1, 0}

          1 ->
            {1, 0}
        end

      {1, 0} ->
        case inst do
          0 ->
            {0, 1}

          1 ->
            {0, -1}
        end

      {0, -1} ->
        case inst do
          0 ->
            {1, 0}

          1 ->
            {-1, 0}
        end

      {-1, 0} ->
        case inst do
          0 ->
            {0, -1}

          1 ->
            {0, 1}
        end
    end
  end

  def advance(_robot = {pos, direction}, turn_instruction) do
    {dx, dy} = turn(direction, turn_instruction)
    {x, y} = pos
    new_pos = {x + dx, y + dy}
    {new_pos, {dx, dy}}
  end

  @black 0
  @white 1

  def part1 do
    program = input()

    run_paint_program(program, 0, [@black], [], 0, %{}, {{0, 0}, {0, 1}})
    |> Enum.count()
  end

  def part2 do
    program = input()

    painted = run_paint_program(program, 0, [@white], [], 0, %{}, {{0, 0}, {0, 1}})

    whites =
      Map.keys(painted)
      |> Enum.filter(fn pos -> Map.get(painted, pos) == @white end)

    ys = whites |> Enum.map(fn {_, y} -> y end)
    xs = whites |> Enum.map(fn {x, _} -> x end)

    miny = ys |> Enum.min()
    maxy = ys |> Enum.max()
    minx = xs |> Enum.min()
    maxx = xs |> Enum.max()

    maxy..miny
    |> Enum.map(fn y ->
      minx..maxx
      |> Enum.map(fn x ->
        if Map.get(painted, {x, y}) == @white do
          "#"
        else
          " "
        end
      end)
      |> Enum.join()
    end)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def apply_robot_outputs(robot, outputs, canvas, result \\ []) do
    case outputs do
      [color, turn | rest] ->
        {pos, _} = robot
        canvas = Map.put(canvas, pos, color)
        robot = advance(robot, turn)
        {new_pos, _} = robot
        result = result ++ [Map.get(canvas, new_pos, @black)]
        apply_robot_outputs(robot, rest, canvas, result)

      [] ->
        {canvas, robot, result}
    end
  end

  def run_paint_program(program, pointer, inputs, outputs, relative_offset, canvas, robot) do
    case run_program(program, pointer, inputs, outputs, relative_offset) do
      {:stop, _, _, _, _, _} ->
        canvas

      {:wait, prog, i, outputs, r} ->
        {canvas, robot, inputs} = apply_robot_outputs(robot, outputs, canvas)
        run_paint_program(prog, i, inputs, [], r, canvas, robot)
    end
  end

  def run_chained_programs(chain, last_output \\ [])

  def run_chained_programs([], result) do
    result
  end

  def run_chained_programs(
        [_unit = {_state, prog, pointer, inputs, outputs, relative_offset} | rest],
        last_output
      ) do
    case run_program(prog, pointer, inputs ++ last_output, outputs, relative_offset) do
      {:stop, _, _, _, outputs, _relative_offset} ->
        run_chained_programs(rest, outputs)

      {:wait, prog, i, inputs, outputs, _r, relative_offset} ->
        run_chained_programs(rest ++ [{:wait, prog, i, inputs, [], relative_offset}], outputs)
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
      |> Kernel.++([0, 0])

    {op, modes}
  end

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

  def run_program(program, i, inputs, outputs, relative_offset) do
    [instruction, c1, c2, c3] = get_chunk(program, i, 4)
    {op, modes} = decompose_op(instruction)

    opname = @codenames[op]

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
        |> run_program(i + 4, inputs, outputs, relative_offset)

      2 ->
        # mult
        set(program, a3, a1 * a2)
        |> run_program(i + 4, inputs, outputs, relative_offset)

      3 ->
        # input
        case inputs do
          [] ->
            {:wait, program, i, outputs, relative_offset}

          [input | rest] ->
            set(program, a1, input)
            |> run_program(i + 2, rest, outputs, relative_offset)
        end

      4 ->
        # output
        run_program(program, i + 2, inputs, outputs ++ [a1], relative_offset)

      5 ->
        # jump-if-true
        pointer =
          if a1 != 0 do
            a2
          else
            i + 3
          end

        run_program(program, pointer, inputs, outputs, relative_offset)

      6 ->
        # jump-if-false
        pointer =
          if a1 == 0 do
            a2
          else
            i + 3
          end

        run_program(program, pointer, inputs, outputs, relative_offset)

      7 ->
        # less than
        result =
          if a1 < a2 do
            1
          else
            0
          end

        set(program, a3, result)
        |> run_program(i + 4, inputs, outputs, relative_offset)

      8 ->
        # equals
        result =
          if a1 == a2 do
            1
          else
            0
          end

        set(program, a3, result)
        |> run_program(i + 4, inputs, outputs, relative_offset)

      9 ->
        # adjust relative offset
        run_program(program, i + 2, inputs, outputs, relative_offset + a1)

      99 ->
        {:stop, program, i, inputs, outputs, relative_offset}
    end
  end
end
