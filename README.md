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


# Code Notes
Successfully changed the to_source function to append Test_code to the bottom of the smartcell. You can hit the "Toggle Source" button to see it. I ran the elixir cell below and got feedback appended correctly.