# Smart Traffic & Accident Response Management System

A web-based traffic monitoring and accident response application built as a college mini project. It brings accident reports, traffic conditions, ambulance availability, and hospital information into one dashboard, with a DevOps workflow for testing and containerized builds.

[![Smart Traffic CI](https://github.com/vj5819601-stack/smart-traffic-accident-response-system/actions/workflows/ci.yml/badge.svg)](https://github.com/vj5819601-stack/smart-traffic-accident-response-system/actions/workflows/ci.yml)

## Project at a glance

| Layer | Technology |
|---|---|
| User interface | HTML, CSS, JavaScript |
| Application server | Python, Flask |
| Database | MySQL 8 |
| Version control | Git and GitHub |
| CI workflow | GitHub Actions |
| Containerization | Docker and Docker Compose |
| Automated checks | pytest |

## What the application supports

- **Accident reporting:** submit a report with reporter details, location, accident type, severity, and description.
- **Incident status tracking:** view reports and update an incident's response status through the API.
- **Traffic monitoring:** record road/area traffic levels and reasons for congestion.
- **Emergency resource directory:** view ambulance details and hospital availability.
- **Dashboard summary:** see totals for reported accidents, active and resolved incidents, available ambulances, and monitored traffic records.
- **Health endpoint:** check whether the Flask application can connect to MySQL.

> **Project scope:** this repository is a college mini project. It uses stored application data; it does not claim to provide live traffic feeds, automatic AI-based predictions, or real emergency-service dispatch.

## How the system is organised

```text
smart-traffic-system/
├── backend/
│   ├── app.py                 # Flask routes and API endpoints
│   ├── db.py                  # MySQL connection and query helpers
│   └── requirements.txt       # Python dependencies
├── frontend/
│   ├── index.html             # Main dashboard
│   ├── traffic.html           # Traffic page
│   ├── accident.html          # Accident page
│   ├── style.css              # Application styling
│   └── script.js              # Frontend behaviour
├── database/
│   └── schema.sql             # Database tables and starter records
├── tests/
│   └── test_app.py            # Basic automated tests
├── .github/
│   └── workflows/
│       └── ci.yml             # GitHub Actions test/build workflow
├── Dockerfile
├── docker-compose.yml
└── README.md
```

## Run locally on Windows

### 1. Requirements

Install the following first:

- Python 3.12 or a compatible Python version
- MySQL Server and MySQL Workbench
- Visual Studio Code (recommended)

### 2. Create the database

1. Start MySQL Server.
2. Open MySQL Workbench and connect to your local server.
3. Open `database/schema.sql` from this project.
4. Execute the script to create `smart_traffic_db`, its tables, and starter records.

### 3. Create a virtual environment

Open the project root folder in VS Code. Select **Terminal → New Terminal**, then run these commands in PowerShell:

```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r backend/requirements.txt
```

If PowerShell blocks virtual-environment activation, run this for the current terminal session and activate again:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\venv\Scripts\Activate.ps1
```

### 4. Configure the MySQL connection

The local defaults in `backend/db.py` are:

- Host: `localhost`
- Port: `3306`
- User: `root`
- Database: `smart_traffic_db`
- Password: blank

If your MySQL setup uses a different password, set it in the same PowerShell terminal before starting the app:

```powershell
$env:DB_PASSWORD="YOUR_MYSQL_PASSWORD"
```

If your MySQL username, host, port, or database name differs, set the matching environment variable too. For example:

```powershell
$env:DB_HOST="localhost"
$env:DB_PORT="3306"
$env:DB_USER="root"
$env:DB_NAME="smart_traffic_db"
```

### 5. Start the application

From the project root:

```powershell
python backend/app.py
```

Open **http://localhost:5000** in your browser.

Useful endpoints:

| Endpoint | Purpose |
|---|---|
| `http://localhost:5000/` | Main application |
| `http://localhost:5000/api/health` | Application/database health check |
| `http://localhost:5000/api/dashboard` | Dashboard summary data |
| `http://localhost:5000/api/accidents` | Accident records |
| `http://localhost:5000/api/traffic` | Traffic records |
| `http://localhost:5000/api/ambulances` | Ambulance directory |
| `http://localhost:5000/api/hospitals` | Hospital directory |

Stop the local server with **Ctrl + C** in the terminal.

## Run with Docker Compose

Docker Compose starts the Flask application and MySQL database together. In this mode, the database schema is mounted into MySQL's initialisation directory and is applied automatically when the database volume is first created.

1. Install and start Docker Desktop.
2. Open a terminal in the folder containing `docker-compose.yml`.
3. Build and start the services:

```powershell
docker compose up --build
```

4. Wait until the database health check passes, then open **http://localhost:5000**.

The Compose configuration maps MySQL to **localhost:3307** on the host and the web application to **localhost:5000**. The app container connects to MySQL internally using the service name `db` and port `3306`.

Stop the containers:

```powershell
docker compose down
```

Stop containers and remove the database volume (this permanently deletes the Compose database data):

```powershell
docker compose down -v
```

**Note:** the Compose file contains development-only database credentials for local learning. Do not reuse them in a production deployment. MySQL's initialisation scripts run only when its data directory is empty; if you change `schema.sql` after the volume has already been created, you may need to apply the changes manually or recreate the volume.

## DevOps workflow

This project demonstrates a simple source-to-build workflow:

1. **Git** records source-code changes.
2. **GitHub** hosts the repository and triggers automation.
3. **GitHub Actions** runs when code is pushed to `main`/`master` or a pull request targets those branches.
4. The workflow installs Python dependencies, runs the pytest suite, and builds the Docker image.
5. **Docker** packages the application environment into a container image for consistent local execution.

The workflow currently builds the image; it does **not** automatically publish it to a registry or deploy it to a live server.

### Run tests locally

With the virtual environment activated and project dependencies installed:

```powershell
pytest -q
```

### Build the Docker image manually

From the project root:

```powershell
docker build -t smart-traffic-system:local .
```

## Git and GitHub

If this folder is not already connected to a Git repository, run the following from the project root. Replace the repository URL with your own GitHub repository URL.

```powershell
git init
git add .
git commit -m "Add Smart Traffic and Accident Response System"
git branch -M main
git remote add origin YOUR_GITHUB_REPOSITORY_URL
git push -u origin main
```

If the repository is already connected to GitHub, you usually only need:

```powershell
git add .
git commit -m "Update project documentation"
git push
```

After pushing, open the repository's **Actions** tab on GitHub to view the CI workflow result.

## API examples

Create an accident report using PowerShell:

```powershell
$body = @{
  reporter_name = "Sample Reporter"
  contact = "9000000000"
  location = "Main Road"
  accident_type = "Vehicle Collision"
  severity = "High"
  description = "Two vehicles involved near the junction."
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5000/api/accidents" -Method Post -ContentType "application/json" -Body $body
```

Update an accident status:

```powershell
$body = @{ status = "Verified" } | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5000/api/accidents/1/status" -Method Patch -ContentType "application/json" -Body $body
```

Use an accident ID that exists in your database.

## Troubleshooting

- **`Access denied for user`:** check `DB_USER` and `DB_PASSWORD`, then verify that the MySQL account has access to `smart_traffic_db`.
- **`Can't connect to MySQL`:** confirm MySQL is running and that the selected port is correct.
- **Port 5000 is already in use:** stop the other process using that port or change the host-side port mapping in `docker-compose.yml`.
- **Docker cannot connect to its engine:** start Docker Desktop and wait until its engine is ready before running Compose.
- **The database tables are missing in Docker:** confirm the `database/schema.sql` mount is present. Existing named volumes are not re-initialised automatically.

## Learning outcomes

By completing this project, students can practise:

- organising a small full-stack web application;
- connecting Flask routes to a relational MySQL database;
- using Git for version control and GitHub for collaboration;
- running automated tests in a GitHub Actions pipeline;
- building and running services with Docker Compose;
- reading logs and troubleshooting application/database connectivity.

## Author / project details

**Project:** Smart Traffic & Accident Response Management System  
**Project type:** College mini project — DevOps and web application integration

---

*Built for learning and demonstration. Do not use this project as a substitute for a verified emergency response or traffic-management service.*
