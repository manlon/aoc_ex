defmodule AocEx.Aoc2022Ex.Day21 do
  use AocEx.Day, year: 2022, day: 21

  def monkeys do
    input_lines()
    |> Enum.reduce({%{}, %{}}, fn line, {jobs, deps} ->
      [name, job] = String.split(line, ":")
      job_parts = String.split(job)

      case job_parts do
        [num] ->
          jobs = Map.put(jobs, name, String.to_integer(num))
          {jobs, deps}

        [a, op, b] ->
          jobs = Map.put(jobs, name, [a, op, b])

          deps =
            Map.update(deps, a, [name], &[name | &1])
            |> Map.update(b, [name], &[name | &1])

          {jobs, deps}
      end
    end)
  end

  def solve1 do
    {jobs, deps} = monkeys()
    reduce_jobs(jobs, deps)
  end

  def solve2 do
    {jobs, deps} = monkeys()

    jobs =
      Map.update!(jobs, "root", fn [a, _op, b] -> [a, "=", b] end)
      |> Map.put("humn", :unknown)

    {:halt, jobs} = reduce_jobs(jobs, deps)
    [a, "=", b] = Map.get(jobs, "root")
    {key, value} = if is_integer(a), do: {b, a}, else: {a, b}
    propagate(jobs, key, value, "humn")
  end

  def reduce_jobs(%{"root" => answer}, _deps) when is_integer(answer) do
    answer
  end

  def reduce_jobs(jobs, deps) do
    case Enum.find(jobs, fn {_, v} -> is_integer(v) end) do
      {name, val} ->
        jobs = Map.delete(jobs, name)
        dependers = Map.get(deps, name)

        jobs =
          Enum.reduce(dependers, jobs, fn depender, jobs ->
            jobs =
              Map.update!(jobs, depender, fn op ->
                Enum.map(op, fn i -> if i == name, do: val, else: i end)
              end)

            case Map.get(jobs, depender) do
              [a, op, b] when is_integer(a) and is_integer(b) ->
                n =
                  case op do
                    "+" ->
                      a + b

                    "-" ->
                      a - b

                    "*" ->
                      a * b

                    "/" ->
                      div(a, b)

                    "=" ->
                      IO.inspect("a: #{a}  b: #{b}")
                      {a, b}
                  end

                Map.put(jobs, depender, n)

              _ ->
                jobs
            end
          end)

        reduce_jobs(jobs, deps)

      nil ->
        {:halt, jobs}
    end
  end

  def propagate(_jobs, target, val, target), do: val

  def propagate(jobs, key, val, target) do
    {operation, jobs} = Map.get_and_update!(jobs, key, fn cur -> {cur, val} end)

    case operation do
      [a, "+", b] when is_integer(a) ->
        propagate(jobs, b, val - a, target)

      [a, "+", b] when is_integer(b) ->
        propagate(jobs, a, val - b, target)

      [a, "-", b] when is_integer(a) ->
        propagate(jobs, b, a - val, target)

      [a, "-", b] when is_integer(b) ->
        propagate(jobs, a, val + b, target)

      [a, "*", b] when is_integer(a) ->
        propagate(jobs, b, div(val, a), target)

      [a, "*", b] when is_integer(b) ->
        propagate(jobs, a, div(val, b), target)

      [a, "/", b] when is_integer(a) ->
        propagate(jobs, b, div(a, val), target)

      [a, "/", b] when is_integer(b) ->
        propagate(jobs, a, val * b, target)
    end
  end
end
