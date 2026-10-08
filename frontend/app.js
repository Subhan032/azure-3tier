// Base URL for the Flask REST API (automatically detects local development vs Azure production)
const isLocalhost = window.location.hostname === "localhost" || window.location.hostname === "127.0.0.1";
const API_URL = window.API_URL || (isLocalhost ? "http://localhost:5000" : "https://app-azure-3tier-dev-backend.azurewebsites.net");

// DOM element references
const taskForm = document.getElementById("task-form");
const taskInput = document.getElementById("task-input");
const taskList = document.getElementById("task-list");
const emptyState = document.getElementById("empty-state");
const errorBanner = document.getElementById("error-banner");

// In-memory frontend task list
let tasks = [];

// Display an error message to the user
function showError(message) {
  errorBanner.textContent = message;
  errorBanner.classList.remove("hidden");
}

// Clear any displayed error message
function clearError() {
  errorBanner.textContent = "";
  errorBanner.classList.add("hidden");
}

// Render the list of tasks into the DOM
function renderTasks() {
  taskList.innerHTML = "";

  if (tasks.length === 0) {
    emptyState.classList.remove("hidden");
    return;
  }

  emptyState.classList.add("hidden");

  tasks.forEach((task) => {
    const li = document.createElement("li");
    li.className = `task-item ${task.completed ? "completed" : ""}`;

    // Task content (title and status badge)
    const contentDiv = document.createElement("div");
    contentDiv.className = "task-content";

    const titleSpan = document.createElement("span");
    titleSpan.className = "task-title";
    titleSpan.textContent = task.title;

    const badgeSpan = document.createElement("span");
    badgeSpan.className = `status-badge ${task.completed ? "done" : "pending"}`;
    badgeSpan.textContent = task.completed ? "Completed" : "Pending";

    contentDiv.appendChild(titleSpan);
    contentDiv.appendChild(badgeSpan);

    // Action buttons container
    const actionsDiv = document.createElement("div");
    actionsDiv.className = "task-actions";

    // Toggle complete button
    const toggleBtn = document.createElement("button");
    toggleBtn.className = "btn btn-toggle";
    toggleBtn.textContent = task.completed ? "Mark Incomplete" : "Mark Complete";
    toggleBtn.addEventListener("click", () => toggleTask(task.id, task.completed));

    // Delete button
    const deleteBtn = document.createElement("button");
    deleteBtn.className = "btn btn-delete";
    deleteBtn.textContent = "Delete";
    deleteBtn.addEventListener("click", () => deleteTask(task.id));

    actionsDiv.appendChild(toggleBtn);
    actionsDiv.appendChild(deleteBtn);

    li.appendChild(contentDiv);
    li.appendChild(actionsDiv);

    taskList.appendChild(li);
  });
}

// Fetch all tasks from the Flask API (GET /tasks)
async function fetchTasks() {
  clearError();
  try {
    const response = await fetch(`${API_URL}/tasks`);
    if (!response.ok) {
      throw new Error(`Failed to load tasks (Status: ${response.status})`);
    }
    tasks = await response.json();
    renderTasks();
  } catch (error) {
    console.error("Error fetching tasks:", error);
    showError("Could not connect to the API. Make sure the Flask backend is running on " + API_URL);
  }
}

// Add a new task (POST /tasks)
async function addTask(event) {
  event.preventDefault();
  clearError();

  const title = taskInput.value.trim();
  if (!title) {
    showError("Please enter a task title.");
    return;
  }

  try {
    const response = await fetch(`${API_URL}/tasks`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ title: title }),
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(errorData.error || `Failed to add task (Status: ${response.status})`);
    }

    const newTask = await response.json();
    tasks.push(newTask);
    renderTasks();
    taskInput.value = "";
  } catch (error) {
    console.error("Error adding task:", error);
    showError(error.message || "Failed to add task.");
  }
}

// Toggle a task's completed status (PUT /tasks/<id>)
async function toggleTask(id, currentCompleted) {
  clearError();
  try {
    const response = await fetch(`${API_URL}/tasks/${id}`, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ completed: !currentCompleted }),
    });

    if (!response.ok) {
      throw new Error(`Failed to update task (Status: ${response.status})`);
    }

    const updatedTask = await response.json();
    tasks = tasks.map((t) => (t.id === id ? updatedTask : t));
    renderTasks();
  } catch (error) {
    console.error("Error updating task:", error);
    showError(error.message || "Failed to update task status.");
  }
}

// Delete a task (DELETE /tasks/<id>)
async function deleteTask(id) {
  clearError();
  try {
    const response = await fetch(`${API_URL}/tasks/${id}`, {
      method: "DELETE",
    });

    if (!response.ok) {
      throw new Error(`Failed to delete task (Status: ${response.status})`);
    }

    tasks = tasks.filter((t) => t.id !== id);
    renderTasks();
  } catch (error) {
    console.error("Error deleting task:", error);
    showError(error.message || "Failed to delete task.");
  }
}

// Event Listeners
taskForm.addEventListener("submit", addTask);

// Load tasks when the page is loaded
document.addEventListener("DOMContentLoaded", fetchTasks);

