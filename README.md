# AEGIS — Smart Traffic & Accident Response System

> **One dashboard. Faster visibility. Better incident coordination.**

AEGIS is a web-based academic prototype for recording road accidents, viewing traffic conditions, and checking ambulance and hospital information from one control-center dashboard.

## At a glance

- **Accident management** — report incidents and review severity and response status.
- **Traffic monitoring** — view road-condition records and add updates.
- **Emergency resources** — browse ambulance and hospital availability.
- **Live database check** — verify the Flask API–MySQL connection.
- **DevOps foundation** — Docker Compose setup and a GitHub Actions workflow.

> **Project scope:** AEGIS is a learning/demo system. It does not provide verified live traffic feeds, AI accident prediction, or real emergency-service dispatch. Use demonstration data only.

## Technology

`HTML` · `CSS` · `JavaScript` · `Python` · `Flask` · `MySQL 8` · `Docker` · `GitHub Actions` · `pytest`

## Run on Windows

### 1. Prepare MySQL
Start **MySQL Server**, open MySQL Workbench, then open and execute `database/schema.sql`. It creates the `smart_traffic_db` database and the required tables.

### 2. Install Python dependencies
Open the project root in VS Code (**the folder containing `backend`, `frontend`, and `database`**) and choose **Terminal → New Terminal**.

```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
python -m pip install -r backend/requirements.txt
```

### 3. Configure the database password
If your local MySQL `root` user has a password, set it in this same terminal:

```powershell
$env:DB_PASSWORD="YOUR_MYSQL_PASSWORD"
```

The default connection settings are `localhost:3306`, user `root`, and database `smart_traffic_db`. If yours differ, set `DB_HOST`, `DB_PORT`, `DB_USER`, or `DB_NAME` in the same terminal.

### 4. Start the application

```powershell
python backend/app.py
```

Open **http://localhost:5000**. Keep the terminal running while using the site.

Check the database connection at **http://localhost:5000/api/health**. A successful response contains `"status": "ok"` and `"database": "connected"`.

## API essentials

| Method | Endpoint | Purpose |
|---|---|---|
| `GET` | `/api/health` | Backend/database health |
| `GET` | `/api/dashboard` | Dashboard summary counts |
| `GET` / `POST` | `/api/accidents` | List or report an accident |
| `PATCH` | `/api/accidents/<id>/status` | Update incident status |
| `GET` / `POST` | `/api/traffic` | View or add traffic records |
| `GET` | `/api/ambulances` | View ambulance records |
| `GET` | `/api/hospitals` | View hospital records |

## Run with Docker (optional)

With Docker Desktop running, use the project root terminal:

```powershell
docker compose up --build
```

Visit **http://localhost:5000**. Stop the stack with `docker compose down`. Docker maps its MySQL service to port `3307` on the host.

## Repository map

```text
backend/      Flask routes and MySQL helpers
frontend/     Dashboard, accident and traffic pages
database/     MySQL schema and demo records
tests/        Automated tests
.github/      GitHub Actions workflow
Dockerfile    Web application image
docker-compose.yml
```

## Test

```powershell
python -m pytest -q
```

## Safety & security

Do not commit database passwords or private data. Before real-world deployment, add secure authentication, authorization, input protections, secret management, HTTPS, backups, monitoring, and verified emergency-service integrations.

---
**AEGIS** · Smart city response prototype · Built for academic learning and demonstration
