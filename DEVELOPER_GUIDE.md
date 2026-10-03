# GUIDE DU DÉVELOPPEUR — LOBICOP (version temps réel / 5 secteurs)

Ce document vous permet de **naviguer, diagnostiquer et modifier le projet
vous-même**, sans repasser par une IA pour chaque petit détail. Il est
écrit pour quelqu'un qui connaît les bases de la programmation.

Trois choses à retenir avant tout :

1. **Rien n'est irréversible.** L'outil `tools/nzela_cli.py` sauvegarde
   automatiquement chaque fichier avant de le modifier. On peut toujours
   revenir en arrière avec `restaurer`.
2. **Le serveur écrit tout ce qu'il fait dans un journal.** En cas de
   souci, on regarde `server/server.log` (ou la commande `logs`) avant de
   deviner.
3. **`python3 tools/nzela_cli.py verifier`** doit toujours répondre
   "🟢 Tout est en ordre" avant de considérer une modification terminée.

---

## 1. Démarrer et diagnostiquer

```bash
cd LOBICOP_CLASSIC_REALTIME_ADMIN_CORRIGE

python3 server/main.py                              # lancement normal
NZELA_LOG_LEVEL=DEBUG python3 server/main.py         # avec tous les détails
```

Au démarrage, le serveur affiche (et écrit dans `server/server.log`) un
résumé : adresse, boutiques chargées, secteurs disponibles. Ensuite,
**chaque requête est enregistrée** avec son code de réponse (`200`=ok,
`404`=introuvable, `403`=interdit, `500`=erreur interne).

```bash
python3 tools/nzela_cli.py logs 50      # les 50 dernières lignes
```

Toute erreur inattendue est capturée et écrite en entier dans le journal —
le serveur ne plante plus en silence. Une connexion coupée par le client
(onglet fermé pendant un flux temps réel) est reconnue comme normale et
n'écrit qu'une ligne discrète, pas un traceback complet.

---

## 2. L'outil `tools/nzela_cli.py`

```bash
python3 tools/nzela_cli.py          # menu numéroté, le plus simple
```

Ou en une commande directe :

```bash
python3 tools/nzela_cli.py arbre                       # structure du projet
python3 tools/nzela_cli.py voir web/app.css 1 20        # lire un fichier
python3 tools/nzela_cli.py chercher "z-index"           # chercher partout
python3 tools/nzela_cli.py modifier-ligne web/app.css 7 "  --bg:#f0f0f0;"
python3 tools/nzela_cli.py remplacer web/app.css "ancien" "nouveau"
python3 tools/nzela_cli.py diff web/app.css              # voir le changement
python3 tools/nzela_cli.py restaurer web/app.css         # annuler
python3 tools/nzela_cli.py verifier                      # santé du projet
```

Liste complète : `python3 tools/nzela_cli.py aide`

---

## 3. Carte du projet

```
├── server/main.py          ← LE SERVEUR : routes /api/..., permissions,
│                              logs, ET le flux temps réel (SSE, voir §5)
├── server/server.log       ← le journal (créé au premier lancement)
│
├── engine/                 ← LES RÈGLES MÉTIER, indépendantes du web.
│   ├── nzela_core_engine/engine.py   base commune à tous les secteurs
│   ├── pharmacy_adapter.py            secteur pharmacie/parapharmacie
│   ├── restaurant_adapter.py          secteur restaurant
│   ├── commerce_adapter.py            boutiques/commerce/vente en ligne
│   ├── service_adapter.py             prestataires/taxi/service
│   ├── establishment_adapter.py       hôtel/école/clinique/agence
│   └── accounts.py                    comptes, connexion, mots de passe
│   (le détail des 3 nouveaux adaptateurs est dans ADAPTERS_CLASSIC.md)
│
├── data/
│   ├── stores.json         ← LISTE des boutiques (secteur, nom, ville...)
│   ├── accounts.json       ← comptes créés (généré automatiquement)
│   └── *.db                ← une base SQLite PAR boutique, recréée si
│                              supprimée (pas de risque à les effacer)
│
├── web/                    ← LA PAGE GLOBALE (accueil, recherche)
│   ├── index.html / app.js
│   └── app.css                🎨 couleurs/tailles — bloc ":root{" en haut,
│                                 commenté ligne par ligne
│
├── web/admin.html           ← l'espace entreprise (gestion d'une boutique)
│
├── web/boutique/             ← L'INTÉRIEUR D'UNE BOUTIQUE
│   ├── index.html
│   └── assets/
│       ├── app.js / app.css    🎨 fichier minifié — voir le commentaire
│       │                        en tête de fichier avant de le modifier
│       ├── admin.js / admin.css
│
├── tools/nzela_cli.py       ← l'outil décrit à la section 2
│
└── tests/                   ← lancés par "python3 tools/nzela_cli.py verifier"
    test_global.py, test_restaurant_and_accounts.py, test_adapters.py
```

---

## 4. Recettes courantes

### 🎨 Changer une couleur
`web/app.css` est lisible ligne par ligne (variables commentées en haut).
`web/boutique/assets/app.css` est minifié : utilisez plutôt
`python3 tools/nzela_cli.py remplacer web/boutique/assets/app.css "--gold:#f5b942" "--gold:#votre_couleur"`
(l'outil refuse si le texte n'est pas unique, par sécurité).

### 🐛 Un bouton ne fait rien
1. `F12` dans le navigateur → onglet Console → chercher un message rouge.
2. `python3 tools/nzela_cli.py chercher "nomDeLaFonction"` pour la localiser.
3. `python3 tools/nzela_cli.py logs` pendant qu'on clique, pour voir si le
   serveur reçoit la requête et avec quel code.

### ↩️ Annuler une modification ratée
```bash
python3 tools/nzela_cli.py historique <fichier>
python3 tools/nzela_cli.py restaurer <fichier>
python3 tools/nzela_cli.py verifier
```

### ➕ Ajouter un nouveau secteur d'activité
Regardez `ADAPTERS_CLASSIC.md` et un adaptateur existant proche (par
exemple `service_adapter.py` pour un nouveau métier de prestation) comme
modèle, puis déclarez le secteur dans `SECTOR_CATEGORIES` de
`server/main.py`. Toujours relancer `verifier` après.

---

## 5. Particularité de cette version : le temps réel (SSE)

Cette version notifie les pages ouvertes en direct (nouvelle demande,
changement de statut) via un flux `/api/events/stream` et
`/api/admin/stream`, sans que la page ait besoin de se rafraîchir. C'est
géré par la fonction `sse()` dans `server/main.py`. Un onglet fermé pendant
qu'un flux est ouvert est un événement normal (pas un bug) — le serveur le
gère proprement et l'écrit en une ligne dans le journal plutôt qu'un
traceback.

---

### Commandes en temps réel — correctifs 0.2.6 (à connaître si ça se reproduit)

- **L'admin ne voyait aucune commande** : la page `admin.js` utilisait deux
  variables jamais déclarées (`catalog`, `allRequests`). Dès qu'une commande
  existait à l'ouverture de la page, elle plantait avec
  `catalog is not defined` (visible dans F12 → Console) et restait vide.
- **Notifications** : à chaque nouvelle commande, bannière en haut à droite,
  son, compteur dans le titre de l'onglet, et notification système si
  l'utilisateur clique sur « 🔕 Activer les alertes » (une fois).
- **Session propriétaire** : si un autre compte se connecte dans le même
  navigateur, l'admin retrouve automatiquement la session du propriétaire,
  sinon affiche un bandeau rouge clair (au lieu d'une liste vide muette).
- **Flux serveur** (`sse()` / `wait_events()` dans `server/main.py`) : plus
  de rejeu de 500 anciens événements à chaque reconnexion, plus de réveil
  perdu (jusqu'à 15 s de retard), flux public réservé aux commandes suivies.
- Test automatique : `tests/test_realtime_orders.py` (lancé par `verifier`).

## 6. Ce qui a été mis en place pour cette autonomie

- Journalisation complète (`server/server.log`), erreurs inattendues
  capturées au lieu de plantages silencieux, déconnexions réseau (fermeture
  d'onglet pendant un flux temps réel) traitées comme normales.
- `tools/nzela_cli.py` : navigation, lecture, recherche, modification
  ligne-par-ligne, remplacement de texte, sauvegarde/restauration
  automatique, vérification de santé, lancement du serveur.
- Variables de couleur documentées dans `web/app.css` (ligne par ligne) et
  `web/boutique/assets/app.css` (bloc d'explication, fichier minifié).
- Ce guide, adapté à cette version précise (5 secteurs + temps réel).

Ce qui reste plus adapté à une discussion avec une IA : nouvelles règles
métier profondes, nouvelle architecture, ou modifications visuelles fines
touchant plusieurs fichiers à la fois. Pour le reste — couleurs, tailles,
petits textes, diagnostics — vous avez maintenant les moyens de faire vous-
même, en toute sécurité.
