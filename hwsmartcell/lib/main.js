export function init(ctx, payload) {
    // Include Tailwind CSS
    const tailwindLink = document.createElement("link");
    tailwindLink.rel = "stylesheet";
    tailwindLink.href = "https://cdnjs.cloudflare.com/ajax/libs/tailwindcss/2.2.19/tailwind.min.css";
    document.head.appendChild(tailwindLink);

    // Include Makeup CSS
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

    // Tab switching logic
    const tabs = {
      problem_tab: payload.problem_statement,
      hint_tab: payload.hint,
      solution_tab: payload.solution
    };

    function setActiveTab(activeTab) {
      // Set active content
      document.getElementById('content').innerHTML = tabs[activeTab];

      // Update tab styles
      document.querySelectorAll('.tab_button').forEach(button => {
        button.classList.remove('text-blue-500', 'font-bold', 'border-b-2', 'border-blue-500');
        button.classList.add('text-gray-500');
      });
      document.getElementById(activeTab).classList.add('text-blue-500', 'font-bold', 'border-b-2', 'border-blue-500');
      document.getElementById(activeTab).classList.remove('text-gray-500');

      // Display input only on the Problem Statement tab
      if (activeTab === 'problem_tab') {
        document.getElementById('input_section').innerHTML = `
          <input type="text" id="text_input" class="w-full p-2 border border-gray-300 rounded-md" placeholder="Type your answer here...">
          <button id="submit_button" class="mt-2 p-2 bg-blue-500 text-white rounded-md">Submit</button>
        `;

        const textInput = document.getElementById('text_input');
        const submitButton = document.getElementById('submit_button');

        // Add event listener for the submit button
        submitButton.addEventListener('click', () => {
          const inputValue = textInput.value;
          ctx.pushEvent('check_answer', { input_value: inputValue });
        });

        // Add event listener for the "Enter" key press
        textInput.addEventListener('keydown', (event) => {
          if (event.key === 'Enter') {
            event.preventDefault(); // Prevent form submission or other default behavior
            submitButton.click(); // Trigger the submit button click
          }
        });
      } else {
        document.getElementById('input_section').innerHTML = ''; // Clear the input section on other tabs
      }
    }

    // Edit button logic
    document.getElementById('edit_button').addEventListener('click', () => {
      document.querySelector('section').classList.toggle('hidden');
      document.getElementById('edit_section').classList.toggle('hidden');
    });

    // Save button logic
    document.getElementById('save_button').addEventListener('click', () => {
      const problemNumber = document.getElementById('problem_number').value;
      const problemStatement = document.getElementById('problem_statement').value;
      const hint = document.getElementById('hint').value;
      const solution = document.getElementById('solution').value;
      const correctAnswer = document.getElementById('correct_answer').value;

      ctx.pushEvent('save_edits', {
        problem_number: problemNumber,
        problem_statement: problemStatement,
        hint: hint,
        solution: solution,
        correct_answer: correctAnswer
      });

      // Update header and content
      document.getElementById('header').textContent = `Problem ${problemNumber}`;
      tabs.problem_tab = problemStatement;
      tabs.hint_tab = hint;
      tabs.solution_tab = solution;

      // Switch back to view mode
      document.querySelector('section').classList.toggle('hidden');
      document.getElementById('edit_section').classList.toggle('hidden');
    });

    // Initial tab display
    setActiveTab('problem_tab');

    // Event listeners for tabsa
    document.getElementById('problem_tab').addEventListener('click', () => setActiveTab('problem_tab'));
    document.getElementById('hint_tab').addEventListener('click', () => setActiveTab('hint_tab'));
    document.getElementById('solution_tab').addEventListener('click', () => setActiveTab('solution_tab'));

    // Handle feedback events
    ctx.handleEvent('feedback', ({ message, color }) => {
      const feedbackSection = document.getElementById('feedback');
      feedbackSection.textContent = message;
      feedbackSection.className = `mt-4 font-bold ${color}`;
    });

    // Handle refresh events
    ctx.handleEvent('refresh', (payload) => {
      tabs.problem_tab = payload.problem_statement;
      tabs.hint_tab = payload.hint;
      tabs.solution_tab = payload.solution;
      setActiveTab('problem_tab');
    });
  }
  