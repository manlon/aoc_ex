defmodule AocEx.Aoc2019Ex.Day05 do
  def input do
    AocEx.Day.input_file_contents(2019, 5)
    # "1,1,1,4,99,5,6,0,99"
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
    |> :array.from_list()
  end

  def set(arr, i, v) do
    :array.set(i, v, arr)
  end

  def get(_arr, :undefined) do
    :undefined
  end

  def get(arr, i) do
    :array.get(i, arr)
  end

  def part1 do
    input()
    |> doop(0, [1])

    nil
  end

  def part2 do
    input()
    |> doop(0, [5])

    nil
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

  def doop(program, i, inputs) do
    {op, modes} = get(program, i) |> decompose_op
    [a1, a2, a3] = args(program, i, modes)

    case op do
      1 ->
        # add
        set(program, a3, a1 + a2)
        |> doop(i + 4, inputs)

      2 ->
        # mult
        set(program, a3, a1 * a2)
        |> doop(i + 4, inputs)

      3 ->
        # input
        p1 = get(program, i + 1)
        [input | rest] = inputs

        set(program, p1, input)
        |> doop(i + 2, rest)

      4 ->
        # output
        IO.puts("OUTPUT: #{a1}")
        doop(program, i + 2, inputs)

      5 ->
        # jump-if-true
        pointer =
          if a1 != 0 do
            a2
          else
            i + 3
          end

        doop(program, pointer, inputs)

      6 ->
        # jump-if-false
        pointer =
          if a1 == 0 do
            a2
          else
            i + 3
          end

        doop(program, pointer, inputs)

      7 ->
        # less than
        result =
          if a1 < a2 do
            1
          else
            0
          end

        set(program, a3, result)
        |> doop(i + 4, inputs)

      8 ->
        # equals
        result =
          if a1 == a2 do
            1
          else
            0
          end

        set(program, a3, result)
        |> doop(i + 4, inputs)

      99 ->
        program
    end

    # def doop(program, i, inputs) do
    #  {op, modes} = get(program, i) |> decompose
    #  [a1, a2, a3] = args(program, i, modes)
    #  # """
    #  # ==========================
    #  # pointer: #{i}
    #  # opcode: #{get(program, i)}
    #  # op: #{op}
    #  # modes: #{modes |> inspect()}
    #  # program: #{get_chunk(program, i, 4) |> inspect()}
    #  # """
    #  # |> IO.puts
    #  case op do
    #    1 ->
    #      # add
    #      [p1, p2, p3] = get_chunk(program, i + 1, 3)
    #      [v1, v2] = values(program, [p1, p2], modes)
    #      set(program, p3, v1 + v2)
    #      |> doop(i + 4, inputs)
    #    2 ->
    #      # mult
    #      [p1, p2, p3] = get_chunk(program, i + 1, 3)
    #      [v1, v2] = values(program, [p1, p2], modes)
    #      set(program, p3, v1 * v2)
    #      |> doop(i + 4, inputs)
    #    3 ->
    #      #input
    #      p1 = get(program, i + 1)
    #      [input | rest] = inputs
    #      set(program, p1, input)
    #      |> doop(i + 2, rest)
    #    4 ->
    #      #output
    #      p1 = get(program, i + 1)
    #      val = values(program, [p1], modes) |> hd
    #      IO.puts("OUTPUT: #{val}")
    #      doop(program, i + 2, inputs)
    #    5 ->
    #      # jump-if-true
    #      [p1, p2] = get_chunk(program, i + 1, 2)
    #      [v1, v2] = values(program, [p1, p2], modes)
    #      pointer = if v1 != 0 do
    #        v2
    #      else
    #        i + 3
    #      end
    #      doop(program, pointer, inputs)
    #    6 ->
    #      # jump-if-false
    #      [p1, p2] = get_chunk(program, i + 1, 2)
    #      [v1, v2] = values(program, [p1, p2], modes)
    #      pointer = if v1 == 0 do
    #        v2
    #      else
    #        i + 3
    #      end
    #      doop(program, pointer, inputs)
    #    7 ->
    #      # less than
    #      [p1, p2, p3] = get_chunk(program, i + 1, 3)
    #      [v1, v2] = values(program, [p1, p2], modes)
    #      result = if v1 < v2 do
    #        1
    #      else
    #        0
    #      end
    #      set(program, p3, result)
    #      |> doop(i + 4, inputs)
    #    8 ->
    #      # equals
    #      [p1, p2, p3] = get_chunk(program, i + 1, 3)
    #      [v1, v2] = values(program, [p1, p2], modes)
    #      result = if v1 == v2 do
    #        1
    #      else
    #        0
    #      end
    #      set(program, p3, result)
    #      |> doop(i + 4, inputs)
    #    99 ->
    #      program
    #  end
  end
end
