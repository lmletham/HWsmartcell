# Hwsmartcell
Livebook smartcell for homework problems


# Code for the Startup Cell
```elixir
Mix.install([
  {:kino, "~> 0.13.2"},
  {:earmark, "~> 1.4.47"},
  {:makeup, "~> 1.1"},
  {:makeup_elixir, "~> 0.7"},
  {:hwsmartcell, "~> 0.1.0"}
])

#Ensure the smartcell is registered
Kino.SmartCell.register(Hwsmartcell)
```
