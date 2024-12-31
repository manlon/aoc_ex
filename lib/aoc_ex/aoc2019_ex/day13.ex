defmodule AocEx.Aoc2019Ex.Day13 do
  defmacro dbg!(clause) do
    quote do
      label = "[#{__ENV__.file}:#{__ENV__.line}] #{unquote(Macro.to_string(clause))}"
      IO.inspect(unquote(clause), label: label)
    end
  end

  def input do
    AocEx.Day.input_file_contents(2019, 13)
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

  def part1 do
    program = input()
    {board, _} = run_game(program, 0, [], [], 0, {%{}, 0})

    board
    |> Map.values()
    |> Enum.count(fn tile -> tile == 2 end)
  end

  def part2 do
    program = input()

    run_game(set(program, 0, 2), 0, [], [], 0, {%{}, 0})
    |> elem(1)
  end

  @display_char %{0 => " ", 3 => "O", 4 => "*", 2 => "#"}
  def print_game({board, score}) do
    if Enum.empty?(board) do
      IO.puts("empty board")
    else
      maxx =
        Map.keys(board)
        |> Enum.map(fn {x, y} -> x end)
        |> Enum.max()

      maxy =
        Map.keys(board)
        |> Enum.map(fn {x, y} -> y end)
        |> Enum.max()

      0..maxy
      |> Enum.map(fn y ->
        0..maxx
        |> Enum.map(fn x ->
          i = Map.get(board, {x, y}, 0)
          char = Map.get(@display_char, i, Integer.to_string(i))
        end)
        |> Enum.join()
      end)
      |> Enum.join("\n")
      |> IO.puts()

      IO.puts("SCORE: #{score}")
    end
  end

  def apply_outputs(outputs, game = {board, score}) do
    outputs
    |> Enum.chunk_every(3)
    |> Enum.reduce({game, []}, fn tile, {{board, score}, _} ->
      case tile do
        [-1, 0, newscore] ->
          {{board, newscore}, []}

        [x, y, z] ->
          {{Map.put(board, {x, y}, z), score}, []}

        rest ->
          {{board, score}, rest}
      end
    end)
  end

  def ball_x({board, _}) do
    Enum.find(board, fn {_, b} -> b == 4 end)
    |> case do
      {{x, _}, _} ->
        x
    end
  end

  def paddle_x({board, _}) do
    Enum.find(board, fn {_, b} -> b == 3 end)
    |> case do
      {{x, _}, _} ->
        x
    end
  end

  def run_game(program, pointer, inputs, outputs, relative_offset, game) do
    case run_program(program, pointer, inputs, outputs, relative_offset, game) do
      {:stop, _, _, _, outputs, _} ->
        [outputs, game]
        {game, outputs} = apply_outputs(outputs, game)
        print_game(game)
        game

      {:wait, prog, i, outputs, r} ->
        {game, outputs} = apply_outputs(outputs, game)
        print_game(game)
        # IO.puts "wait"
        inputs =
          cond do
            ball_x(game) < paddle_x(game) ->
              [[-1, 1]]

            ball_x(game) > paddle_x(game) ->
              [[1, 1]]

            true ->
              [[0, 1]]
          end

        Process.sleep(20)
        run_game(prog, i, inputs, outputs, r, game)

      {:cont, prog, i, inputs, outputs, r} ->
        {game, outputs} = apply_outputs(outputs, game)
        print_game(game)
        run_game(prog, i, inputs, outputs, r, game)
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
    case inputs do
      [] ->
        []

      [[_, 0] | rest] ->
        take_inputs(rest)

      [[val, count] | rest] ->
        [val, [val, count - 1] | rest]
    end
  end

  def input_left(inputs, acc \\ 0) do
    case inputs do
      [] ->
        acc

      [[_, c] | rest] ->
        input_left(rest, acc + c)
    end
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

  def run_program(program, i, inputs, outputs, relative_offset, game) do
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
        |> run_program(i + 4, inputs, outputs, relative_offset, game)

      2 ->
        # mult
        set(program, a3, a1 * a2)
        |> run_program(i + 4, inputs, outputs, relative_offset, game)

      3 ->
        # input
        case take_inputs(inputs) do
          [] ->
            {:wait, program, i, outputs, relative_offset}

          [input | rest] ->
            # IO.puts("processing input #{input} (#{input_left(rest)})")
            # print_game(game)
            set(program, a1, input)
            |> run_program(i + 2, rest, outputs, relative_offset, game)
        end

      4 ->
        # output
        {:cont, program, i + 2, inputs, outputs ++ [a1], relative_offset}

      5 ->
        # jump-if-true
        pointer =
          if a1 != 0 do
            a2
          else
            i + 3
          end

        run_program(program, pointer, inputs, outputs, relative_offset, game)

      6 ->
        # jump-if-false
        pointer =
          if a1 == 0 do
            a2
          else
            i + 3
          end

        run_program(program, pointer, inputs, outputs, relative_offset, game)

      7 ->
        # less than
        result =
          if a1 < a2 do
            1
          else
            0
          end

        set(program, a3, result)
        |> run_program(i + 4, inputs, outputs, relative_offset, game)

      8 ->
        # equals
        result =
          if a1 == a2 do
            1
          else
            0
          end

        set(program, a3, result)
        |> run_program(i + 4, inputs, outputs, relative_offset, game)

      9 ->
        # adjust relative offset
        run_program(program, i + 2, inputs, outputs, relative_offset + a1, game)

      99 ->
        {:stop, program, i, inputs, outputs, relative_offset}
    end
  end
end
