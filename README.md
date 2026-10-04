# Smart Traffic and Accident Response Management System

College DevOps project using:
- Git (Version Control)
- GitHub Actions (CI/CD)
- Docker (Containerization)

Application:
- Frontend: HTML, CSS, JavaScript
- Backend: Python Flask
- Database: MySQL

## Fast local setup
1. Start MySQL.
2. Run `database/schema.sql` in MySQL Workbench.
3. Open this folder in VS Code.
4. Run:
   python -m venv venv
   venv\Scripts\activate
   pip install -r backend/requirements.txt
5. If your MySQL password is not blank, set:
   $env:DB_PASSWORD="YOUR_PASSWORD"
6. Run:
   python backend/app.py
7. Open http://localhost:5000

## Docker setup
Docker Desktop must be running.
From the project root:
    docker compose up --build
Open http://localhost:5000

Stop:
    docker compose down

## Git
    git init
    git add .
    git commit -m "Initial Smart Traffic project"
    git branch -M main
    git remote add origin YOUR_GITHUB_REPOSITORY_URL
    git push -u origin main

GitHub Actions is already included in `.github/workflows/ci.yml`.
It installs dependencies, runs tests, and builds the Docker image.

