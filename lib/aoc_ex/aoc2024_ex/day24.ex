defmodule AocEx.Aoc2024Ex.Day24 do
  import Bitwise
  alias Graphvix.Graph

  @example """
  """

  def input do
    AocEx.Day.input_file_contents(2024, 24)
    # @example
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn chunk -> String.split(chunk, "\n", trim: true) end)
    |> then(fn [wires, gates] -> {parse_wires(wires), parse_gates(gates)} end)
  end

  def parse_wires(wires) do
    Enum.map(wires, fn wire ->
      [a, b] = String.split(wire, ": ")
      {a, String.to_integer(b)}
    end)
    |> Enum.into(%{})
  end

  def parse_gates(wires) do
    Enum.map(wires, fn wire ->
      [g1, typ, g2, "->", g3] = String.split(wire, " ")

      ([typ] ++ Enum.sort([g1, g2]) ++ [g3])
      |> List.to_tuple()
    end)
  end

  def evolve(wires, gates) do
    Enum.reduce(gates, {wires, false}, fn gate, {wires, changed} ->
      {typ, i1, i2, out} = gate

      if Map.has_key?(wires, out) do
        {wires, changed}
      else
        if Map.has_key?(wires, i1) and Map.has_key?(wires, i2) do
          wires = Map.put(wires, out, gate(typ, wires[i1], wires[i2]))
          {wires, true}
        else
          {wires, changed}
        end
      end
    end)
  end

  def settle(wires, gates) do
    case evolve(wires, gates) do
      {wires, false} -> wires
      {wires, true} -> settle(wires, gates)
    end
  end

  def gate("AND", x, y), do: band(x, y)
  def gate("OR", x, y), do: bor(x, y)
  def gate("XOR", x, y), do: bxor(x, y)

  def read(wires, prefix) do
    wires
    |> Enum.filter(fn {k, _} -> String.starts_with?(k, prefix) end)
    |> Enum.sort(:desc)
    |> Enum.map(&elem(&1, 1))
    |> Integer.undigits(2)
  end

  def solve1 do
    {wires, gates} = input()
    wires = settle(wires, gates)
  end

  def solve2 do
  end

  def graph do
    {wires, gates} = input()
    graph = Graph.new()

    all_wires =
      Enum.flat_map(gates, fn {_, i1, i2, out} -> [i1, i2, out] end)
      |> Enum.uniq()
      |> Enum.sort()

    {graph, vnames} =
      Enum.reduce(all_wires, {graph, %{}}, fn wire, {graph, vnames} ->
        {graph, vid} = Graph.add_vertex(graph, wire)
        vnames = Map.put(vnames, wire, vid)
        {graph, vnames}
      end)

    swaps = %{
      "z16" => "pbv",
      "pbv" => "z16",
      "z23" => "qqp",
      "qqp" => "z23",
      "z36" => "fbq",
      "fbq" => "z36",
      "qnw" => "qff",
      "qff" => "qnw"
    }

    Enum.reduce(gates, graph, fn {typ, i1, i2, out}, graph ->
      out = Map.get(swaps, out, out)

      vid1 = Map.get(vnames, i1)
      vid2 = Map.get(vnames, i2)
      vid_out = Map.get(vnames, out)

      {graph, gatenode} = Graph.add_vertex(graph, "#{i1} #{typ} #{i2}")

      {graph, _} = Graph.add_edge(graph, vid1, gatenode)
      {graph, _} = Graph.add_edge(graph, vid2, gatenode)
      {graph, _} = Graph.add_edge(graph, gatenode, vid_out)

      graph
    end)
  end
end
