import os
import time
from flask import Flask, jsonify, request
from flask_cors import CORS
import psycopg
from psycopg.rows import dict_row

app = Flask(__name__)

# Enable CORS so the frontend can interact with this API during local development
CORS(app)

# Database configuration read from environment variables
DB_HOST = os.environ.get("DB_HOST", "localhost")
DB_PORT = os.environ.get("DB_PORT", "5432")
DB_NAME = os.environ.get("DB_NAME", "taskmanager")
DB_USER = os.environ.get("DB_USER", "postgres")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "postgres_dev_password")


def get_db_connection():
    """Establish and return a connection to the PostgreSQL database."""
    return psycopg.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        row_factory=dict_row,
    )


def init_db():
    """Wait for PostgreSQL to be ready and ensure the tasks table exists."""
    retries = 10
    while retries > 0:
        try:
            with get_db_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute("""
                        CREATE TABLE IF NOT EXISTS tasks (
                            id SERIAL PRIMARY KEY,
                            title VARCHAR(255) NOT NULL,
                            completed BOOLEAN DEFAULT FALSE,
                            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                        );
                    """)
                conn.commit()
            print("Successfully connected to PostgreSQL and verified 'tasks' table.")
            return
        except Exception as e:
            retries -= 1
            print(f"Waiting for PostgreSQL database to be ready... ({retries} retries remaining): {e}")
            time.sleep(2)
    print("Warning: Could not connect to PostgreSQL during initial startup.")


@app.route("/", methods=["GET"])
def home():
    """Root health check endpoint."""
    return jsonify({"message": "Azure Task Manager API is running"}), 200


@app.route("/tasks", methods=["GET"])
def get_tasks():
    """Retrieve all tasks from PostgreSQL."""
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT id, title, completed, created_at FROM tasks ORDER BY id ASC;")
                tasks = cur.fetchall()
        return jsonify(tasks), 200
    except Exception as e:
        return jsonify({"error": f"Database error: {str(e)}"}), 500


@app.route("/tasks", methods=["POST"])
def create_task():
    """Create a new task in PostgreSQL."""
    data = request.get_json(silent=True) or {}
    title = data.get("title")

    # Validate that title exists and is not empty
    if not title or not isinstance(title, str) or not title.strip():
        return jsonify({"error": "Task title is required and cannot be empty"}), 400

    try:
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    "INSERT INTO tasks (title, completed) VALUES (%s, %s) RETURNING id, title, completed, created_at;",
                    (title.strip(), False),
                )
                new_task = cur.fetchone()
            conn.commit()
        return jsonify(new_task), 201
    except Exception as e:
        return jsonify({"error": f"Database error: {str(e)}"}), 500


@app.route("/tasks/<int:id>", methods=["PUT"])
def update_task(id):
    """Toggle or update the completed status of a task."""
    data = request.get_json(silent=True) or {}

    try:
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT id, title, completed FROM tasks WHERE id = %s;", (id,))
                task = cur.fetchone()
                if task is None:
                    return jsonify({"error": "Task not found"}), 404

                # Update completed status based on request, or toggle it if omitted
                if "completed" in data:
                    new_status = bool(data["completed"])
                else:
                    new_status = not task["completed"]

                cur.execute(
                    "UPDATE tasks SET completed = %s WHERE id = %s RETURNING id, title, completed, created_at;",
                    (new_status, id),
                )
                updated_task = cur.fetchone()
            conn.commit()
        return jsonify(updated_task), 200
    except Exception as e:
        return jsonify({"error": f"Database error: {str(e)}"}), 500


@app.route("/tasks/<int:id>", methods=["DELETE"])
def delete_task(id):
    """Delete a task by ID."""
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("DELETE FROM tasks WHERE id = %s RETURNING id;", (id,))
                deleted = cur.fetchone()
                if deleted is None:
                    return jsonify({"error": "Task not found"}), 404
            conn.commit()
        return jsonify({"message": "Task deleted successfully"}), 200
    except Exception as e:
        return jsonify({"error": f"Database error: {str(e)}"}), 500


if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000, debug=False)
