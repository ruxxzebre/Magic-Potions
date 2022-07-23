defmodule Benchmarks do end

# Functions

map_fun = fn i -> [i, i*i] end

generate_color = fn ->
  "#" <> (
    for _ <- 0..2 do
      color = :random.uniform(255) |> Integer.to_string(16)
      cond do
        String.length(color) < 2 -> "0" <> color
        true -> color
      end
    end |> Enum.join()
  )
end

# Inputs

list_inputs = %{
  "small list" => Enum.to_list(1..100),
  "medium list" => Enum.to_list(1..10_000),
  "large list" => Enum.to_list(1..1_000_000)
}

colors = Enum.to_list(1..500000) |> Enum.map(fn _ -> generate_color.() end)

# Configs

benchmark_flat_map = [%{
  "flat_map" => fn list -> list |> Enum.flat_map(map_fun) end,
  "map.flatten" => fn list -> list |> Enum.map(map_fun) |> List.flatten() end,
}, [
  inputs: list_inputs
]]

benchmark_regex_against_pattern_matching = [%{
  "regex" => fn colors ->
    fun = fn color -> Regex.run(~r/#(\d{2})(\d{2})(\d{2})/, color) end
    colors |> Enum.each(fun)
  end,
  "pattern matching" => fn colors ->
    fun = fn color -> <<?#, p1::2-bytes, p2::2-bytes, p3::2-bytes>> = color end
    colors |> Enum.each(fun)
  end
}, [
  inputs: %{
    colors: colors
  },
  warmup: 20,
  time: 15,
  parallel: 8
]]

# Running Benchee

apply(Benchee, :run, benchee_config_2)
