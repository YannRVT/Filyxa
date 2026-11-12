# PRD — Filyxa

## Problème

Dans les ateliers et marques de mode, la connaissance des matières est éparpillée : classeurs d'échantillons physiques, tableurs Excel, PDF fournisseurs, mémoire des modélistes. Retrouver un tissu adapté (composition, grammage, entretien, certification) prend du temps. Ressaisir une étiquette entraîne des erreurs. L'atelier découvre une rupture de stock fournisseur trop tard, au moment de commander pour la production. Et le dossier matières envoyé au façonnier est refait à la main à chaque collection, déjà périmé à son arrivée.

Pourquoi maintenant : l'IA lit désormais de façon fiable une étiquette multilingue froissée. Et les exigences de traçabilité (affichage environnemental, passeport numérique produit européen) obligent les marques à documenter précisément leurs matières.

## Solution

Filyxa est une plateforme qui relie les ateliers et leurs fournisseurs autour d'une base de matières fiable et à jour.

- **TissuTech** : la bibliothèque de matières de l'atelier, partagée par toute l'équipe. Elle s'affiche en galerie ou en tableau technique, avec une recherche instantanée et des filtres (fibre avec un pourcentage minimum, grammage, couleur, armure, certifications, usage, disponibilité).
- **Scanner** : l'utilisateur photographie l'étiquette d'un échantillon et obtient une fiche pré-remplie à valider. Si l'échantillon correspond à une référence d'un fournisseur présent sur Filyxa, la fiche officielle et la disponibilité en direct s'y rattachent.
- **Fournisseurs** : les fournisseurs publient leur catalogue et leur disponibilité. L'atelier sait tout de suite s'il peut produire.
- **Studio** : collections, modèles et coloris, pour les vêtements, les chaussures, la maroquinerie et les accessoires. On y associe les matières par rôle, on calcule le besoin en matière et on reçoit des alertes de compatibilité.
- **Export** : un dossier matières en PDF et un lien partagé, toujours à jour, pour le façonnier.

## Utilisateur cible

**Atelier (utilisateur principal).** Claire est responsable matières et développement produit dans une marque de prêt-à-porter et d'accessoires de 5 à 15 personnes. Elle reçoit chaque saison des centaines d'échantillons. Elle travaille dans l'atelier, entre les échantillons et son poste de travail : elle monte les collections et les dossiers matières sur ordinateur, et scanne avec son téléphone devant les échantillons et sur les salons (Première Vision). Selon les marques, la production se fait sur place ou chez des façonniers au Portugal ou en Roumanie. Autour d'elle, la direction de création consulte (Lecteur) et les modélistes travaillent dans l'outil (Éditeurs).

**Fournisseur (utilisateur secondaire).** Marco est responsable commercial chez un tisseur italien. Son stock est suivi dans un ERP ou un tableur. Il veut que ses références soient visibles et à jour chez les marques qui les utilisent.

## User Stories

### Comptes et organisation

- **US-1** — En tant que super-admin, je veux créer une organisation atelier ou fournisseur et inviter son premier admin, afin d'ouvrir l'accès à un client pilote.
- **US-2** — En tant que super-admin, je veux attribuer une offre à une organisation et voir son usage (scans, membres, coût de l'IA), afin de maîtriser les coûts.
- **US-3** — En tant qu'admin, je veux inviter un collègue par e-mail avec un rôle (Admin, Éditeur, Lecteur), afin qu'il rejoigne notre espace.
- **US-4** — En tant qu'invité, je veux saisir le code à 6 chiffres reçu par e-mail puis choisir mon mot de passe, afin de rejoindre l'organisation sans lien à ouvrir.
- **US-5** — En tant qu'invité dont le code a expiré, je veux un message clair m'indiquant de demander une nouvelle invitation, afin de ne pas rester bloqué.
- **US-6** — En tant qu'utilisateur, je veux réinitialiser mon mot de passe avec un code à 6 chiffres reçu par e-mail, afin de récupérer mon accès.
- **US-7** — En tant qu'admin, je veux changer le rôle d'un membre ou le retirer, afin de garder le contrôle des accès.
- **US-8** — En tant que Lecteur, je veux consulter et exporter sans pouvoir rien modifier, afin de travailler sans risque d'abîmer la base.
- **US-9** — En tant qu'utilisateur, je veux choisir ma langue (français, anglais, italien, espagnol, portugais, roumain), afin de travailler dans ma langue.

### TissuTech

- **US-10** — En tant que membre d'atelier, je veux voir nos matières en galerie ou en tableau technique, afin de comparer visuellement ou par les chiffres.
- **US-11** — En tant que membre d'atelier, je veux une recherche instantanée par nom, code article, fournisseur ou couleur, afin de retrouver une matière en quelques secondes.
- **US-12** — En tant que membre d'atelier, je veux filtrer par fibre (avec un pourcentage minimum), grammage, couleur, armure, certification, usage et disponibilité, afin de trouver la matière adaptée à un modèle.
- **US-13** — En tant que nouvel atelier, quand TissuTech est vide, je veux qu'on me propose de scanner un échantillon ou d'importer un fichier Excel, afin de démarrer vite.
- **US-14** — En tant qu'Éditeur, je veux créer une matière à la main, afin d'enregistrer un échantillon sans étiquette.
- **US-15** — En tant qu'Éditeur, je veux saisir le métrage de notre stock atelier pour une matière, afin de savoir ce que nous avons sur place.
- **US-16** — En tant que membre d'atelier, sur une matière liée à un fournisseur, je veux voir ses données techniques et sa disponibilité à jour, afin de me fier à la source officielle.
- **US-17** — En tant qu'Éditeur, je veux ajouter mes informations privées (prix négocié, notes, étiquettes, photos) à une matière liée, afin de compléter la fiche sans toucher aux données du fournisseur.
- **US-18** — En tant qu'Éditeur, je veux signaler une erreur sur une fiche fournisseur, afin qu'il la corrige pour tous.
- **US-19** — En tant que membre d'atelier, quand un fournisseur retire une référence, je veux garder la fiche telle qu'elle était, avec la mention « Référence retirée par le fournisseur », afin que mes modèles et dossiers restent complets.
- **US-20** — En tant qu'Éditeur, je veux lier après coup une fiche créée à la main à une référence fournisseur, afin de profiter des données à jour.
- **US-21** — En tant qu'Éditeur, je veux importer un fichier Excel ou CSV en associant ses colonnes aux champs, avec un aperçu et la liste des lignes en erreur, afin de reprendre notre base existante.
- **US-22** — En tant qu'Éditeur, après un import, je veux que les matières soient automatiquement reliées aux catalogues des fournisseurs présents sur Filyxa, afin d'éviter de les lier une par une.

### Scanner

- **US-23** — En tant que membre d'atelier, je veux photographier l'étiquette d'un échantillon sur mobile ou importer une photo depuis un ordinateur, afin de créer une fiche sans tout saisir.
- **US-24** — En tant qu'Éditeur, je veux une fiche pré-remplie (composition, grammage, laize, armure, coloris, entretien, certifications, fournisseur, code article) que je valide ou corrige avant enregistrement, afin que rien ne soit enregistré sans mon accord.
- **US-25** — En tant qu'Éditeur, je veux que les champs lus avec peu de certitude soient signalés, afin de savoir quoi vérifier.
- **US-26** — En tant qu'Éditeur, quand l'échantillon correspond à une référence fournisseur, je veux qu'on me demande « C'est bien cette référence ? » avec la fiche du fournisseur, puis confirmer ou choisir parmi des références proches, afin d'éviter un mauvais rapprochement.
- **US-27** — En tant qu'Éditeur, quand aucune référence ne correspond, je veux enregistrer une fiche à moi, afin de ne pas perdre l'échantillon.
- **US-28** — En tant qu'Éditeur, quand la matière existe déjà dans TissuTech, je veux être averti et pouvoir ouvrir la fiche existante, afin d'éviter les doublons.
- **US-29** — En tant que membre d'atelier, quand l'étiquette est illisible ou que l'analyse échoue, je veux un message clair et la possibilité de réessayer ou de saisir à la main, afin de ne jamais rester bloqué.
- **US-30** — En tant qu'admin, je veux être prévenu à 80 % puis à 100 % du quota mensuel de scans, et que la saisie manuelle reste toujours possible, afin d'anticiper sans bloquer l'équipe.

### Fournisseur

- **US-31** — En tant que fournisseur, je veux importer mon catalogue (références, données techniques, stock) depuis un fichier Excel ou CSV en associant mes colonnes, afin d'être présent sur Filyxa sans développement.
- **US-32** — En tant que fournisseur, je veux réimporter mon fichier pour mettre à jour mon stock et mes fiches, afin que les ateliers voient des informations exactes.
- **US-33** — En tant que fournisseur, je veux choisir comment ma disponibilité s'affiche (quantité exacte, paliers avec mes propres seuils, ou masquée), globalement ou référence par référence, avec un délai de réassort pour ce qui est sur commande, afin de ne pas exposer des informations sensibles.
- **US-34** — En tant que fournisseur, je veux recevoir les signalements d'erreur des ateliers et y répondre, afin de garder des fiches justes.
- **US-35** — En tant que fournisseur, je veux retirer une référence de mon catalogue, afin de ne plus la proposer.

### Studio

- **US-36** — En tant qu'Éditeur, je veux créer une collection (par exemple « AH27 »), afin de regrouper les modèles d'une saison.
- **US-37** — En tant qu'Éditeur, je veux créer un modèle dans une collection en choisissant son type (vêtement, chaussure, maroquinerie, accessoire), afin d'avoir les bons rôles de matières.
- **US-38** — En tant qu'Éditeur, je veux associer des matières à un modèle par rôle (principal, doublure, entoilage…), à partir d'une liste qui dépend du type et que je peux compléter, afin de construire la nomenclature matière.
- **US-39** — En tant qu'Éditeur, je veux décliner un modèle en coloris, chacun avec ses propres matières, afin d'éviter de dupliquer le modèle.
- **US-40** — En tant qu'Éditeur, je veux saisir la consommation par pièce, la quantité prévue par coloris et une marge de perte (8 % par défaut), afin d'obtenir le besoin total en matière.
- **US-41** — En tant que membre d'atelier, je veux des alertes sur l'entretien, la technique, les certifications et le stock, chacune avec son explication, afin de corriger un problème avant la production.
- **US-42** — En tant que membre d'atelier, quand une matière d'un modèle en cours passe en stock faible ou en rupture, ou que sa fiche est modifiée ou retirée par le fournisseur, je veux une notification dans l'app, afin de réagir à temps.
- **US-43** — En tant que membre d'atelier, quand une collection ou un modèle est vide, je veux être guidé vers l'étape suivante, afin de savoir quoi faire.

### Export et partage

- **US-44** — En tant que membre d'atelier, je veux exporter la fiche d'une matière en PDF A4 avec les pictogrammes d'entretien, afin de l'imprimer ou de l'envoyer.
- **US-45** — En tant que membre d'atelier, je veux exporter le dossier matières d'un modèle ou d'une collection en PDF, dans la langue de mon choix et avec un QR code vers le lien partagé, afin de l'envoyer au façonnier.
- **US-46** — En tant qu'Éditeur, je veux créer un lien partagé en lecture seule, avec une date d'expiration, et pouvoir le révoquer, afin de contrôler qui voit nos informations.
- **US-47** — En tant que façonnier, je veux ouvrir le lien sur mon téléphone sans créer de compte et voir des fiches à jour, sans prix, sans notes et sans stock de l'atelier, afin de produire avec les bonnes informations.
- **US-48** — En tant que façonnier, quand le lien a expiré ou a été révoqué, je veux une page qui me l'explique, afin de savoir qu'il faut en demander un nouveau.

### Navigation

- **US-49** — En tant qu'utilisateur sur téléphone, je veux un bouton Scanner au centre de la barre de navigation, afin de scanner d'une seule main en un seul geste.

## Critères de succès

1. La fiche pré-remplie s'affiche en moins de 7 s après la photo, en 4G, pour 9 scans sur 10.
2. Sur un jeu de 50 vraies étiquettes, au moins 90 % des champs sont lus correctement (composition, grammage, laize, entretien, code article).
3. Au moins 80 % des échantillons d'un fournisseur pilote sont reliés automatiquement à la bonne référence, avant confirmation.
4. Un fichier Excel de 500 références est importé en moins de 2 min.
5. Une recherche ou un filtre affiche son résultat en moins de 1 s sur une base de 5 000 matières.
6. Le dossier matières PDF d'une collection de 20 modèles est généré en moins de 10 s.
7. Un lien partagé s'ouvre sur un téléphone sans compte.
8. La notification de rupture apparaît dans l'app moins de 2 h après le passage en rupture chez le fournisseur.
9. Après 1 mois, 2 ateliers et 1 fournisseur pilotes sont actifs, et chaque atelier a au moins 200 matières et 1 collection complète.

## Hors périmètre

### Prévu après la version pilote

1. Envoi du stock par API et synchronisation automatique depuis un lien (en V1, seul l'import manuel de fichier existe)
2. Statistiques fournisseur et partage nominatif de l'activité d'un atelier
3. Étiquettes QR Filyxa imprimées par les fournisseurs
4. Cuirs et composants (en V1, textiles uniquement)
5. Scan hors ligne et consultation sans réseau
6. Notifications par e-mail (en V1, uniquement dans l'app)
7. Paiement en ligne et abonnements (les offres sont attribuées à la main)
8. Connexion avec un compte Google ou Microsoft
9. Appartenance d'une personne à plusieurs organisations
10. Application Windows ou macOS installable

### Exclu jusqu'à nouvelle décision

11. Commandes, devis et demandes d'échantillons auprès des fournisseurs
12. Connecteurs prêts à l'emploi pour les logiciels de gestion des fournisseurs
13. Avis ou alertes rédigés par l'IA dans le Studio
14. Comptes invités pour les façonniers
15. Consommation par taille, placement et gradation
16. Déduction automatique du stock lors de la production sur place
17. Import de fiches fournisseurs en PDF
18. Modification par l'atelier des données techniques d'une référence fournisseur
19. Notifications push
20. Inscription en libre-service

## Décisions d'implémentation

- **Plateformes** : iOS, Android et navigateur web. Scan par l'appareil photo sur mobile, import d'une photo sur ordinateur.
- **Navigation** : sur ordinateur et tablette, une barre latérale vert pétrole avec le logo. Sur téléphone, des onglets en bas : TissuTech · Studio · Scanner · Fournisseurs · Compte, avec le bouton Scanner au centre et mis en avant.
- **Identité** : charte Filyxa (vert pétrole, émeraude, menthe, police Montserrat). Bon contraste du texte sur tous les fonds.
- **Langues** : français, anglais, italien, espagnol, portugais, roumain. Une fiche saisie dans une langue s'affiche correctement dans les autres. Les PDF et les liens partagés sont générés dans la langue choisie à l'export.
- **Rôles** : l'Admin gère les membres, l'offre et les paramètres. L'Éditeur crée, modifie, scanne, importe et partage. Le Lecteur consulte et exporte en PDF.
- **Accès** : pas d'inscription en libre-service. Invitation par e-mail avec un code à 6 chiffres valable 48 h. Mot de passe de 8 caractères minimum. Une personne appartient à une seule organisation en V1.
- **Matières** : textiles uniquement en V1. Stock atelier saisi à la main, en mètres.
- **Fiche liée à un fournisseur** : données techniques et disponibilité en lecture seule, toujours à jour, avec la mention « Données fournisseur ». La couche privée de l'atelier (prix, notes, étiquettes, photos, stock atelier) est modifiable et visible par l'atelier seulement.
- **Disponibilité** : paliers Disponible / Stock faible / Sur commande (délai en semaines) / Rupture, ou quantité exacte, selon le choix du fournisseur. Les paliers sont affichés par défaut. Chaque statut a une couleur constante dans toute l'app.
- **Scan** : rien n'est enregistré sans validation. Les champs incertains sont surlignés. Une correspondance avec un fournisseur demande toujours une confirmation. Un doublon est signalé avant l'enregistrement.
- **Quota de scans** : un quota mensuel par offre, avec un avertissement à 80 % et à 100 % pour les admins. La saisie manuelle reste illimitée.
- **Import** : association des colonnes, aperçu avant validation, liste des lignes en erreur avec leur motif. Jusqu'à 5 000 lignes par fichier.
- **Besoin en matière** : consommation par pièce × quantité par coloris × (1 + marge de perte). Marge de 8 % par défaut, modifiable par modèle. Unité : mètres.
- **Alertes du Studio** : quatre familles (entretien, technique, certifications, stock). Elles sont recalculées instantanément à chaque modification, et chaque alerte cite les valeurs qui la déclenchent. Le même cas donne toujours la même alerte.
- **Lien partagé** : lecture seule, valable 30 jours par défaut, modifiable, révocable à tout moment. Il n'affiche jamais les prix, les notes ni le stock de l'atelier.
- **Notifications** : une cloche avec un compteur dans l'app.

## Notes complémentaires

- **Prérequis avant la publication sur les stores** : un mot-logo Filyxa vectorisé fidèlement (le texte actuel dépend de la police installée et n'est pas rendu en Montserrat), un symbole fidèle à la planche (sans le cran parasite) et l'icône d'app validée.
- **À vérifier** : disponibilité de la marque Filyxa (INPI, EUIPO) et du domaine.
- **Dépendance** : 1 à 2 fournisseurs pilotes prêts à exporter leur catalogue.
- **Risque** : tenir les 7 s du scan. Leviers : mode rapide de l'IA (plus cher) ou modèle plus léger, s'il respecte le critère de lecture.
- **Risque** : coût de l'IA par atelier. Il est suivi par organisation et encadré par le quota.
- **Hypothèse** : les fournisseurs acceptent de rendre leur stock visible, au moins par paliers.
- **Hébergement** : les données sont hébergées dans l'Union européenne (RGPD).
- **Repris de l'ancienne application TissuTech** : pictogrammes d'entretien, règles de compatibilité, mise en page PDF, consignes de lecture d'étiquette et banc d'essai de lecture.
- **Évolutions prévues** : les dix éléments « prévus après la version pilote » du hors périmètre.

---

# V2 — Studio avancé

## Problème

Après la V1, l'atelier a une base de matières fiable. Mais le Studio s'arrête au besoin en mètres. Il ne sait pas où en est chaque modèle et ne connaît pas les échéances. Il ignore aussi combien de mètres sont déjà promis à une production en cours, et combien coûte réellement une pièce. Pour tout ça, l'atelier repart sur Excel : un tableau de suivi de collection, un fichier de gradation, une feuille de coût de revient. Ces fichiers ne sont jamais synchronisés avec les matières, ni avec leurs prix ou leur stock.

Les tailles ne sont pas prises en compte : un XXL consomme plus qu'un XS, et le besoin moyen fausse les commandes. Le prototypage consomme aussi beaucoup de matière : tests de colle, tests matière, sublimation avec marge sur les côtés. Ces mètres-là n'apparaissent nulle part.

Pourquoi maintenant : la V1 a posé les matières, les modèles et les coloris. Sans le suivi jusqu'à la production et sans le coût, l'atelier n'a pas de raison d'ouvrir Filyxa chaque jour. La V2 doit le fidéliser avant que les fournisseurs (V3) et le paiement en libre-service (V4) n'arrivent.

## Solution

Le Studio suit chaque modèle de l'idée à la livraison :

- **Statut et échéances.** Le modèle passe par Idée, Prototype, Validé, En production, Livré ou Abandonné. Chaque étape a une échéance, la collection se lit comme un planning, et un retard est signalé.
- **Tailles.** Les quantités se saisissent par taille et par coloris. La consommation de la taille de base est déclinée sur les autres tailles par un écart en %, modifiable.
- **Prototypage.** Le besoin de prototypage est calculé à part, avec une perte propre à chaque matière.
- **Stock.** Au lancement en production, le besoin est réservé sur le stock atelier, puis déduit à la livraison, avec une confirmation à chaque fois.
- **Coût de revient.** Il réunit matières, fournitures, façon et frais annexes. Il est calculé par pièce, par coloris et par collection, et comparé au prix de vente visé par un coefficient.

Ces nouveautés sont réservées à l'offre Pro. Les autres offres les voient verrouillées. La V2 corrige aussi des irritants de la V1 :

- le rôle d'une ligne de matière se modifie sur place ;
- les coloris ont un sélecteur de couleur ;
- les notifications arrivent en temps réel ;
- l'import atelier mémorise l'association des colonnes.

## Utilisateur cible

Camille, responsable de collection dans un atelier de 5 à 15 personnes qui produit 2 à 4 collections par an, en petites séries de 50 à 500 pièces par modèle. Elle fait aujourd'hui son suivi de collection et ses coûts de revient sur Excel. Elle passe sa matinée entre la table de coupe et l'ordinateur. Elle doit savoir à tout moment :

- quels modèles sont en retard ;
- s'il reste assez de matière pour lancer la prochaine production ;
- si un modèle tient son coefficient avant de le valider.

Elle utilise Filyxa sur ordinateur au bureau et sur tablette à l'atelier.

## User Stories

### Suivi de production

- **US-50** — En tant qu'Éditeur, je veux faire passer un modèle par les statuts Idée, Prototype, Validé, En production, Livré ou Abandonné, afin de savoir où en est chaque modèle de la collection.
- **US-51** — En tant qu'Éditeur, je veux fixer une échéance pour chaque étape d'un modèle, afin de planifier la collection.
- **US-52** — En tant que membre de l'atelier, je veux voir la collection sous forme de planning, trié par échéance et regroupé par statut, afin de repérer d'un coup d'œil ce qui est en retard.
- **US-53** — En tant que membre de l'atelier, je veux recevoir une notification le jour où une échéance est dépassée, afin de réagir avant que le retard ne s'accumule.
- **US-54** — En tant qu'Éditeur, je veux qu'au passage « En production » Filyxa me montre le besoin à réserver sur le stock atelier et me demande de confirmer, afin que les mètres promis à cette production ne soient pas utilisés ailleurs.
- **US-55** — En tant qu'Éditeur, je veux être averti, avant de confirmer, quand le stock disponible ne couvre pas le besoin, afin de commander le complément ou de lancer quand même en connaissance de cause.
- **US-56** — En tant que membre de l'atelier, je veux voir pour chaque matière le stock atelier, le stock réservé et le stock disponible, avec les modèles qui le réservent, afin de savoir ce qui est vraiment libre.
- **US-57** — En tant qu'Éditeur, je veux qu'au passage « Livré » Filyxa propose de déduire du stock atelier les mètres réservés, en ajustant si la consommation réelle a différé, afin que le stock reste juste.
- **US-58** — En tant qu'Éditeur, je veux qu'un modèle abandonné ou ramené en arrière libère sa réservation, afin de ne pas bloquer du stock pour rien.
- **US-59** — En tant que membre de l'atelier, je veux que seuls les modèles en Prototype, Validé ou En production déclenchent les alertes de stock et de fiche fournisseur, afin de ne pas être dérangé par des idées ou des modèles livrés.

### Tailles et gradation

- **US-60** — En tant qu'Éditeur, je veux choisir une grille de tailles pour un modèle (XS–XXL, 34–48, pointures 35–46, ou une grille créée par l'atelier), afin de saisir les quantités dans les tailles que je produis.
- **US-61** — En tant qu'Admin, je veux créer et modifier les grilles de tailles de l'atelier, afin de coller à mes propres tailles.
- **US-62** — En tant qu'Éditeur, je veux saisir les quantités par taille et par coloris dans un tableau, avec les totaux par ligne et par colonne, afin de préparer la production.
- **US-63** — En tant qu'Éditeur, je veux désigner la taille de base et un écart de consommation en % par taille (même écart par défaut d'une taille à l'autre, modifiable taille par taille), afin que le besoin tienne compte de la taille sans saisir chaque consommation.
- **US-64** — En tant que membre de l'atelier, je veux voir le besoin de chaque matière détaillé par taille et par coloris, afin de commander la bonne quantité.
- **US-65** — En tant qu'Éditeur, je veux qu'un modèle sans grille de tailles continue de fonctionner comme en V1, avec une quantité par coloris, afin de ne pas être obligé de grader un accessoire en taille unique.

### Prototypage

- **US-66** — En tant qu'Éditeur, je veux indiquer le nombre de prototypes d'un modèle et un % de perte de prototypage par matière (25 % par défaut), afin de compter les mètres consommés par les tests de colle, les tests matière ou la sublimation.
- **US-67** — En tant que membre de l'atelier, je veux voir le besoin de prototypage à côté du besoin de production, puis leur total, afin de distinguer les mètres de test des mètres de série.

### Coût de revient

- **US-68** — En tant qu'Éditeur, je veux que le coût matières d'un modèle soit calculé à partir des prix de mes matières, de la consommation et des pertes, afin de ne rien ressaisir.
- **US-69** — En tant qu'Éditeur, je veux ajouter des lignes de fournitures (libellé, prix unitaire, quantité par pièce), un coût de façon par pièce et des frais annexes, afin d'obtenir un coût de revient complet.
- **US-70** — En tant qu'Éditeur, je veux saisir un prix de vente visé et voir le coefficient obtenu, afin de décider si le modèle est rentable.
- **US-71** — En tant qu'Admin, je veux fixer un coefficient minimal pour l'atelier, afin qu'une alerte signale tout modèle qui passe en dessous.
- **US-72** — En tant qu'Éditeur, je veux voir le coût de revient par pièce, par coloris et pour toute la collection, prototypage inclus à part, afin de connaître le budget total.
- **US-73** — En tant qu'Éditeur, je veux être averti quand une matière du modèle n'a pas de prix, afin de savoir que le coût affiché est incomplet.
- **US-74** — En tant que Lecteur, je ne veux pas voir les coûts ni les prix, afin que ces données restent réservées à ceux qui décident.

### Offre Pro

- **US-75** — En tant qu'atelier en offre Essentiel, je veux voir les nouveautés du Studio avec la mention « Disponible avec l'offre Pro », afin de savoir ce que l'offre Pro m'apporterait.
- **US-76** — En tant que super-admin, je veux faire passer un atelier en Pro depuis la console, afin d'ouvrir les nouveautés immédiatement après un accord commercial.
- **US-77** — En tant qu'atelier qui repasse en Essentiel, je veux garder la lecture de mes données (statuts, tailles, coûts) sans pouvoir les modifier, afin de ne rien perdre.

### Améliorations

- **US-78** — En tant qu'Éditeur, je veux changer le rôle d'une ligne de matière directement dans le modèle, afin de corriger sans supprimer la ligne.
- **US-79** — En tant qu'Éditeur, je veux choisir la couleur d'un coloris avec un sélecteur, afin de reconnaître les coloris d'un coup d'œil.
- **US-80** — En tant que membre de l'atelier, je veux que la cloche se mette à jour dès qu'une notification arrive, afin de ne pas attendre plusieurs minutes.
- **US-81** — En tant qu'Éditeur, je veux qu'un nouvel import atelier reprenne l'association des colonnes du précédent, afin de ne pas la refaire à chaque fois.

## Critères de succès

1. Le coût de revient et le besoin d'un modèle de 10 matières, 6 tailles et 3 coloris se recalculent en moins de 1 s après chaque modification.
2. Le besoin par taille et le coût de revient correspondent au centimètre et au centime près à un calcul de référence fait à la main sur 5 modèles.
3. Au passage « En production », le stock disponible de chaque matière baisse du besoin réservé. À la livraison, le stock atelier est déduit.
4. Une échéance dépassée déclenche une notification le jour même.
5. Une notification apparaît dans la cloche moins de 5 s après l'événement.
6. Un deuxième import atelier propose d'office l'association des colonnes du précédent.
7. Un atelier hors offre Pro voit les nouveautés verrouillées, et le serveur refuse toute utilisation.
8. Après 2 mois, au moins 1 atelier Pro suit une collection complète, de l'idée à la livraison, dans Filyxa.

## Hors périmètre

### Prévu dans les versions suivantes

1. V3 : envoi du stock par API, synchronisation automatique, statistiques fournisseur, étiquettes QR imprimées par les fournisseurs.
2. V4 : inscription en libre-service, paiement en ligne et abonnements.
3. V5 : module de réalité augmentée pour tester les produits.

### Exclu de la V2

4. Placement, patronage et calcul de consommation à partir d'un patron.
5. Saisie exacte de la consommation pour chaque taille et chaque matière : l'écart en % reste la règle.
6. Fournitures gérées comme des matières dans TissuTech, avec fiche et stock : en V2, ce sont des lignes libres du coût de revient.
7. Comptes invités pour les façonniers et partage de fiches techniques.
8. Commandes, devis et demandes d'échantillons auprès des fournisseurs.
9. Plusieurs monnaies et conversion de devises.
10. Export comptable, facturation, prix de vente par canal.
11. Planning détaillé par tâche ou par personne (diagramme de Gantt, affectation).
12. Notifications par e-mail ou push.
13. Avis ou alertes rédigés par l'IA.

## Décisions d'implémentation

- **Statuts** : Idée → Prototype → Validé → En production → Livré, plus Abandonné depuis n'importe quel statut. On peut revenir en arrière, sauf depuis Livré. Chaque statut a une couleur constante.
- **Échéances** : une date facultative par étape. Le planning de collection trie les modèles par prochaine échéance et marque en rouge celles qui sont dépassées. La notification de retard part une fois, le jour du dépassement.
- **Réservation** : elle se fait au passage « En production », après confirmation, sur le besoin total (production et prototypage restant). Stock disponible = stock atelier − réservé. Il peut devenir négatif, et il est alors affiché en rouge avec le manque. À la livraison, la déduction proposée est égale à la réservation, modifiable avant confirmation. Abandonner un modèle, ou revenir avant « En production », libère la réservation.
- **Grilles de tailles fournies** : XS–XXL, 34–48, pointures 35–46 et taille unique. L'Admin crée et modifie les grilles de l'atelier. Une grille déjà utilisée par un modèle ne peut pas perdre une taille qui a des quantités.
- **Gradation** : l'écart par défaut est de +4 % par taille au-dessus de la taille de base, et −4 % par taille en dessous. Il est modifiable pour le modèle, puis taille par taille. Besoin d'une taille = consommation de base × (1 + écart) × quantité × (1 + marge de perte).
- **Prototypage** : nombre de prototypes par modèle, 1 par défaut. Perte de prototypage par matière, 25 % par défaut. Le besoin de prototypage est calculé sur la taille de base et affiché à part du besoin de production.
- **Coût de revient** : matières (prix × besoin, pertes incluses), fournitures en lignes libres, façon par pièce, frais annexes par pièce ou en forfait pour le modèle. Le coût est affiché par pièce, par coloris et par collection. Coefficient = prix de vente visé ÷ coût par pièce. Le coefficient minimal de l'atelier est de 2,5 par défaut, réglable par l'Admin. Un coût dont une matière n'a pas de prix porte la mention « incomplet ».
- **Monnaie** : l'euro, affiché selon la langue de l'interface.
- **Droits** : l'Admin et l'Éditeur voient et modifient statuts, tailles et coûts. Le Lecteur voit les statuts, le planning et les besoins, mais ni les prix ni les coûts. L'export PDF et le lien partagé n'incluent jamais les coûts.
- **Offre Pro** : les statuts et échéances, la réservation, les tailles, le prototypage et le coût de revient sont réservés aux offres Pro et Sur mesure. En Pilote et en Essentiel, ces écrans sont visibles mais verrouillés, avec la mention « Disponible avec l'offre Pro ». Après un retour à une offre inférieure, les données restent consultables sans modification. Les ateliers en offre Pilote passent en Pro le temps du pilote.
- **Améliorations** : le rôle d'une ligne se change dans un menu sur la ligne. Le sélecteur de couleur propose une palette et une saisie libre. La cloche se met à jour sans rechargement. L'import atelier pré-remplit la dernière association de colonnes, que l'on peut modifier.

## Notes complémentaires

- **Feuille de route** : V3 pour attirer les fournisseurs, V4 pour la monétisation en libre-service, V5 pour la réalité augmentée afin de tester les produits.
- **Accès et paiements** : ils restent gérés à la main par le super-admin jusqu'à la V4.
- **Hypothèse** : les ateliers saisissent le prix de leurs matières. Sans prix, le coût de revient reste incomplet.
- **Risque** : l'écart de gradation par défaut (±4 %) ne convient pas à tous les produits, par exemple les chaussures. Il faudra le valider avec un premier atelier Pro.
- **Dépendance** : un atelier pilote prêt à suivre une collection complète dans Filyxa (critère 8).
