# LobiCop 0.2.23 — Base réelle par dossiers

Cette version ajoute une base de données réelle supplémentaire sous `base_reelle/`. Elle permet de construire LobiCop à partir de dossiers réels : un dossier par utilisateur, un dossier par boutique, puis un dossier par produit.

Le serveur importe ces dossiers au démarrage sans supprimer les données existantes. Les boutiques créées depuis l'interface créent également leur dossier métier.

Voir `base_reelle/README.md` et `modeles_base_reelle/`.


## Version 0.2.22 — base 0.2.21 + les 7 cartes
- La page d'accueil est celle de la base 0.2.21, inchangée.
- Les 7 cartes sont intégrées partout ailleurs, avec la palette du projet (or, surfaces, texte) : aucun bleu, aucun point de statut, plus de badge « Populaire ».
- 1 Carte produit · 2 Produit ouvert · 3 Commander · 4 Suivi de commande · 5 Carte boutique (avec « Contacter la boutique ») · 6 Produit dans la boutique (onglets de catégories) · 7 Commande confirmée.
- Les résultats de recherche affichent la carte boutique.
- Badge « Nouveau » : seulement sur les produits récents (`UI.newDays` dans `web/boutique/assets/app.js`).
- Favoris (cœur) mémorisés sur l'appareil.

## Version 0.2.20 — accueil simplifié, boutique et messagerie
- Accueil simplifié, inspiré uniquement du principe de sobriété du prototype de référence fourni.
- Suppression de la section « Suggestions » dans l’espace client boutique : le catalogue reste accessible directement via « Choisir vos produits ».
- Logos des boutiques affichés dans les résultats de recherche.
- Le logo de la boutique ouvre sa fiche d’informations, avec « Contacter la boutique ».
- Les annonces supportent désormais le broadcast et une cible individuelle.
- Une réponse d’un propriétaire de boutique à une conversation client crée automatiquement une annonce ciblée, visible dans la zone habituelle des annonces du client et actualisée en temps réel.
### 0.2.19 — Passage à Flask / WSGI
- Serveur HTTP migré vers Flask.
- Point d’entrée WSGI `wsgi.py` pour PythonAnywhere.
- APIs existantes conservées pour limiter les régressions.
- Flux SSE adaptés à Flask/WSGI pour les commandes et la messagerie temps réel.
- Dépendance Flask déclarée dans `requirements.txt`.

### 0.2.18 — Messagerie et expérience mobile
- Messagerie privée entre deux comptes inscrits.
- Conversations compte ↔ boutique, avec réception et réponse depuis l’espace administrateur de la boutique.
- Temps réel via Server-Sent Events, avec stockage SQLite persistant dans `data/messages.db`.
- Contrôle d’accès : seuls les participants d’une conversation peuvent lire ou envoyer ses messages.
- Recherche d’utilisateurs par nom ou e-mail depuis la messagerie.
- Interface de messagerie responsive et adaptée aux petits écrans.
- Correction de la suppression de compte : les sessions de l’utilisateur supprimé sont maintenant correctement supprimées.


### 0.2.17 — Accueil simplifié
La page d’accueil est recentrée sur la recherche, sans catalogue ni détails affichés par défaut.
# LOBICOP — Bêta 0.2.14

Transformation de la base NZELA GLOBAL en une première expérience LOBICOP alternative.

## Principe UX
- accueil très léger, inspiré des moteurs de recherche simples
- une action principale : rechercher
- recherche de boutiques par nom, secteur, ville, quartier ou adresse
- recherche également dans les produits des catalogues
- ouverture directe de l'espace d'une boutique
- catalogue et demande conservés derrière la recherche
- interface responsive et mobile-first

## Démo
```bash
python3 server/main.py
```
Puis ouvrir `http://127.0.0.1:8787`.

## Données persistantes séparées
- Le code et les données peuvent désormais être séparés.
- `LOBICOP_DATA_DIR` permet de connecter toutes les versions futures au même dossier de données.
- Le dossier conserve comptes/utilisateurs, créateurs, boutiques, bases métier, médias et profils.
- Voir `LOBICOP_DONNEES.md` et `data/README.md`.

## Architecture
Le moteur pharmacie existant est conservé. Cette version change surtout la couche globale de découverte et l'identité visuelle :

```text
LOBICOP alternative
        ↓
     Recherche
        ↓
Boutique / acteur trouvé
        ↓
      Espace
        ↓
Catalogue / action
```

## Test
```bash
python3 tests/test_global.py
python3 tests/test_restaurant_and_accounts.py
```

## 0.2.11 — Bêta produit propre
- Version de déploiement du produit LobiCop sans l’outil interne d’édition visuelle.
- Le designer visuel est retiré du paquet de production et n’est pas nécessaire au fonctionnement du produit.
- Le cœur métier, les comptes, les espaces, les catalogues, les commandes et le temps réel restent inchangés.

## 0.2.0 — nouveau secteur, comptes et création d'espace

Conformément au livre blanc NZELA (section 9, « adaptateurs sectoriels ») et
à la stratégie de lancement (section 15, densifier l'offre par secteur puis
par zone) :

- **Nouveau secteur/adaptateur : Restaurant.**
  `engine/restaurant_adapter.py` définit les catégories (Entrées, Plats,
  Accompagnements, Boissons, Desserts, Menus, Réservations) et deux
  opérations : `menu_item` (article du menu) et `reservation_request`
  (réservation de table). Le moteur générique (`NzelaEngine`) n'a pas été
  modifié — seul un adaptateur a été ajouté, comme pour la pharmacie.
  Deux acteurs restaurant de démonstration sont pré-inscrits
  (`shop-resto-centre`, `shop-resto-bacongo`).

- **Inscription / connexion.** `engine/accounts.py` gère des comptes acteurs
  (nom, e-mail, mot de passe haché en PBKDF2-HMAC-SHA256, aucune dépendance
  externe) et des sessions par jeton, persistés dans `data/accounts.json` et
  `data/sessions.json`. Endpoints : `POST /api/auth/signup`,
  `POST /api/auth/login`, `POST /api/auth/logout`, `GET /api/auth/me`.

- **Création d'espace en libre-service.** Une fois connecté, un acteur peut
  créer son propre espace (`POST /api/spaces` : nom, secteur, ville,
  quartier, adresse, téléphone, description). L'espace est immédiatement
  persisté dans `data/stores.json`, moteur/base créés à la volée, et
  apparaît aussitôt dans la recherche (`RECHERCHER → DÉCOUVRIR → CHOISIR →
  ENTRER → AGIR`, section 4 du livre blanc). Le propriétaire peut ensuite
  ajouter des produits/articles à son catalogue via
  `POST /api/stores/<id>/products` (accès réservé au propriétaire,
  vérifié par jeton).

- **Recherche et résultats.** Les résultats affichent désormais un libellé
  de secteur lisible (`sector_label`) et incluent naturellement les
  nouveaux espaces créés en libre-service, sans traitement particulier —
  la couche GLOBAL reste générique par construction.

- **Interface.** Le header propose « Connexion » / « Inscription » (ou, une
  fois connecté, « Créer mon espace » et le menu du compte). Dans l'espace
  d'un acteur, son propriétaire voit un panneau « Ajouter au catalogue »
  avec les catégories propres à son secteur.

## Accueil 0.1.4
- nouveau marquage visuel LOBICOP avec une icône en forme de L, sans étoile
- bouton Rechercher explicite dans la zone de recherche
- accès rapides discrets sous la recherche
- accès direct à l’espace taxi via `/taxi`
- bouton Découvrir pour explorer les grands univers sans alourdir l’accueil

## 0.1.3
- Ajout du moteur de mondes partagé : **Monde de glace** / **Monde classique**.
- Bouton flottant de changement de monde, mémorisé localement.
- Le monde classique désactive les effets visuels coûteux pour les appareils plus lents.
- Le moteur partagé est disponible sur l’accueil et l’espace taxi.


## 0.1.4 — deux mondes, un même espace métier
- Le Monde de Glace et le Monde classique sont deux moteurs de présentation d'un même univers métier.
- Un espace métier n'est jamais dupliqué : mêmes données, catalogue et actions, vue différente.
- Le changement de monde reste disponible pendant la consultation d'un espace métier et dans l'espace taxi.
- Le monde choisi est mémorisé localement.
- Les effets immersifs sont isolés dans la couche visuelle ; le moteur métier reste commun.
- Les espaces peuvent être ouverts directement par ancre `#espace=<id>`.


## 0.1.7 — Deux mondes

Le Monde de Glace réutilise directement le moteur visuel de NZELA CORE 2.18.20 FLUIDITE comme moteur immersif de référence. Le Monde classique reste l'interface légère. Le bouton flottant change réellement de moteur d'interface ; les espaces métier et les API restent communs.


## 0.1.7 — Monde de Glace
The immersive world uses the visual interface and interaction parameters of the supplied reference application. It is a view layer over the same business space; the selected store is passed with `?store=<id>`. Classic and immersive worlds share the same catalog and request engine.

## 0.2.7 — thème partagé et corrections
- **Thème clair / sombre unique** (celui de l'espace administrateur) sur toute la plateforme : accueil, taxi, boutique client et espace admin. Une seule préférence mémorisée (`nzela_theme`, `nzela_theme_scale`) : le choix fait sur une page vaut pour les autres. Code partagé : `web/theme.js` + `web/theme.css`.
- Corrections de sécurité et de logique : voir `tests/test_bugfixes_0_2_7.py`.
- **Mode clair complet** : le curseur de thème va maintenant du gris-bleu (0 %) jusqu'au blanc pur (100 %) sur toutes les pages (fond, halos et en-têtes s'éclaircissent ensemble).

## 0.2.23 — Base réelle par dossiers + restaurants du catalogue
- Import réel par dossiers sous `base_reelle/boutiques/` et `base_reelle/utilisateurs/`.
- 5 restaurants et 20 articles importés depuis le catalogue PDF fourni.
- Chaque restaurant est relié à un compte propriétaire et possède ses propres fichiers éditables.
- Compte root de développement : `root@lobicop.local` / `12345678`.
- Le root peut administrer une boutique précise via son identifiant de boutique.
- Les stocks non indiqués par le PDF restent à 0 pour éviter d'inventer une disponibilité.
- Correction du chargement des logos depuis les dossiers réels.
