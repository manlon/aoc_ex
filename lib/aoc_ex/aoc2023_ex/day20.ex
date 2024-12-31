defmodule AocEx.Aoc2023Ex.Day20 do
  use AocEx.Day, day: 20

  defmodule Parser do
    use AocEx.Parser
    alias AocEx.Aoc2023Ex.Day20
    @bcast "broadcaster"
    module_name = ascii_string([?a..?z], 2)
    type = ascii_string([?&, ?%], 1)
    module = choice([string(@bcast) |> replace(["b", @bcast]), wrap(concat(type, module_name))])
    module_list = wrap(module_name |> repeat(istr(", ") |> concat(module_name)))
    line = module |> istr(" -> ") |> concat(module_list)
    defmatch(:parse_line, line)

    def parsed_lines, do: Day20.input_lines() |> Enum.map(&parse_line/1)

    def parsed_input do
      for [[typ, name], dests] <- parsed_lines(), reduce: %{} do
        map ->
          default = %{type: typ, dests: dests}
          map = Map.update(map, name, default, &Map.merge(&1, default))

          for d <- dests, reduce: map do
            map ->
              Map.update(
                map,
                d,
                %{inputs: [name]},
                &Map.update(&1, :inputs, [name], fn inputs -> [name | inputs] end)
              )
          end
      end
    end
  end

  @conj "&"
  @flip "%"
  @bcst "b"
  @rx "!"
  @high :high
  @low :low
  @off :off
  @on :on
  def start_state do
    map = Parser.parsed_input()

    for n <- Map.keys(map), reduce: map do
      map ->
        case map[n] do
          info = %{type: @conj} ->
            input_pulses =
              for i <- info.inputs, into: %{} do
                {i, @low}
              end

            Map.put(map, n, Map.merge(info, %{input_pulses: input_pulses}))

          info = %{type: @flip} ->
            Map.put(map, n, Map.merge(info, %{state: @off}))

          _ ->
            map
        end
    end
    |> Map.update!("rx", &Map.merge(&1, %{type: @rx}))
  end

  def process_pulses(
        _map,
        [_pulse = {_src, modname, hilo} | _],
        _cts,
        _stopon = {modname, hilo},
        _n
      ) do
    :halt
  end

  def process_pulses(map, [_pulse = {src, modname, hilo} | rest], {hict, lowct}, stopon, n) do
    module = map[modname]

    {module, sends} =
      case module[:type] do
        @rx ->
          {module, []}

        @bcst ->
          sends = for d <- module.dests, do: {modname, d, hilo}
          {module, sends}

        @flip ->
          case hilo do
            @high ->
              {module, []}

            @low ->
              case module.state do
                @off ->
                  module = put_in(module.state, @on)
                  sends = for d <- module.dests, do: {modname, d, @high}
                  {module, sends}

                @on ->
                  module = put_in(module.state, @off)
                  sends = for d <- module.dests, do: {modname, d, @low}
                  {module, sends}
              end
          end

        @conj ->
          module = put_in(module.input_pulses[src], hilo)

          if modname == "vr" do
            if module.input_pulses |> Map.values() |> Enum.any?(&(&1 == @high)) do
              inps = module.input_pulses
              IO.puts("boop #{n} #{inspect(inps)}")
            end
          end

          sends =
            if module.input_pulses |> Map.values() |> Enum.all?(&(&1 == @high)) do
              for d <- module.dests, do: {modname, d, @low}
            else
              for d <- module.dests, do: {modname, d, @high}
            end

          {module, sends}
      end

    map = Map.put(map, modname, module)
    pulses = rest ++ sends

    hict =
      if hilo == @high do
        hict + 1
      else
        hict
      end

    lowct =
      if hilo == @low do
        lowct + 1
      else
        lowct
      end

    process_pulses(map, pulses, {hict, lowct}, stopon, n)
  end

  def process_pulses(map, [], cts, _stopon, _n), do: {map, cts}

  def solve1 do
    map = start_state()
    start_pulse = [{nil, "broadcaster", @low}]
    cts = {0, 0}

    {_, {hi, lo}} =
      for i <- 1..1000, reduce: {map, cts} do
        {map, cts} ->
          process_pulses(map, start_pulse, cts, nil, i)
      end

    hi * lo
  end

  def debug_print_map(map) do
    Enum.sort(map)
    |> Enum.map(fn {k, v} ->
      case v[:type] do
        @conj ->
          input_str =
            for({k, v} <- Enum.sort(v.input_pulses), do: "#{k}=#{v}")
            |> Enum.join(",")

          "#{k}: #{input_str}\n"

        @flip ->
          "#{k}: #{v.state}\n"

        _ ->
          ""
      end
    end)
    |> Enum.join("")
  end

  def hilostr(:high), do: "1"
  def hilostr(:low), do: "0"
  def onoffstr(:on), do: "#"
  def onoffstr(:off), do: "."

  def debug_print_s(map) do
    Enum.sort(map)
    |> Enum.map(fn {k, v} ->
      s =
        case v[:type] do
          @conj ->
            # for({k, v} <- Enum.sort(v.input_pulses), do: "#{k}=#{v}")
            # |> Enum.join(",")
            input_str =
              for({k, v} <- Enum.sort(v.input_pulses), do: hilostr(v))
              |> Enum.join("")

            "(#{k}:#{input_str})"

          # "#{k}:#{input_str};"

          @flip ->
            pref =
              if k in map["vr"].inputs do
                ">"
              else
                ""
              end

            # "#{k}:#{v.state};"
            onoffstr(v.state)

          @bcst ->
            "b"

          @rx ->
            @rx
        end

      if k == "rx" || k == "vr" do
        "<" <> s <> ">"
      else
        s
      end
    end)
    |> Enum.join("")
  end

  def count_until_halt(map, stopon, n \\ 1, catch_highs \\ %{}) do
    start_pulse = [{nil, "broadcaster", @low}]

    case process_pulses(map, start_pulse, {0, 0}, stopon, n) do
      {map, _} ->
        # if map["vr"].input_pulses |> Map.values() |> Enum.any?(&(&1 == @high)) do
        # if true do
        # IO.puts(n)
        # if rem(n, 2 ** 20) == 0 do
        #   IO.puts(debug_print_s(map))
        #   # IO.puts("--------------------")
        # end

        # IO.inspect(map["vr"].input_pulses)

        new_catch_highs =
          Enum.reduce(map["vr"].input_pulses, catch_highs, fn {k, v}, acc ->
            if(v == @high && !Map.has_key?(acc, k)) do
              Map.put(acc, k, n)
            else
              acc
            end
          end)

        if Enum.count(catch_highs) != Enum.count(new_catch_highs) do
          IO.inspect(new_catch_highs)
        end

        count_until_halt(map, stopon, n + 1, new_catch_highs)

      :halt ->
        n
    end
  end

  def solve2 do
    map = start_state()
    count_until_halt(map, {"rx", @low})
  end
end
