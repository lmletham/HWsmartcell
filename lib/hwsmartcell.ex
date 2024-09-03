defmodule Hwsmartcell do
  use Kino.JS
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

    #Determine whether to show the input box
    show_input_box = problem_type == "text"

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
     makeup_css: makeup_css,
     show_input_box: show_input_box
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
      makeup_css: ctx.assigns.makeup_css,
      show_input_box: ctx.assigns.show_input_box
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
    # Split the text into sections outside and inside code blocks
    Regex.replace(~r/```elixir\n(.+?)\n```/s, text, fn _match, code ->
      # Apply syntax highlighting to the code block
      highlighted_code = Makeup.highlight(code, lexer: Makeup.Lexers.ElixirLexer)

      # Wrap the highlighted code in a pre block with padding
      "<pre style=\"margin-top: 1rem; margin-bottom: 0; padding: 1rem; background-color: #111827;\"><code class=\"highlight\">#{highlighted_code}</code></pre>"
    end)
    # After processing code blocks, replace newlines in the remaining text with <br> tags
    |> String.replace(~r/(?!<\/?pre[^>]*>)(\n)(?!<\/?code[^>]*>)/, "<br>")
    # Ensure any double newlines are converted into paragraph breaks for larger spacing
    |> String.replace(~r/\n\n/, "<p></p>")
  end

  defp makeup_stylesheet do
    """
    .highlight .hll { background-color: #111827; }
    .highlight { color: #e7e9db; background-color: #111827; }

    pre {
      border-radius: 0.5rem;
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

  asset "main.js" do
    """
    export function init(ctx, payload) {
      // Include Tailwind CSS
      const tailwindLink = document.createElement("link");
      tailwindLink.rel = "stylesheet";
      tailwindLink.href = "https://cdnjs.cloudflare.com/ajax/libs/tailwindcss/2.2.19/tailwind.min.css";
      document.head.appendChild(tailwindLink);

      // Include Makeup CSS from the payload
      const makeupStyle = document.createElement("style");
      makeupStyle.textContent = payload.makeup_css;
      document.head.appendChild(makeupStyle);

      ctx.root.innerHTML = `
        <section class="bg-gray-100 p-4 rounded-md relative">
          <button id="edit_button" class="absolute top-2 right-2 bg-blue-500 text-white p-2 rounded-md hover:bg-blue-600">Edit</button>
          <h2 id="header" class="text-2xl font-bold mb-4">Problem ${payload.problem_number}</h2>
          <div id="tabs" class="border-b border-gray-300 mb-4 flex">
            <button id="problem_tab" class="tab_button text-blue-500 font-bold border-b-2 border-blue-500 py-2 px-4">Problem Statement</button>
            <button id="hint_tab" class="tab_button text-gray-500 py-2 px-4">Hint</button>
            <button id="solution_tab" class="tab_button text-gray-500 py-2 px-4">Solution</button>
          </div>
          <div id="content" class="mt-4 p-4 bg-white rounded-md shadow-md">${payload.problem_statement}</div>
          <div id="input_section" class="mt-4"></div>
          <div id="feedback" class="mt-4 font-bold"></div>
        </section>

        <section id="edit_section" class="bg-white p-4 rounded-md hidden">
          <h2 class="text-xl font-bold mb-4">Edit Problem</h2>
          <div class="mb-4">
            <label class="block text-gray-700 text-sm font-bold mb-2" for="problem_number">Problem Number</label>
            <input type="text" id="problem_number" class="w-full p-2 border border-gray-300 rounded-md" value="${payload.problem_number}">
          </div>
          <div class="mb-4">
            <label class="block text-gray-700 text-sm font-bold mb-2" for="problem_type">Problem Type</label>
            <select id="problem_type" class="w-full p-2 border border-gray-300 rounded-md">
              <option value="text" ${payload.problem_type === 'text' ? 'selected' : ''}>Text</option>
              <option value="elixir" ${payload.problem_type === 'elixir' ? 'selected' : ''}>Elixir</option>
            </select>
          </div>
          <div class="mb-4">
            <label class="block text-gray-700 text-sm font-bold mb-2" for="problem_statement">Problem Statement</label>
            <textarea id="problem_statement" rows="6" class="w-full p-2 border border-gray-300 rounded-md">${payload.problem_statement}</textarea>
          </div>
          <div class="mb-4">
            <label class="block text-gray-700 text-sm font-bold mb-2" for="hint">Hint</label>
            <textarea id="hint" rows="4" class="w-full p-2 border border-gray-300 rounded-md">${payload.hint}</textarea>
          </div>
          <div class="mb-4">
            <label class="block text-gray-700 text-sm font-bold mb-2" for="solution">Solution</label>
            <textarea id="solution" rows="4" class="w-full p-2 border border-gray-300 rounded-md">${payload.solution}</textarea>
          </div>
          <div class="mb-4">
            <label class="block text-gray-700 text-sm font-bold mb-2" for="correct_answer">Correct Answer</label>
            <input type="text" id="correct_answer" class="w-full p-2 border border-gray-300 rounded-md" value="${payload.correct_answer}">
          </div>
          <button id="save_button" class="mt-2 p-2 bg-blue-500 text-white rounded-md">Save</button>
        </section>
      `;

      const problemTab = ctx.root.querySelector("#problem_tab");
      const hintTab = ctx.root.querySelector("#hint_tab");
      const solutionTab = ctx.root.querySelector("#solution_tab");
      const content = ctx.root.querySelector("#content");
      const inputSection = ctx.root.querySelector("#input_section");
      const feedbackSection = ctx.root.querySelector("#feedback");
      const editButton = ctx.root.querySelector("#edit_button");
      const editSection = ctx.root.querySelector("#edit_section");
      const mainSection = ctx.root.querySelector("section");

      const tabs = {
        "problem_statement": payload.problem_statement,
        "hint": payload.hint,
        "solution": payload.solution
      };

      function displayContent(tab, activeTab) {
        content.innerHTML = tabs[tab];

        // Update active class
        document.querySelectorAll(".tab_button").forEach(btn => {
          btn.classList.remove("text-blue-500", "font-bold", "border-b-2", "border-blue-500");
          btn.classList.add("text-gray-500");
        });
        activeTab.classList.add("text-blue-500", "font-bold", "border-b-2", "border-blue-500");
        activeTab.classList.remove("text-gray-500");

        // Display input only on the Problem Statement tab
        if (tab === "problem_statement") {
          if (payload.problem_type === "text") {
            inputSection.innerHTML = `
              <input type="text" id="text_input" class="w-full p-2 border border-gray-300 rounded-md" placeholder="Type your answer here...">
              <button id="submit_button" class="mt-2 p-2 bg-blue-500 text-white rounded-md">Submit</button>
            `;

            const textInput = inputSection.querySelector("#text_input");
            const submitButton = inputSection.querySelector("#submit_button");

            submitButton.addEventListener("click", () => {
              const inputValue = textInput.value;
              ctx.pushEvent("check_answer", { input_value: inputValue });
            });
          } else if (payload.problem_type === "elixir") {
            inputSection.innerHTML = ""; // Display nothing if problem_type is "elixir"
          }
        } else {
          inputSection.innerHTML = ""; // Clear the input section on other tabs
        }
      }

      problemTab.addEventListener("click", () => displayContent("problem_statement", problemTab));
      hintTab.addEventListener("click", () => displayContent("hint", hintTab));
      solutionTab.addEventListener("click", () => displayContent("solution", solutionTab));

      displayContent("problem_statement", problemTab); // Show the problem statement by default

      // Edit button logic
      editButton.addEventListener("click", () => {
        mainSection.classList.toggle("hidden");
        editSection.classList.toggle("hidden");
      });

      // Save button logic
      const saveButton = ctx.root.querySelector("#save_button");
      saveButton.addEventListener("click", () => {
        const problemNumber = document.getElementById('problem_number').value;
        const problemType = document.getElementById('problem_type').value;
        const problemStatement = document.getElementById('problem_statement').value;
        const hint = document.getElementById('hint').value;
        const solution = document.getElementById('solution').value;
        const correctAnswer = document.getElementById('correct_answer').value;

        ctx.pushEvent('save_edits', {
          problem_number: problemNumber,
          problem_type: problemType,
          problem_statement: problemStatement,
          hint: hint,
          solution: solution,
          correct_answer: correctAnswer
        });

        // Update the payload and tabs
        payload.problem_number = problemNumber;
        payload.problem_type = problemType;
        payload.problem_statement = problemStatement;
        payload.hint = hint;
        payload.solution = solution;
        payload.correct_answer = correctAnswer;

        // Update header and content
        document.getElementById('header').textContent = `Problem ${problemNumber}`;
        tabs.problem_statement = problemStatement;
        tabs.hint = hint;
        tabs.solution = solution;

        // Switch back to view mode
        mainSection.classList.toggle("hidden");
        editSection.classList.toggle("hidden");

        // Refresh the active tab
        displayContent('problem_statement', problemTab);
      });

      ctx.handleEvent("feedback", ({ message, color }) => {
        feedbackSection.textContent = message;
        feedbackSection.className = `mt-4 font-bold ${color}`;
      });
    }
    """
  end
end

Kino.SmartCell.register(Hwsmartcell)
