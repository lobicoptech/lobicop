FROM python:3.12-slim

WORKDIR /app
COPY . /app

# Aucune dépendance externe : le serveur utilise uniquement la bibliothèque
# standard de Python (http.server, sqlite3, json).
ENV NZELA_HOST=0.0.0.0
ENV PORT=8787
EXPOSE 8787

CMD ["python3", "server/main.py"]
