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
OK. This is almost working. I have highlighting fixed on edit. and the padding is working. I just need to hide the input box on tabs: hint and solution as well as on the text="elixir" Which I thought it was doing already :/