# Benchmarks

This repo consist of a bunch of benchmarks of
different functionality like:

- Regex VS Pattern Matching
- `Enum.flat_map` VS `Enum.map |> List.flatten`

To run the benchmark follow these steps:

```sh
mix deps.get
mix compile
mix run lib/benchmarks.exs
```
