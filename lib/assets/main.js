export function init(ctx, payload) {
    // Include Tailwind CSS
    const tailwindLink = document.createElement("link");
    tailwindLink.rel = "stylesheet";
    tailwindLink.href = "https://cdnjs.cloudflare.com/ajax/libs/tailwindcss/2.2.19/tailwind.min.css";
    document.head.appendChild(tailwindLink);

    // Include Makeup CSS from the payload
    const makeupStyle = document.createElement("style");
    makeupStyle.textContent = payload.makeup_css || '';
    document.head.appendChild(makeupStyle);

    ctx.root.innerHTML = `
      <style>
        pill {
          display: inline-block;
          padding: 0.1rem 0.5rem;
          border-radius: 0.5rem;
          background-color: #e2e8f0;
          color: #000000;
          font-size: 1rem;
          line-height: 1.25rem;
          font-family: JetBrains Mono, monospace;
        }
      </style>

      <section id="main_section" class="bg-gray-100 p-4 rounded-md relative" style="display:block;">
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

      <section id="edit_section" class="bg-white p-4 rounded-md hidden" style="display:none;">
        <h2 class="text-xl font-bold mb-4">Edit Problem</h2>
        <div class="mb-4">
          <label class="block text-gray-700 text-sm font-bold mb-2" for="problem_number">Problem Number</label>
          <input type="text" id="problem_number" class="w-full p-2 border border-gray-300 rounded-md" value="${payload.problem_number}">
        </div>
        <div class="mb-4">
          <label class="block text-gray-700 text-sm font-bold mb-2" for="problem_type">Problem Type</label>
          <textarea id="problem_type" class="w-full p-2 border border-gray-300 rounded-md">${payload.problem_type}</textarea>
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
        <div class="mb-4">
          <label class="block text-gray-700 text-sm font-bold mb-2" for="test_code">Test Code</label>
          <textarea id="test_code" rows="6" class="w-full p-2 border border-gray-300 rounded-md">${payload.test_code || ''}</textarea>
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
    const mainSection = ctx.root.querySelector("#main_section");

    const tabs = {
      "problem_statement": payload.problem_statement,
      "hint": payload.hint,
      "solution": payload.solution
    };

    // Add Tab listeners 
    problemTab.addEventListener("click", () => displayContent("problem_statement", problemTab, payload.problem_type));
    hintTab.addEventListener("click", () => displayContent("hint", hintTab, payload.problem_type));
    solutionTab.addEventListener("click", () => displayContent("solution", solutionTab, payload.problem_type));
    


    function displayContent(tab, activeTab, arg) {
      content.innerHTML = tabs[tab];

      // Update active class
      document.querySelectorAll(".tab_button").forEach(btn => {
        btn.classList.remove("text-blue-500", "font-bold", "border-b-2", "border-blue-500");
        btn.classList.add("text-gray-500");
      });
      activeTab.classList.add("text-blue-500", "font-bold", "border-b-2", "border-blue-500");
      activeTab.classList.remove("text-gray-500");

      // Display input only on the Problem Statement tab
      if (tab === "problem_statement" && arg ==="text") {
        inputSection.innerHTML = `
          <input type="text" id="text_input" class="w-full p-2 border border-gray-300 rounded-md" placeholder="Type your answer here...">
          <button id="submit_button" class="mt-2 p-2 bg-blue-500 text-white rounded-md">Submit</button>
        `;

        const textInput = document.getElementById('text_input');
        const submitButton = document.getElementById('submit_button');

        // Event listener for the submit button
        submitButton.addEventListener("click", () => {
          const inputValue = textInput.value;
          ctx.pushEvent("check_answer", { input_value: inputValue });
        });

        // Event listener for the "Enter" key press
        textInput.addEventListener("keydown", (event) => {
          if (event.key === "Enter") {
            event.preventDefault(); // Prevent form submission or other default behavior
            submitButton.click(); // Trigger the submit button click
          }
        });
      } else {
        inputSection.innerHTML = ""; // Clear the input section on other tabs
      }
    }


    displayContent("problem_statement", problemTab, payload.problem_type); // Show the problem statement by default LML

    // Edit button logic
    editButton.addEventListener("click", () => {
      mainSection.style.display = mainSection.style.display === "none" ? "block" : "none";
      editSection.style.display = editSection.style.display === "none" ? "block" : "none";
    });

    // Save button logic
    document.getElementById('save_button').addEventListener('click', () => {
      const problemNumber = document.getElementById('problem_number').value;
      const problemType = document.getElementById('problem_type').value;
      const problemStatement = document.getElementById('problem_statement').value;
      const hint = document.getElementById('hint').value;
      const solution = document.getElementById('solution').value;
      const correctAnswer = document.getElementById('correct_answer').value;
      const testCode = document.getElementById('test_code').value;


      ctx.pushEvent('save_edits', {
        problem_number: problemNumber,
        problem_type: problemType,
        problem_statement: problemStatement,
        hint: hint,
        solution: solution,
        correct_answer: correctAnswer,
        test_code: testCode,
      });

      // Switch back to view mode
      mainSection.style.display = mainSection.style.display === "none" ? "block" : "none";
      editSection.style.display = editSection.style.display === "none" ? "block" : "none";
    });

    // Handle feedback events
    ctx.handleEvent("feedback", ({ message, color }) => {
      feedbackSection.textContent = message;
      feedbackSection.className = `mt-4 font-bold ${color}`;
    });

    ctx.handleEvent("refresh", (payload) => {
      // Update the payload
      payload.problem_number = payload.problem_number;
      payload.problem_type = payload.problem_type;
      payload.correct_answer = payload.correct_answer;
      payload.test_code = payload.test_code;

      // Update the header
      document.getElementById('header').textContent = `Problem ${payload.problem_number}`;

      // Update the tabs with the new content
      tabs["problem_statement"] = payload.problem_statement;
      tabs["hint"] = payload.hint;
      tabs["solution"] = payload.solution;

      // Re-display the current tab content
      displayContent("problem_statement", problemTab, payload.problem_type);

    });
  }