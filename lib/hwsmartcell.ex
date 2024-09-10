defmodule Hwsmartcell do
  use Kino.JS, assets_path: "lib/assets"
  use Kino.JS.Live
  use Kino.SmartCell, name: "Homework Smartcell"

  @impl true
  def init(attrs, ctx) do
    problem_number = attrs["problem_number"] || "1"
    problem_type = attrs["problem_type"] || "text"
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
    test_code = attrs["test_code"] || ":evaluated"

    # Process the problem statement with Makeup
    rendered_problem_statement = process_with_makeup(problem_statement)
    rendered_hint = process_with_makeup(hint)
    rendered_solution = process_with_makeup(solution)

    # Generate the Makeup CSS
    makeup_css = makeup_stylesheet()

    ctx = assign(ctx,
     problem_number: problem_number,
     problem_type: problem_type,
     problem_statement: rendered_problem_statement,
     hint: rendered_hint,
     solution: rendered_solution,
     correct_answer: correct_answer,
     test_code: test_code,
     makeup_css: makeup_css
    )

    {:ok, ctx}
  end

  @impl true
  def handle_connect(ctx) do
    {:ok, %{
      problem_number: ctx.assigns.problem_number,
      problem_type: ctx.assigns.problem_type,
      problem_statement: ctx.assigns.problem_statement,
      hint: ctx.assigns.hint,
      solution: ctx.assigns.solution,
      correct_answer: ctx.assigns.correct_answer,
      test_code: ctx.assigns.test_code,
      makeup_css: ctx.assigns.makeup_css
    }, ctx}
  end

  @impl true
  def to_attrs(ctx) do
    %{
      "problem_number" => ctx.assigns.problem_number,
      "problem_type" => ctx.assigns.problem_type,
      "problem_statement" => ctx.assigns.problem_statement,
      "hint" => ctx.assigns.hint,
      "solution" => ctx.assigns.solution,
      "correct_answer" => ctx.assigns.correct_answer,
      "test_code" => ctx.assigns.test_code
    }
  end

  @impl true
  def to_source(attrs) do
    """
    #Problem_Number:
    _ = "#{attrs["problem_number"]}"

    #Problem_Statement:
    _ = ~s#{inspect(attrs["problem_statement"], raw: true)}

    #Hint:
    _ = ~s#{inspect(attrs["hint"], raw: true)}

    #Solution:
    _ = ~s#{inspect(attrs["solution"], raw: true)}

    #Correct Answer:
    _ = ~s#{inspect(attrs["correct_answer"], raw: true)}

    #Test Code:
    _ = #{attrs["test_code"]}
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
    "problem_type" => problem_type,
    "problem_statement" => problem_statement,
    "hint" => hint,
    "solution" => solution,
    "correct_answer" => correct_answer,
    "test_code" => test_code
  }, ctx) do
    ctx = assign(ctx,
    problem_number: problem_number,
    problem_type: problem_type,
    problem_statement: problem_statement,
    hint: hint,
    solution: solution,
    correct_answer: correct_answer,
    test_code: test_code
  )


      # Process the text with Makeup
    rendered_problem_statement = process_with_makeup(problem_statement)
    rendered_hint = process_with_makeup(hint)
    rendered_solution = process_with_makeup(solution)


    # Send the rendered HTML and CSS to the client-side for display
    broadcast_event(ctx, "refresh", %{
      problem_number: problem_number,
      problem_type: problem_type,
      problem_statement: rendered_problem_statement,
      hint: rendered_hint,
      solution: rendered_solution,
      correct_answer: correct_answer,
      test_code: test_code,
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







  defp makeup_stylesheet do
    """
    .highlight .hll { background-color: #111827; }
    .highlight { color: #e7e9db; background-color: #111827; }

    pre {
        border-radius: 0.5rem;
        margin-top: 0.2rem;
        margin-bottom: 0;
        padding: 1rem;
    }

    .highlight .unselectable {
        -webkit-touch-callout: none;
        -webkit-user-select: none;
        -khtml-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
        user-select: none;
    }

    /* Built-in pseudo elements */
    .highlight .bp { color: #e7e9db; }

    /* Comments */
    .highlight .c { color: #8c92a3 !important; }
    .highlight .c * { color: #8c92a3 !important; }
    .highlight .c1 { color: #8c92a3 !important; }
    .highlight .c1 * { color: #8c92a3 !important; }
    .highlight .ch { color: #8c92a3 !important; }
    .highlight .ch * { color: #8c92a3 !important; }
    .highlight .cm { color: #8c92a3 !important; }
    .highlight .cm * { color: #8c92a3 !important; }
    .highlight .cp { color: #8c92a3 !important; }
    .highlight .cp * { color: #8c92a3 !important; }
    .highlight .cpf { color: #8c92a3 !important; }
    .highlight .cpf * { color: #8c92a3 !important; }
    .highlight .cs { color: #8c92a3 !important; }
    .highlight .cs * { color: #8c92a3 !important; }

    /* String Delimiters */
    .highlight .dl { color: #98c379; }

    /* Errors */
    .highlight .err { color: #ef6155; }

    /* Function magic */
    .highlight .fm { color: #06b6ef; }

    /* Generic styles */
    .highlight .gd { color: #ef6155; }
    .highlight .ge { font-style: italic; }
    .highlight .gh { color: #e7e9db; font-weight: bold; }
    .highlight .gi { color: #61afef; }
    .highlight .gp { color: #8c92a3; font-weight: bold; }
    .highlight .gs { font-weight: bold; }
    .highlight .gu { color: #5bc4bf; font-weight: bold; }

    /* Numbers */
    .highlight .il { color: #61afef; }
    .highlight .k { color: #c678dd; } /* Keywords */
    .highlight .kc { color: #c678dd; } /* Keyword constant */
    .highlight .kd { color: #c678dd; } /* Keyword declaration */
    .highlight .kn { color: #5bc4bf; } /* Keyword namespace */
    .highlight .kp { color: #c678dd; } /* Keyword pseudo */
    .highlight .kr { color: #c678dd; } /* Keyword reserved */
    .highlight .kt { color: #fec418; } /* Keyword type */

    /* Literals */
    .highlight .l { color: #61afef; }
    .highlight .ld { color: #61afef; }

    /* Numbers */
    .highlight .m { color: #61afef; }
    .highlight .mb { color: #61afef; }
    .highlight .mf { color: #61afef; }
    .highlight .mh { color: #61afef; }
    .highlight .mi { color: #61afef; }
    .highlight .mo { color: #61afef; }

    /* Names */
    .highlight .n { color: #e7e9db; }
    .highlight .na { color: #06b6ef; } /* Name attribute */
    .highlight .nb { color: #e7e9db; } /* Name built-in */
    .highlight .nc { color: #56b6c2; } /* Name class - Updated color */
    .highlight .nd { color: #d19a66; } /* Name decorator */
    .highlight .ne { color: #ef6155; } /* Name exception */
    .highlight .nf { color: #61afef; } /* Name function */
    .highlight .ni { color: #e7e9db; } /* Name entity */
    .highlight .nl { color: #61afef; } /* Name label */
    .highlight .nn { color: #56b6c2; } /* Name namespace - Updated color */
    .highlight .no { color: #61afef; } /* Name constant */
    .highlight .nt { color: #d19a66; } /* Name tag */
    .highlight .nv { color: #ef6155; } /* Name variable */
    .highlight .nx { color: #61afef; } /* Name other */

    /* Operators */
    .highlight .o { color: #d19a66; }
    .highlight .ow { color: #d19a66; }

    /* Punctuation */
    .highlight .p { color: #e7e9db; }

    /* Properties */
    .highlight .py { color: #e7e9db; }

    /* Strings */
    .highlight .s { color: #98c379; }
    .highlight .s1 { color: #98c379; }
    .highlight .s2 { color: #98c379; }
    .highlight .sa { color: #98c379; }
    .highlight .sb { color: #98c379; }
    .highlight .sc { color: #e7e9db; }
    .highlight .sd { color: #776e71; }
    .highlight .se { color: #f99b15; }
    .highlight .sh { color: #98c379; }
    .highlight .si { color: #f99b15; }
    .highlight .sr { color: #98c379; }
    .highlight .ss { color: #61afef; }
    .highlight .sx { color: #61afef; } /* String other, also used for sigils */

    /* Variables */
    .highlight .vc { color: #ef6155; } /* Variable class */
    .highlight .vg { color: #ef6155; } /* Variable global */
    .highlight .vi { color: #ef6155; } /* Variable instance */
    .highlight .vm { color: #ef6155; } /* Variable magic */
    .highlight .vn { color: #ef6155; } /* Variable namespace */
    .highlight .vq { color: #ef6155; } /* Variable pseudo */
    .highlight .vs { color: #ef6155; } /* Variable special */
    .highlight .w { color: #e7e9db; } /* Whitespace */
    """
  end
end
