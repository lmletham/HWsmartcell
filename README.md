# Hwsmartcell
Livebook smartcell for homework problems


# Code for the Startup Cell
```elixir
Mix.install([
  {:hwsmartcell, ">= 0.1.0"}
])

#Ensure the smartcell is registered
Kino.SmartCell.register(Hwsmartcell)
```

I only need to have the above in the startup cell because all my dependencies are called in mix.exs already.

OK, this is the version that has a working "elixir" hide function. Submit button is broken though.