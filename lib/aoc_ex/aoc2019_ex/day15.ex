defmodule AocEx.Aoc2019Ex.Day15 do
  defmacro dbg!(clause) do
    quote do
      label = "[#{__ENV__.file}:#{__ENV__.line}] #{unquote(Macro.to_string(clause))}"
      IO.inspect(unquote(clause), label: label)
    end
  end

  def input do
    AocEx.Day.input_file_contents(2019, 15)
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

  # def empty_map do
  #  %{{0,0} => {".", []}}
  # end

  def init_pos do
    {0, 0}
  end

  def empty_map do
    %{init_pos() => {".", []}}
  end

  def part1 do
    map = empty_map()
    program = input()
    map = run_until_explored(map, program)

    {_oxy_loc, {_, oxy_path}} =
      map
      |> Enum.find(fn {_, {c, _}} -> c == "A" end)

    Enum.count(oxy_path)
  end

  def part2 do
    map = empty_map()
    program = input()
    map = run_until_explored(map, program)

    oxy_map(map)
    |> oxygenate()
  end

  def found_target(map) do
    hits =
      Enum.filter(map, fn {_k, {chr, _path}} ->
        chr == "A"
      end)

    case hits do
      [target] ->
        target

      [] ->
        false
    end
  end

  def run_until_found(map, program) do
    target = found_target(map)

    if target do
      target
    else
      paths = new_paths_for(map)

      paths
      |> Enum.map(&length/1)
      |> Enum.max()

      map =
        paths
        |> Enum.reduce(map, fn path, acc ->
          {_robot, acc} = run_until_wait(program, 0, path, [], 0, [], init_pos(), acc)
          acc
        end)

      run_until_found(map, program)
    end
  end

  def run_until_explored(map, program) do
    paths = new_paths_for(map)

    if paths == [] do
      print_map({{0, 0}, map})
      map
    else
      map =
        paths
        |> Enum.reduce(map, fn path, acc ->
          {_robot, acc} = run_until_wait(program, 0, path, [], 0, [], init_pos(), acc)
          acc
        end)

      run_until_explored(map, program)
    end
  end

  def open_points(map) do
    Enum.reduce(map, %{}, fn {coord, {chr, _path} = pt}, acc ->
      if chr == "." do
        Map.put(acc, coord, pt)
      else
        acc
      end
    end)
  end

  def oxy_points(map) do
    Enum.reduce(map, %{}, fn {coord, chr}, acc ->
      if chr == "O" do
        Map.put(acc, coord, chr)
      else
        acc
      end
    end)
  end

  def new_paths_for(map) do
    opens = open_points(map)

    Enum.reduce(opens, [], fn {openpos, {_, openpath}}, acc ->
      neighbors =
        [1, 2, 3, 4]
        |> Enum.map(fn dir ->
          {dir, add_dir(openpos, dir)}
        end)
        |> Enum.filter(fn {_dir, neighbor} ->
          !Map.has_key?(map, neighbor)
        end)

      new_paths =
        neighbors
        |> Enum.map(fn {dir, _pos} ->
          openpath ++ [dir]
        end)

      acc ++ new_paths
    end)
  end

  def is_oxy?(map, pos) do
    Map.get(map, pos, "") == "O"
  end

  def new_oxy_pts(map) do
    cur_oxy = oxy_points(map)

    Enum.reduce(cur_oxy, [], fn {openpos, _}, acc ->
      neighbors =
        [1, 2, 3, 4]
        |> Enum.map(fn dir ->
          {dir, add_dir(openpos, dir)}
        end)
        |> Enum.filter(fn {_dir, neighbor} ->
          Map.get(map, neighbor, "") == "."
        end)

      acc ++ Enum.map(neighbors, fn {_dir, pos} -> pos end)
    end)
  end

  def oxy_done(map) do
    Enum.filter(map, fn {_pos, chr} -> chr == "." end)
    |> Enum.empty?()
  end

  def oxygenate(map, c \\ 0) do
    if oxy_done(map) do
      print_map(map)
      c
    else
      new_pts = new_oxy_pts(map)

      map =
        Enum.reduce(new_pts, map, fn pt, acc ->
          Map.put(acc, pt, "O")
        end)

      print_map(map)
      :timer.sleep(40)
      oxygenate(map, c + 1)
    end
  end

  def oxy_map(robot_map) do
    {target_loc, _} = found_target(robot_map)

    robot_map
    |> Enum.reduce(%{}, fn {pos, {chr, _}}, acc ->
      Map.put(acc, pos, chr)
    end)
    |> Map.put(target_loc, "O")
  end

  def explode(paths) do
    Enum.flat_map(paths, &explore/1)
  end

  def explore(path) do
    [1, 2, 3, 4]
    |> Enum.map(fn dir ->
      path ++ [dir]
    end)
  end

  def add_dir({x, y}, dir) do
    case dir do
      1 ->
        {x, y + 1}

      2 ->
        {x, y - 1}

      3 ->
        {x - 1, y}

      4 ->
        {x + 1, y}
    end
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

  def update_robot(robot, map, processed_inputs, output) do
    last_input = hd(processed_inputs)
    try_pos = add_dir(robot, last_input)

    chr =
      case output do
        0 ->
          "#"

        1 ->
          "."

        2 ->
          "A"
      end

    map =
      if Map.has_key?(map, try_pos) do
        map
      else
        Map.put(map, try_pos, {chr, Enum.reverse(processed_inputs)})
      end

    robot =
      if output == 0 do
        robot
      else
        try_pos
      end

    {robot, map}
  end

  def run_until_wait(program, pointer, inputs, outputs, r, processed_inputs, robot, map) do
    case run_program(program, pointer, inputs, outputs, r, processed_inputs) do
      {:wait, _prog, _i, _outputs, _r, _processed_inputs} ->
        {robot, map}

      {:cont, prog, i, inputs, [output], r, processed_inputs} ->
        {robot, map} = update_robot(robot, map, processed_inputs, output)
        run_until_wait(prog, i, inputs, [], r, processed_inputs, robot, map)
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
