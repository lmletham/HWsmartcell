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

# Code for example elixir cell (below smartcell)
```elixir
defmodule P1 do
  def answer do
    # Write your answer in the line below
    "atom"
  end
end

P1Test.test()
```

# Code for test code field (in smartcell)
```elixir
defmodule P1Test do
  @compile {:no_warn_undefined, P1}
  def test do
    case check_answer(P1.answer()) do
      :ok -> 
        Kino.render(P1.answer())
        Kino.HTML.new("<font color='green'>Correct!</font>")
      :error -> 
        Kino.render(P1.answer())
        Kino.HTML.new("<font color='red'>Try again!</font>")
    end
  end

  defp check_answer(answer) when answer in ["atom", "Atom"], do: :ok
  defp check_answer(_), do: :error
end

# Suppress the compilation output
:evaluated
```

# Code example for writing in the Problem Statement. I am now using backticks to get the pill effect.
```elixir
What is this *data*

I **need** it

super `bad`

list:
* sdf 
* sdf
* sdfsd `tt`

```elixir
:tbd
:testing
```
```



# Code Notes
Everything working!
