defmodule Hwsmartcell do
  use Kino.JS
  use Kino.JS.Live
  use Kino.SmartCell, name: "HW Smartcell"

  @impl true
  def init(attrs, ctx) do
    problem_number = attrs["problem_number"] || "1"
    problem_statement = attrs["problem_statement"] || """
    What is this data type?
    ```elixir
    defmodule Test do
      def answer do
        #Write your answer below here:
        :integer
        var = 2 + 2
        IO.puts(var)
        "Hello"
      end
    end

    Test.answer()
    ```
    """
    hint = attrs["hint"] || "Try breaking the problem into smaller parts."
    solution = attrs["solution"] || "Atom"
    correct_answer = attrs["correct_answer"] || ""

    # Process the problem statement with Makeup
    rendered_problem_statement = process_with_makeup(problem_statement)
    rendered_hint = process_with_makeup(hint)
    rendered_solution = process_with_makeup(solution)

    # Generate the Makeup CSS
    makeup_css = File.read!("lib/styles.css")

    ctx = assign(ctx, problem_number: problem_number, problem_statement: rendered_problem_statement, hint: rendered_hint, solution: rendered_solution, correct_answer: correct_answer, makeup_css: makeup_css)

    {:ok, ctx}
  end

  @impl true
  def handle_connect(ctx) do
    {:ok, %{
      problem_number: ctx.assigns.problem_number,
      problem_statement: ctx.assigns.problem_statement,
      hint: ctx.assigns.hint,
      solution: ctx.assigns.solution,
      correct_answer: ctx.assigns.correct_answer,
      makeup_css: ctx.assigns.makeup_css
    }, ctx}
  end

  @impl true
  def to_attrs(ctx) do
    %{
      "problem_number" => ctx.assigns.problem_number,
      "problem_statement" => ctx.assigns.problem_statement,
      "hint" => ctx.assigns.hint,
      "solution" => ctx.assigns.solution,
      "correct_answer" => ctx.assigns.correct_answer
    }
  end

  @impl true
  def to_source(attrs) do
    """
    #Problem_Number:
    #{attrs["problem_number"]}

    #Problem_Statement:
    #{inspect(attrs["problem_statement"], raw: true)}

    #Hint:
    #{inspect(attrs["hint"], raw: true)}

    #Solution:
    #{inspect(attrs["solution"], raw: true)}

    #Correct Answer:
    #{inspect(attrs["correct_answer"], raw: true)}
    """
  end

  @impl true
  def handle_event("check_answer", %{"input_value" => input_value}, ctx) do
    feedback =
      if String.downcase(String.trim(input_value)) == String.downcase(String.trim(ctx.assigns.correct_answer)) do
        %{"message" => "Correct!", "color" => "text-green-500"}
      else
        %{"message" => "Try again!", "color" => "text-red-500"}
      end

    broadcast_event(ctx, "feedback", feedback)
    {:noreply, ctx}
  end

  @impl true
  def handle_event("save_edits", %{
    "problem_number" => problem_number,
    "problem_statement" => problem_statement,
    "hint" => hint,
    "solution" => solution,
    "correct_answer" => correct_answer
  }, ctx) do
    ctx = assign(ctx, problem_number: problem_number, problem_statement: problem_statement, hint: hint, solution: solution, correct_answer: correct_answer)

    # Process the text with Makeup
    rendered_problem_statement = process_with_makeup(problem_statement)
    rendered_hint = process_with_makeup(hint)
    rendered_solution = process_with_makeup(solution)

    # Send the rendered HTML and CSS to the client-side for display
    broadcast_event(ctx, "refresh", %{
      problem_number: problem_number,
      problem_statement: rendered_problem_statement,
      hint: rendered_hint,
      solution: rendered_solution,
      correct_answer: correct_answer,
      makeup_css: ctx.assigns.makeup_css
    })

    {:noreply, ctx}
  end

  defp process_with_makeup(text) do
    # Use a regex to find code blocks between ```elixir and ``` delimiters
    Regex.replace(~r/```elixir\n(.+?)\n```/s, text, fn _match, code ->
      # Apply syntax highlighting
      highlighted_code = Makeup.highlight(code, lexer: Makeup.Lexers.ElixirLexer)

      # Perform a safe string replacement for function names and keywords
      highlighted_code
      |> String.replace(~r/(?<=[^a-zA-Z0-9_])puts(?=[^a-zA-Z0-9_])/, ~s(<span class="nf">puts</span>))
      |> String.replace(~r/(?<=[^a-zA-Z0-9_])answer(?=[^a-zA-Z0-9_])/, ~s(<span class="nf">answer</span>))
      |> (fn hc -> "<pre><code class=\"highlight\">#{hc}</code></pre>" end).()
    end)
  end

  asset "main.js" do
    File.read!("lib/main.js")
  end
end

Kino.SmartCell.register(Hwsmartcell)
