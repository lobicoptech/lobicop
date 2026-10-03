# Déploiement LOBICOP sur PythonAnywhere

## 1. Envoyer le projet
Décompresser le projet dans, par exemple :

`/home/VOTRE_NOM/lobicop`

## 2. Installer les dépendances
Dans une console Bash PythonAnywhere :

```bash
cd /home/VOTRE_NOM/lobicop
python3 -m pip install --user -r requirements.txt
```

Il est recommandé d'utiliser un virtualenv Python 3.10+ si votre compte le permet.

## 3. Créer l'application Web
Dans **Web → Add a new web app** :

- Framework : **Manual configuration**
- Version Python : celle utilisée par votre virtualenv
- Virtualenv : `/home/VOTRE_NOM/.virtualenvs/lobicop`

## 4. Fichier WSGI
Dans le fichier WSGI de PythonAnywhere, utiliser :

```python
import sys
project = '/home/VOTRE_NOM/lobicop'
if project not in sys.path:
    sys.path.insert(0, project)

from wsgi import application
```

## 5. Dossier de données
Par défaut les données sont dans :

`/home/VOTRE_NOM/lobicop/data`

Pour séparer le code des données, définir dans l'environnement Web :

`LOBICOP_DATA_DIR=/home/VOTRE_NOM/lobicop_data`

Puis copier les fichiers de `data/` dans ce dossier avant le premier démarrage.

## 6. Important pour la messagerie temps réel
LOBICOP utilise **Server-Sent Events (SSE)**. La version Flask fournit les flux SSE avec des générateurs WSGI. Sur PythonAnywhere, le comportement du flux dépend du type de compte et de la configuration du proxy ; si un proxy met les réponses en tampon, le navigateur peut recevoir les événements par lots plutôt qu'instantanément.

La messagerie reste fonctionnelle même si le flux temps réel est temporairement indisponible : l'historique est stocké dans `data/messages.db` et peut être relu par l'API.

## 7. Recharger
Après modification du code :

**Web → Reload**

## 8. Vérification
Tester :

```bash
curl https://VOTRE_DOMAINE/api/health
```

La réponse attendue contient `"ok": true` et la version LOBICOP.
