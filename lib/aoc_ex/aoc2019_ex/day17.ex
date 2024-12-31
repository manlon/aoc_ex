defmodule AocEx.Aoc2019Ex.Day17 do
  def input do
    AocEx.Day.input_file_contents(2019, 17)
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
      dbg({arr, i, v})
    end

    :array.set(i, v, arr)
  end

  def get(_, :undefined) do
    :undefined
  end

  def get(arr, i) do
    :array.get(i, arr)
  end

  # def empty_map do
  #  %{{0,0} => {".", []}}
  # end

  def init_pos do
    {0, 0}
  end

  def empty_map do
    %{init_pos() => {".", []}}
  end

  def outputs_to_map(outputs) do
    {_, map} =
      outputs
      |> List.to_string()
      |> String.split("\n")
      |> Enum.map(fn line ->
        String.codepoints(line)
      end)
      |> Enum.reduce({0, %{}}, fn line, {y, map} ->
        {_, map} =
          Enum.reduce(line, {0, map}, fn chr, {x, map} ->
            {x + 1, Map.put(map, {x, y}, chr)}
          end)

        {y + 1, map}
      end)

    map
  end

  def go1 do
    program = input()
    {:stop, _, _, _, outputs, _, _} = run_until_wait(program, 0, [], [], 0, [])
    IO.puts(outputs)
    map = outputs_to_map(outputs)

    scaffolds =
      map
      |> Enum.filter(fn {_k, v} -> v == "#" end)
      |> Enum.map(fn {a, _} -> a end)
      |> Enum.filter(fn {x, y} ->
        neighbs = neighbors({x, y})

        Enum.count(Map.take(map, neighbs)) == 4 &&
          Enum.all?(neighbs, fn n -> Map.get(map, n) == "#" end)
      end)

    Enum.map(scaffolds, fn {x, y} -> x * y end)
    |> Enum.sum()
  end

  def rot_r({1, 0}), do: {0, 1}
  def rot_r({0, 1}), do: {-1, 0}
  def rot_r({-1, 0}), do: {0, -1}
  def rot_r({0, -1}), do: {1, 0}

  def rot_l({0, 1}), do: {1, 0}
  def rot_l({-1, 0}), do: {0, 1}
  def rot_l({0, -1}), do: {-1, 0}
  def rot_l({1, 0}), do: {0, -1}

  def add_coords({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}

  def find_path(map, cur_pos, cur_dir, [cur_run | acc]) do
    ahead = add_coords(cur_pos, cur_dir)

    if Map.get(map, ahead, nil) == "#" do
      find_path(map, ahead, cur_dir, [cur_run + 1 | acc])
    else
      cond do
        # Map.get(map, add_coords(cur_pos, rot_r(cur_dir))) == "#" ->
        #  find_path(map, cur_pos, rot_r(cur_dir), [0, :R, ])
        # Map.get(map, add_coords(cur_pos, rot_l(cur_dir))) == "#" ->
        true ->
          nil
      end
    end
  end

  def go2 do
    program = input()
    {:stop, _, _, _, outputs, _, _} = run_until_wait(program, 0, [], [], 0, [])
    map = outputs_to_map(outputs)

    {start_pos, _} = Enum.find(map, fn {_, char} -> char == "^" end)
    IO.inspect(start_pos, label: :start)

    program =
      input()
      |> set(0, 2)

    # 'L,6,R,12,L,4,L,6,R,6,L,6,R,12,R,6,L,6,R,12,L,6,L,10,L,10,R,6,L,6,R,12,L,4,L,6,R,6,L,6,R,12,L,6,L,10,L,10,R,6,L,6,R,12,L,4,L,6,R,6,L,6,R,12,L,6,L,10,L,10,R,6'

    robot_input =
      ~c'A,B,B,C,A,B,C,A,B,C\n' ++
        ~c'L,6,R,12,L,4,L,6\n' ++
        ~c'R,6,L,6,R,12\n' ++
        ~c'L,6,L,10,L,10,R,6\n' ++
        ~c'n\n'

    {:stop, _, _, _, outputs, _, _} = run_until_wait(program, 0, robot_input, [], 0, [], false)

    IO.inspect(outputs, label: :output)
    IO.inspect(Enum.at(outputs, length(outputs) - 1))
  end

  def neighbors({x, y}) do
    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
  end

  def print_map({robot, map}) do
    if Enum.empty?(map) do
      IO.puts("empty map")
    else
      IO.puts("=============================")

      minx =
        Map.keys(map)
        |> Enum.map(fn {x, _y} -> x end)
        |> Enum.min()

      miny =
        Map.keys(map)
        |> Enum.map(fn {_x, y} -> y end)
        |> Enum.min()

      maxx =
        Map.keys(map)
        |> Enum.map(fn {x, _y} -> x end)
        |> Enum.max()

      maxy =
        Map.keys(map)
        |> Enum.map(fn {_x, y} -> y end)
        |> Enum.max()

      maxy..miny
      |> Enum.map(fn y ->
        minx..maxx
        |> Enum.map(fn x ->
          if robot == {x, y} do
            "R"
          else
            Map.get(map, {x, y}, {" ", []})
            |> case do
              {chr, _path} ->
                chr

              chr ->
                chr
            end
          end
        end)
        |> Enum.join()
      end)
      |> Enum.join("\n")
      |> IO.puts()

      IO.puts("=============================")
    end
  end

  def print_map(map) do
    print_map({nil, map})
  end

  def run_until_wait(
        program,
        pointer,
        inputs,
        outputs,
        r,
        processed_inputs,
        print_immediate \\ false
      ) do
    case run_program(program, pointer, inputs, outputs, r, processed_inputs) do
      {:wait, _prog, _i, _outputs, _r, _processed_inputs} ->
        nil

      {:cont, prog, i, inputs, outputs, r, processed_inputs} ->
        if print_immediate do
          IO.write(outputs)
          run_until_wait(prog, i, inputs, [], r, processed_inputs, true)
        else
          run_until_wait(prog, i, inputs, outputs, r, processed_inputs)
        end

      x ->
        x
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

  def run_program(program, i, inputs, outputs, relative_offset, last_input) do
    [instruction, c1, _c2, c3] = get_chunk(program, i, 4)
    {op, modes} = decompose_op(instruction)

    _opname = @codenames[op]

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
