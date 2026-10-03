# Déploiement LOBICOP

La version 0.2.19 utilise Flask/WSGI. Pour PythonAnywhere, voir `PYTHONANYWHERE.md`.

Entrée WSGI : `wsgi.py` → `server.main:app`.

Dépendances : `requirements.txt`.

En local :

```bash
python3 -m pip install -r requirements.txt
python3 server/main.py
```

ou avec Flask :

```bash
flask --app server.main:app run --host 0.0.0.0 --port 8787
```

Les données persistantes restent dans `data/`, ou dans le dossier défini par `LOBICOP_DATA_DIR`.
