# Connecter le dossier de données LobiCop

Le projet LobiCop et son dossier de données sont maintenant séparables.

## Pour utiliser un même dossier avec toutes les futures versions

Définir la variable d'environnement `LOBICOP_DATA_DIR` vers le dossier de données.

Exemple Windows PowerShell :

```powershell
$env:LOBICOP_DATA_DIR="C:\LobiCop\DONNEES"
python server/main.py
```

Exemple Linux :

```bash
export LOBICOP_DATA_DIR=/opt/lobicop-data
python3 server/main.py
```

Le serveur y conserve les comptes, sessions, boutiques, bases métier, médias et futurs profils.

Si `LOBICOP_DATA_DIR` n'est pas défini, la version locale utilise `./data` pour rester immédiatement lançable.

## Pourquoi

Le ZIP du projet contient le **code**. Le dossier de données contient la **vie du projet**.
Ainsi, passer de 0.2.14 à 0.2.15 ne doit pas effacer les utilisateurs, créateurs, boutiques, commandes ou médias.
