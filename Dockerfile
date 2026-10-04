FROM python:3.12-slim
WORKDIR /app
COPY backend/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt
COPY backend /app/backend
COPY frontend /app/frontend
ENV PYTHONUNBUFFERED=1
ENV DB_HOST=db
ENV DB_PORT=3306
ENV DB_USER=traffic_user
ENV DB_PASSWORD=traffic_pass
ENV DB_NAME=smart_traffic_db
EXPOSE 5000
CMD ["python", "backend/app.py"]
