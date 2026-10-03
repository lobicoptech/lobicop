# LOBICOP — 3 adaptateurs Classic

Cette version stabilise trois familles d'acteurs autour du même CORE.

## 1. Boutique / commerce

Adaptateur : `engine/commerce_adapter.py`

Couvre : boutiques physiques, vendeurs en ligne, producteurs, artisans et restaurants.
Le profil restaurant conserve ses règles spécialisées via `RestaurantEngine`.

Actions de base : commande de produit, réservation, contact.

## 2. Prestataire / service

Adaptateur : `engine/service_adapter.py`

Couvre notamment : taxi, technicien, réparateur, coiffeur, couturier, photographe,
développeur, service à domicile et autres indépendants.

Le prestataire publie ses capacités/compétences sous forme d'offres et reçoit des
demandes de service, rendez-vous ou courses.

## 3. Établissement / organisation

Adaptateur : `engine/establishment_adapter.py`

Couvre : cliniques, écoles, hôtels, garages, agences, bureaux et organisations.

Actions de base : contact, rendez-vous, inscription.

## Règle commune

GLOBAL trouve et fait entrer. L'adaptateur décrit le métier. CORE exécute les règles
communes : catalogue/offres, disponibilité, demandes, états et historique.

Endpoints utiles :
- `GET /api/adapters`
- `GET /api/adapters/{id}`
- `GET /api/sectors`
- `GET /api/stores?q=...`
- `GET /api/stores/{id}/catalog`
- `POST /api/stores/{id}/requests`

Les trois familles utilisent donc le même parcours, sans imposer le même fonctionnement
au métier.
