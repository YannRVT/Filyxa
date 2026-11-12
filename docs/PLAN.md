# Plan : Filyxa — V1 (version pilote) et V2 (Studio avancé)

> PRD source : `docs/PRD.md` · Design : `docs/DESIGN.md`

## État d'avancement

**V1 terminée le 11/11/2026** : les 14 phases sont livrées et fusionnées dans `main` (PR #1 à #16). 214 tests Flutter et 146 tests de base de données passent.

Restent ouverts (cases non cochées ci-dessous) : les mesures de performance et de qualité qui demandent des conditions réelles (appareils, réseau 4G, vraies étiquettes, fournisseur pilote).

Limites connues, à reprendre en V2 :

- L'import atelier ne mémorise pas l'association des colonnes (l'import fournisseur, si).
- Le rôle d'une ligne de matière ne se modifie pas sur place.
- Les coloris n'ont pas de sélecteur de couleur.
- Tous les modèles comptent comme « en cours » pour les notifications.
- La cloche se relit toutes les 5 min, pas en temps réel.
- Les offres sont attribuées à la main par le super-admin.

La V2 (Studio avancé, offre Pro) est planifiée en fin de document, phases 15 à 25.

## Décisions architecturales

Décisions durables qui s'appliquent à toutes les phases :

- **Pile technique** : app Flutter unique pour iOS, Android et Web, avec gestion d'état Riverpod, navigation go_router et modèles freezed. Côté serveur, Supabase hébergé dans l'Union européenne : base Postgres avec règles d'accès par ligne (RLS), authentification, stockage de fichiers et Edge Functions en Deno.
- **IA** : Claude Opus 5.5 en effort `low`, avec sortie JSON structurée et repli côté serveur en cas de refus. Elle est appelée **uniquement** depuis l'Edge Function `analyze-tag`, et la clé ne quitte jamais le serveur. Le modèle se change par un secret.
- **Routes** :
  - Connexion : `/login`, `/invite`, `/reset`.
  - App atelier : `/library` (TissuTech), `/library/:materialId`, `/library/import`, `/library/links` (correspondances à confirmer), `/scan`, `/studio`, `/studio/collections/:collectionId`, `/studio/models/:modelId`, `/suppliers`, `/notifications`, `/account`, `/account/members`, `/account/links` (liens partagés).
  - App fournisseur : `/catalog`, `/catalog/import`, `/catalog/settings`, `/catalog/:referenceId`, `/catalog/reports`.
  - Super-admin : `/admin` (organisations, offres, quotas, usage et coût de l'IA).
  - Public sans compte : `/s/:token`.
- **Schéma** :
  - `organizations` (`kind` : `atelier` | `supplier`, `plan`, `scan_quota`), `memberships` (`user_id`, `org_id`, `role` : `admin` | `editor` | `viewer`), `invitations` (e-mail, organisation, rôle, expiration 48 h), `profiles` (`locale`, `is_superadmin`).
  - `materials` (`org_id`, `kind` = `textile` en V1, `supplier_reference_id` optionnel, `snapshot` figé au retrait, champs privés : prix, notes, étiquettes, stock atelier en m) et `textile_specs` (composition en codes ISO 2076 avec pourcentages, grammage, laize, armure, coloris, entretien en codes ISO 3758, certifications, usages).
  - `supplier_references` (`supplier_org_id`, `code` normalisé, données techniques, stock brut lisible par le fournisseur seul), `availability_policies` (quantité exacte | paliers avec seuils | masquée, délai de réassort), vue `supplier_availability` (seule lecture autorisée aux ateliers), `error_reports`.
  - `collections`, `models` (`product_type` : vêtement | chaussure | maroquinerie | accessoire), `colorways` (un coloris par défaut caché par modèle), `model_materials` (coloris, rôle, consommation par pièce, unité), `colorway_quantities`, marge de perte par modèle (8 % par défaut).
  - `share_links` (`token` aléatoire, périmètre, `expires_at` 30 jours par défaut, `revoked_at`), `notifications`, `usage_counters` (organisation, mois, scans, tokens), `plans` (quota de scans par défaut de chaque offre), `platform_settings` (tarif de l'IA).
- **Autorisation** : chaque règle d'accès passe par `memberships` et une fonction `has_role(org_id, role)`. Les droits d'administration complets de la base sont utilisés uniquement dans les Edge Functions. Les ateliers ne lisent jamais les tables des fournisseurs, seulement des vues filtrées.
- **Données normalisées** : fibres en codes ISO 2076, entretien en codes ISO 3758, armures et usages en listes fermées, tout traduit à l'affichage. L'app est traduite en français, anglais, italien, espagnol, portugais et roumain dès le premier écran, sans aucune chaîne en dur.
- **Edge Functions** : `analyze-tag` (scan), `admin-users` (organisations, invitations, rôles). Les imports et la page publique passent par des fonctions en base : `import_atelier_materials`, l'import du catalogue fournisseur, et `share_view(token)`, seule fonction ouverte aux visiteurs sans compte.
- **Briques reprises de l'ancienne app TissuTech** : pictogrammes ISO 3758, règles de compatibilité et leurs tests, mise en page PDF, prompt et schéma d'extraction, banc d'essai de lecture, étiquettes de démonstration.

---

## Phase 1 : Fondations — accès et coquille de l'app

**User stories** : US-1, US-4, US-5, US-6, US-9, US-49

### Ce qu'on livre

L'app Filyxa démarre sur iOS, Android et Web avec la charte (pétrole, Montserrat et Source Sans 3), une navigation adaptative et les 6 langues. Le super-admin crée une organisation atelier et invite son premier admin. L'invité reçoit un code à 6 chiffres, choisit son mot de passe et arrive dans une app vide mais navigable. Le mot de passe oublié fonctionne par code.

### Critères d'acceptation

- [x] Sur téléphone, onglets en bas (TissuTech · Studio · Scanner · Fournisseurs · Compte) avec le Scanner central. Au-delà de 1024 px, barre latérale pétrole avec le logo.
- [x] Le super-admin crée une organisation atelier et une invitation, et l'invité reçoit un e-mail avec un code à 6 chiffres.
- [x] Un code valide plus un mot de passe de 8 caractères ou plus créent le compte et l'appartenance Admin. Un code expiré (plus de 48 h) affiche le message qui invite à demander une nouvelle invitation.
- [x] Le mot de passe oublié envoie un code à 6 chiffres qui permet de le réinitialiser.
- [x] Le changement de langue traduit toute l'interface sans redémarrage, et le choix est conservé.
- [x] Les règles d'accès sont testées : un utilisateur ne voit aucune donnée d'une autre organisation.

## Bloquée par

Aucune — démarrable immédiatement

---

## Phase 2 : Membres et rôles

**User stories** : US-3, US-7, US-8

### Ce qu'on livre

L'admin d'atelier invite ses collègues avec un rôle, change leur rôle ou les retire. Le Lecteur voit tout mais ne peut rien modifier.

### Critères d'acceptation

- [x] L'admin invite un collègue par e-mail avec le rôle Admin, Éditeur ou Lecteur, et l'invitation apparaît en attente jusqu'à son acceptation.
- [x] L'admin change le rôle d'un membre ou le retire. Un membre retiré perd l'accès immédiatement.
- [x] Le dernier admin d'une organisation ne peut pas se retirer ni se rétrograder.
- [x] Un Lecteur ne voit aucun bouton de création ou de modification, et toute écriture qu'il tenterait est refusée côté serveur (test).

## Bloquée par

- Phase 1

---

## Phase 3 : TissuTech minimal

**User stories** : US-10, US-13, US-14, US-15

### Ce qu'on livre

Un Éditeur crée une matière textile à la main (composition, grammage, laize, armure, coloris, entretien, certifications, usages, photo) et saisit son stock atelier en mètres. TissuTech affiche les matières en galerie, avec la matière mise en avant, ou en tableau technique. La fiche détaillée s'ouvre depuis les deux vues.

### Critères d'acceptation

- [x] Quand TissuTech est vide, deux actions sont proposées : « Scanner un échantillon » et « Importer un fichier Excel ».
- [x] Le formulaire de création valide les champs : la somme des pourcentages fait 100 %, et les valeurs sont numériques avec leur unité.
- [x] La galerie montre la photo, ou à défaut l'aplat du coloris. Le tableau aligne les chiffres en colonnes et affiche les codes et compositions en police d'étiquette.
- [x] Les pictogrammes d'entretien ISO 3758 s'affichent sur la fiche.
- [x] Le stock atelier se modifie depuis la fiche et apparaît dans le tableau.
- [x] Une fiche saisie en français s'affiche correctement en anglais (codes normalisés).

## Bloquée par

- Phase 1

---

## Phase 4 : Recherche et filtres

**User stories** : US-11, US-12

### Ce qu'on livre

Une recherche instantanée (nom, code article, fournisseur, couleur) et des filtres à facettes (fibre avec pourcentage minimum, plage de grammage, couleur, armure, certification, usage, disponibilité) qui se combinent, avec un compteur de résultats.

### Critères d'acceptation

- [ ] Le résultat s'affiche en moins de 1 s sur une base de 5 000 matières (critère de succès 5).
  - *À mesurer sur une base de 5 000 matières en conditions réelles.*
- [x] « Laine ≥ 50 % » ne retourne que les matières contenant au moins 50 % de WO.
- [x] Les filtres actifs s'affichent sous forme de puces amovibles. « Aucun résultat » propose d'effacer les filtres.
- [x] Les filtres actifs sont conservés quand on revient à la liste après avoir ouvert une fiche.

## Bloquée par

- Phase 3

---

## Phase 5 : Côté fournisseur — catalogue et disponibilité

**User stories** : US-31, US-32, US-33, US-35

### Ce qu'on livre

Le super-admin crée une organisation fournisseur. Son admin importe son catalogue depuis un fichier Excel ou CSV (association des colonnes, aperçu, lignes en erreur), le réimporte pour le mettre à jour, choisit comment sa disponibilité s'affiche et retire des références.

### Critères d'acceptation

- [ ] Un fichier de 500 références est importé en moins de 2 min (critère de succès 4). La limite est de 5 000 lignes par fichier.
  - *À mesurer avec le catalogue réel d'un fournisseur pilote.*
- [x] L'association des colonnes est mémorisée pour le prochain import. Une réimportation met à jour les références existantes par code article, sans créer de doublons.
- [x] Les lignes en erreur sont listées avec leur motif, et les lignes valides sont importées.
- [x] Le fournisseur choisit pour sa disponibilité : quantité exacte, paliers avec ses seuils, ou masquée, globalement ou référence par référence, avec un délai de réassort en semaines pour ce qui est sur commande.
- [x] Un test prouve qu'un compte atelier ne peut pas lire le stock brut, seulement la vue filtrée.
- [x] Une référence retirée n'apparaît plus dans le catalogue publié.

## Bloquée par

- Phase 1

---

## Phase 6 : Scanner IA

**User stories** : US-23, US-24, US-25, US-27, US-28, US-29, US-30

### Ce qu'on livre

Sur mobile, on photographie l'étiquette d'un échantillon. Sur le Web, on importe une photo. Claude lit l'étiquette et renvoie une fiche pré-remplie où les champs incertains sont surlignés. L'Éditeur la valide ou la corrige, puis l'enregistre. Rien n'est enregistré sans validation. Les doublons et les erreurs sont gérés, et chaque scan est compté dans le quota de l'organisation.

### Critères d'acceptation

- [ ] Fiche pré-remplie affichée en moins de 7 s en 4G pour 9 scans sur 10 (critère de succès 1).
  - *À mesurer en 4G sur iPhone et Android.*
- [ ] Au moins 90 % des champs sont corrects sur un jeu de 50 vraies étiquettes, mesuré avec le banc d'essai (critère de succès 2).
  - *À mesurer avec le banc d'essai sur 50 vraies étiquettes.*
- [x] Un code article déjà présent dans TissuTech déclenche un avertissement de doublon avec un lien vers la fiche existante.
- [x] Une photo illisible, une erreur réseau ou un refus de l'IA affiche un message clair, avec les choix « Réessayer » et « Saisir à la main ».
- [x] Le compteur mensuel s'incrémente à chaque scan. Les admins voient un avertissement à 80 % et à 100 %. À 100 %, le scan est bloqué mais la saisie manuelle reste possible.
- [x] La clé de l'IA n'apparaît dans aucun build de l'app (vérification).

## Bloquée par

- Phase 3

---

## Phase 7 : Matière liée à une référence fournisseur

**User stories** : US-16, US-17, US-19, US-20, US-26

### Ce qu'on livre

Au scan, l'app cherche une correspondance (fournisseur et code normalisé) dans les catalogues et demande « C'est bien cette référence ? », avec la fiche du fournisseur et des références proches. Une matière liée affiche les données du fournisseur en lecture seule et sa disponibilité à jour, et l'atelier y ajoute sa couche privée. Une fiche créée à la main peut être liée après coup. Si le fournisseur retire la référence, la copie figée est conservée. **C'est le premier moment démontrable à un pilote.**

### Critères d'acceptation

- [ ] Au moins 80 % des échantillons d'un fournisseur pilote trouvent la bonne référence avant confirmation (critère de succès 3).
  - *Mesure reportée au démarrage du premier fournisseur pilote (aucun pilote à ce jour). En attendant, le parcours est vérifié sur le catalogue de démo « Tissage Démo » (scan en mode démo → `TD-SRG-280` proposée).*
- [x] Rien n'est lié sans confirmation. « Aucune de ces références » enregistre une fiche propre à l'atelier.
- [x] Sur une matière liée, les champs techniques ne sont pas modifiables et portent la mention « Données fournisseur ». Prix, notes, étiquettes, photos et stock atelier restent modifiables.
- [x] Une mise à jour du catalogue du fournisseur apparaît dans la fiche de l'atelier sans action de sa part.
- [x] Après un retrait, la fiche reste visible avec la mention « Référence retirée par le fournisseur » et les dernières valeurs connues.
- [x] La pastille de disponibilité respecte la politique du fournisseur (paliers ou quantité exacte).

## Bloquée par

- Phase 5
- Phase 6

---

## Phase 8 : Import atelier et rapprochement automatique

**User stories** : US-21, US-22

### Ce qu'on livre

Un Éditeur importe la base existante de l'atelier depuis un fichier Excel ou CSV, avec le même parcours que les fournisseurs. À la fin de l'import, les matières sont automatiquement rapprochées des catalogues fournisseurs. Les correspondances sûres sont liées, les autres sont proposées à confirmer.

### Critères d'acceptation

- [x] Association des colonnes, aperçu et lignes en erreur avec leur motif, jusqu'à 5 000 lignes.
- [x] Le récapitulatif de fin d'import affiche « X importées · Y reliées à un fournisseur · Z à confirmer · W en erreur ».
- [x] Les correspondances à confirmer apparaissent dans une liste à traiter une par une.
- [x] Un import relancé ne duplique pas les matières déjà importées.

## Bloquée par

- Phase 7

---

## Phase 9 : Signalements d'erreur

**User stories** : US-18, US-34

### Ce qu'on livre

Depuis une matière liée, un Éditeur signale une erreur sur un champ (valeur attendue et commentaire). Le fournisseur la retrouve dans sa liste de signalements, corrige sa référence ou répond. L'atelier est notifié de la réponse.

### Critères d'acceptation

- [x] Un signalement précise le champ concerné, la valeur constatée et un commentaire facultatif.
- [x] Le fournisseur voit les signalements sans le nom de l'atelier, sauf si celui-ci a choisi de partager son identité (option désactivée par défaut en V1).
- [x] Le statut passe de « Ouvert » à « Corrigé » ou « Rejeté, avec motif ». L'atelier voit ce statut sur la fiche et reçoit une notification dans l'app.

## Bloquée par

- Phase 7

---

## Phase 10 : Studio — collections, modèles, coloris, besoin

**User stories** : US-36, US-37, US-38, US-39, US-40, US-43

### Ce qu'on livre

Un Éditeur crée une collection, puis des modèles typés (vêtement, chaussure, maroquinerie, accessoire). Il associe des matières par rôle (liste par type de produit, complétable) et décline le modèle en coloris. Il saisit la consommation par pièce, les quantités par coloris et la marge de perte, et voit le besoin total par matière.

### Critères d'acceptation

- [x] Les rôles proposés changent selon le type de produit (par exemple tige, doublure, semelle pour une chaussure), et l'atelier peut en ajouter.
- [x] Un modèle à un seul coloris n'affiche pas de déclinaisons. Les onglets de coloris apparaissent dès le deuxième.
- [x] Besoin = consommation × quantité × (1 + marge), avec une marge de 8 % par défaut modifiable par modèle. Les valeurs sont recalculées instantanément.
- [x] Une collection vide ou un modèle sans matière affiche l'action suivante à faire.
- [x] Le Lecteur consulte le Studio sans pouvoir le modifier.

## Bloquée par

- Phase 3

---

## Phase 11 : Alertes du Studio et notifications

**User stories** : US-41, US-42

### Ce qu'on livre

Des règles déterministes signalent les problèmes d'entretien, de technique, de certifications et de stock sur chaque modèle et coloris, avec leur explication. Une cloche dans l'app prévient quand une matière d'un modèle en cours passe en stock faible ou en rupture, ou que sa fiche est modifiée ou retirée par le fournisseur.

### Critères d'acceptation

- [x] Chaque alerte cite les valeurs en cause, par exemple « Doublure : nettoyage à sec uniquement (P). Principal : lavage 30 °C ».
- [x] Le même modèle donne toujours les mêmes alertes, et les règles sont couvertes par des tests unitaires (repris de l'ancienne app et étendus).
- [x] L'alerte de stock compare le besoin au stock atelier puis au stock fournisseur, selon les paliers ou la quantité exacte.
- [x] La notification de rupture apparaît moins de 2 h après le passage en rupture chez le fournisseur (critère de succès 8).
  - *La notification est créée dès le changement de stock ; la cloche se relit toutes les 5 min.*
- [x] La cloche affiche le nombre de notifications non lues, et chaque notification ouvre le modèle ou la fiche concernés.

## Bloquée par

- Phase 7
- Phase 10

---

## Phase 12 : Export PDF

**User stories** : US-44, US-45

### Ce qu'on livre

Export d'une fiche matière en PDF A4 et du dossier matières d'un modèle ou d'une collection, dans la langue choisie, avec les pictogrammes d'entretien et la charte Filyxa.

### Critères d'acceptation

- [ ] Le dossier d'une collection de 20 modèles est généré en moins de 10 s (critère de succès 6).
  - *À mesurer sur appareil avec une vraie collection.*
- [x] La langue du PDF se choisit à l'export, indépendamment de la langue de l'interface.
- [x] Le PDF n'inclut ni prix ni notes internes.
- [ ] Aperçu, impression et partage du fichier fonctionnent sur iOS, Android et Web.
  - *Génération du PDF couverte par les tests ; aperçu, impression et partage restent à vérifier sur Web, iPhone et Android.*

## Bloquée par

- Phase 10

---

## Phase 13 : Lien partagé public

**User stories** : US-46, US-47, US-48

### Ce qu'on livre

Un Éditeur crée un lien en lecture seule vers une fiche, un modèle ou une collection, valable 30 jours par défaut et révocable. Le façonnier l'ouvre sur son téléphone sans compte et voit des fiches à jour. Le QR code du PDF pointe vers ce lien.

### Critères d'acceptation

- [ ] Le lien s'ouvre sur un téléphone sans compte (critère de succès 7), dans la langue choisie à la création.
  - *Couvert par les tests ; reste à vérifier sur un vrai téléphone en navigation privée.*
- [x] La page n'affiche jamais les prix, les notes ni le stock atelier, et le serveur ne renvoie pas ces champs (test).
- [x] Un lien expiré ou révoqué affiche une page qui l'explique.
- [x] La liste des liens actifs permet de modifier l'expiration et de révoquer un lien.
- [x] Le QR code du dossier PDF ouvre le lien correspondant.

## Bloquée par

- Phase 12

---

## Phase 14 : Console super-admin — offres et usage

**User stories** : US-2

### Ce qu'on livre

Une section `/admin`, visible uniquement par le super-admin sur le Web : liste des organisations, offre et quota de scans de chacune, usage du mois (scans, membres, références) et coût estimé de l'IA.

### Critères d'acceptation

- [x] La console est inaccessible à tout compte non super-admin, et l'appel serveur est refusé (test).
- [x] Changer l'offre ou le quota d'une organisation s'applique immédiatement au scanner.
- [x] Le coût de l'IA par organisation et par mois est calculé à partir des tokens consommés.

## Bloquée par

- Phase 6


---

# V2 — Studio avancé

> PRD source : `docs/PRD.md`, partie « V2 — Studio avancé »

## Décisions architecturales (V2)

Elles s'ajoutent aux décisions de la V1, qui restent valables :

- **Offre Pro** : les fonctionnalités Pro sont rattachées aux offres (`plans`). Les offres Pro et Sur mesure les ouvrent, ainsi que l'offre Pilote le temps du pilote. Le contrôle se fait côté serveur, sur chaque écriture, par une fonction unique `has_pro(org_id)`. L'interface ne sert qu'à afficher le verrou. Après un retour à une offre inférieure, la lecture reste ouverte et l'écriture est refusée.
- **Routes** :
  - `/studio/collections/:collectionId` reçoit un onglet Planning, à côté de la liste des modèles.
  - `/account/sizes` : grilles de tailles de l'atelier (Admin).
  - `/account/workspace` : réglages de l'atelier, dont le coefficient minimal (Admin).
  - Le reste se loge dans `/studio/models/:modelId` (sections Production, Tailles, Prototypage, Coût).
- **Schéma** :
  - `models` reçoit `status` (`idea` | `prototype` | `validated` | `in_production` | `delivered` | `abandoned`, `idea` par défaut), `size_chart_id`, `base_size`, `grade_pct` (4 par défaut), `prototype_count` (1 par défaut) et `target_price`.
  - `model_deadlines` : (`model_id`, `stage`, `due_date`, `notified_at`).
  - `size_charts` : (`org_id` null pour les grilles fournies, `name`, `sizes` ordonnées). `model_size_grades` : écart propre à une taille, quand il diffère de l'écart du modèle.
  - `colorway_size_quantities` : (`colorway_id`, `size`, `quantity`). Sans grille, la quantité par coloris de la V1 reste utilisée.
  - `model_materials` reçoit `proto_loss_pct` (25 par défaut).
  - `stock_reservations` : (`material_id`, `model_id`, `meters`, `created_at`). Stock disponible = stock atelier − somme des réservations.
  - `model_costs` : (`model_id`, `kind` : `supply` | `labor` | `overhead`, `label`, `unit_price`, `quantity`, `per` : `piece` | `model`).
  - `organizations` reçoit `min_coefficient` (2,5 par défaut).
- **Calcul** : le besoin et le coût sont calculés dans l'app, instantanément et de façon déterministe, par une seule fonction de domaine couverte par des tests unitaires. Pour réserver et déduire le stock, le serveur enregistre les mètres affichés et confirmés par l'Éditeur, après avoir vérifié le rôle, l'offre et l'appartenance des matières.
- **Confidentialité des prix** : le prix des matières et tous les coûts sont lisibles par les Admins et les Éditeurs uniquement. Le prix des matières passe dans une table à part, protégée par les règles d'accès. Le Lecteur ne le voit plus dans TissuTech : c'est un changement de comportement par rapport à la V1. Les PDF et les liens partagés n'incluent jamais les coûts.
- **Temps réel** : la cloche s'abonne aux nouvelles notifications de l'utilisateur au lieu de se relire toutes les 5 minutes.

---

## Phase 15 : Statuts du modèle et verrou Pro

**User stories** : US-50, US-59, US-75, US-76, US-77

### Ce qu'on livre

Un modèle passe par les statuts Idée, Prototype, Validé, En production, Livré ou Abandonné, chacun avec sa couleur. Le statut s'affiche sur la fiche du modèle et dans la liste de la collection. Les ateliers hors offre Pro voient ce statut verrouillé, avec la mention « Disponible avec l'offre Pro ». Le super-admin passe un atelier en Pro depuis la console, et l'effet est immédiat. Les alertes de stock et de fiche fournisseur ne concernent plus que les modèles en Prototype, Validé ou En production.

### Critères d'acceptation

- [x] Le statut suit l'ordre Idée → Prototype → Validé → En production → Livré, et un modèle peut passer en Abandonné depuis n'importe quel statut. On peut revenir en arrière, sauf depuis Livré.
- [x] Un atelier Essentiel voit la mention « Disponible avec l'offre Pro » et ne peut pas changer de statut. Le serveur refuse le changement (test).
- [x] Dès que le super-admin passe l'atelier en Pro, le statut se modifie sans reconnexion.
- [x] Après un retour en Essentiel, le statut reste affiché mais n'est plus modifiable.
- [x] Un modèle en Idée, Livré ou Abandonné ne déclenche plus de notification de stock ni de fiche fournisseur (test).
- [x] Les modèles existants passent en Prototype à la migration, pour continuer à recevoir les notifications comme en V1. Les nouveaux modèles partent d'Idée.

## Bloquée par

Aucune — démarrable immédiatement.

---

## Phase 16 : Échéances, planning de collection et notification de retard

**User stories** : US-51, US-52, US-53

### Ce qu'on livre

Chaque étape d'un modèle reçoit une échéance facultative. L'onglet Planning de la collection trie les modèles par prochaine échéance, les regroupe par statut et marque en rouge les échéances dépassées. Le jour où une échéance est dépassée, les membres de l'atelier reçoivent une notification qui ouvre le modèle.

### Critères d'acceptation

- [x] Une échéance se fixe, se modifie et s'efface pour chaque étape du modèle.
- [x] Le planning trie les modèles par prochaine échéance, les regroupe par statut et affiche en rouge les échéances dépassées.
- [x] Une échéance dépassée déclenche une seule notification, le jour même (critère de succès V2 n° 4, test).
- [x] Un modèle Livré ou Abandonné ne déclenche plus de notification de retard.
- [x] Le Lecteur consulte le planning sans pouvoir le modifier.

## Bloquée par

- Phase 15

---

## Phase 17 : Grilles de tailles et quantités par taille et par coloris

**User stories** : US-60, US-61, US-62, US-65

### Ce qu'on livre

Filyxa fournit les grilles XS–XXL, 34–48, pointures 35–46 et taille unique. L'Admin crée et modifie celles de l'atelier dans `/account/sizes`. Sur un modèle, l'Éditeur choisit une grille et saisit les quantités dans un tableau tailles × coloris, avec les totaux. Un modèle sans grille garde la quantité par coloris de la V1.

### Critères d'acceptation

- [x] Les quatre grilles fournies sont disponibles dans tous les ateliers et ne sont pas modifiables.
- [x] L'Admin crée, renomme et réordonne les tailles d'une grille de l'atelier. Une taille qui a des quantités sur un modèle ne peut pas être supprimée.
- [x] Le tableau tailles × coloris affiche les totaux par taille, par coloris et le total général.
- [x] Un modèle sans grille fonctionne comme en V1 (test de non-régression).
- [x] Un changement de grille sur un modèle qui a déjà des quantités demande une confirmation, puis efface les quantités devenues sans objet.

## Bloquée par

- Phase 15

---

## Phase 18 : Gradation — besoin par taille

**User stories** : US-63, US-64

### Ce qu'on livre

L'Éditeur désigne la taille de base du modèle. La consommation saisie correspond à cette taille, et chaque taille s'en écarte de +4 % par taille au-dessus et de −4 % par taille en dessous. Cet écart se modifie pour le modèle, puis taille par taille. Le besoin de chaque matière est détaillé par taille et par coloris.

### Critères d'acceptation

- [x] Besoin d'une taille = consommation de base × (1 + écart) × quantité × (1 + marge de perte). Le calcul est vérifié au centimètre près sur 5 modèles de référence (critère de succès V2 n° 2).
- [x] L'écart du modèle et l'écart propre à une taille se modifient, et le besoin se recalcule en moins de 1 s pour un modèle de 10 matières, 6 tailles et 3 coloris (critère de succès V2 n° 1).
- [x] Le détail du besoin par taille et par coloris s'affiche pour chaque matière, avec le total.
- [x] Les alertes de stock du Studio utilisent le besoin gradué.

## Bloquée par

- Phase 17

---

## Phase 19 : Prototypage

**User stories** : US-66, US-67

### Ce qu'on livre

L'Éditeur indique le nombre de prototypes du modèle (1 par défaut) et une perte de prototypage par matière (25 % par défaut), qui couvre les tests de colle, les tests matière et la sublimation. Le besoin de prototypage est calculé sur la taille de base. Il s'affiche à côté du besoin de production, avec le total des deux.

### Critères d'acceptation

- [x] Besoin de prototypage = nombre de prototypes × consommation de base × (1 + perte de prototypage de la matière), calculé sur les lignes du premier coloris.
- [x] La perte de prototypage se règle ligne par ligne. Une nouvelle ligne reçoit 25 %.
- [x] Le besoin de prototypage, le besoin de production et leur total s'affichent séparément pour chaque matière.

## Bloquée par

- Phase 15

---

## Phase 20 : Réservation et déduction du stock

**User stories** : US-54, US-55, US-56, US-57, US-58

### Ce qu'on livre

Au passage « En production », Filyxa montre le besoin à réserver, matière par matière, signale tout manque et demande une confirmation. La fiche de chaque matière affiche le stock atelier, le stock réservé, le stock disponible et les modèles qui réservent. Au passage « Livré », Filyxa propose de déduire du stock atelier les mètres réservés, modifiables avant confirmation. Abandonner un modèle, ou le ramener avant « En production », libère sa réservation.

### Critères d'acceptation

- [x] La confirmation du passage « En production » crée une réservation par matière, égale au besoin total (production et prototypage). Le stock disponible baisse d'autant (critère de succès V2 n° 3, test).
- [x] Avant de confirmer, un manque s'affiche en rouge avec le nombre de mètres manquants. On peut lancer quand même.
- [x] La fiche matière affiche le stock atelier, le stock réservé et le stock disponible, avec la liste des modèles qui réservent.
- [x] Au passage « Livré », la déduction proposée est égale à la réservation, modifiable par matière. Après confirmation, le stock atelier baisse et la réservation disparaît (test).
- [x] Abandonner un modèle, ou le ramener avant « En production », libère la réservation (test).
- [x] Réservations et déductions sont refusées côté serveur hors offre Pro et pour le Lecteur.

## Bloquée par

- Phase 15
- Phase 18
- Phase 19

---

## Phase 21 : Coût de revient

**User stories** : US-68, US-69, US-72, US-73, US-74

### Ce qu'on livre

La section Coût du modèle calcule le coût matières à partir du prix des matières, du besoin et des pertes. L'Éditeur y ajoute des fournitures, la façon et des frais annexes, par pièce ou en forfait. Le coût de revient s'affiche par pièce, par coloris et pour la collection, prototypage à part. Un coût dont une matière n'a pas de prix porte la mention « incomplet ». Les prix et les coûts deviennent invisibles pour le Lecteur, y compris le prix des matières dans TissuTech.

### Critères d'acceptation

- [ ] Coût par pièce = coût matières + fournitures + façon + frais par pièce + frais forfaitaires ÷ nombre de pièces. Le calcul est vérifié au centime près sur 5 modèles de référence (critère de succès V2 n° 2).
- [ ] Le coût par coloris tient compte des tailles (besoin gradué). Le coût de la collection additionne ses modèles, avec le prototypage affiché à part.
- [ ] Une matière sans prix fait afficher la mention « incomplet » et la liste des matières concernées.
- [ ] Un Lecteur ne reçoit ni le prix des matières ni les coûts du serveur (test). Ces champs n'apparaissent pas dans son interface.
- [ ] Les montants sont en euros, au format de la langue de l'interface. Ni les PDF ni les liens partagés ne contiennent de coût (test).

## Bloquée par

- Phase 15
- Phase 18 et Phase 19, pour que le coût inclue les tailles et le prototypage

---

## Phase 22 : Prix de vente visé et coefficient

**User stories** : US-70, US-71

### Ce qu'on livre

L'Éditeur saisit un prix de vente visé, et Filyxa affiche le coefficient obtenu (prix de vente ÷ coût par pièce). L'Admin fixe le coefficient minimal de l'atelier dans `/account/workspace` (2,5 par défaut). Un modèle sous ce minimum reçoit une alerte dans le Studio, et le planning de la collection le signale.

### Critères d'acceptation

- [ ] Le coefficient se met à jour instantanément quand le prix de vente ou un coût change.
- [ ] Sous le coefficient minimal, une alerte cite le coefficient obtenu et le minimum, par exemple « Coefficient 2,1 < 2,5 ».
- [ ] Seul l'Admin modifie le coefficient minimal.
- [ ] Sans prix de vente ou avec un coût incomplet, aucun coefficient n'est affiché, et un message dit ce qui manque.

## Bloquée par

- Phase 21

---

## Phase 23 : Modèle plus fluide

**User stories** : US-78, US-79

### Ce qu'on livre

Le rôle d'une ligne de matière se change depuis un menu sur la ligne, sans la supprimer. Un coloris se choisit avec un sélecteur de couleur : une palette et une saisie libre.

### Critères d'acceptation

- [ ] Changer le rôle conserve la consommation, la perte de prototypage et la position de la ligne.
- [ ] Le sélecteur propose une palette et accepte une couleur saisie en hexadécimal. La couleur choisie apparaît sur l'onglet du coloris et dans le PDF.
- [ ] Le Lecteur ne voit ni le menu ni le sélecteur.

## Bloquée par

Aucune — démarrable immédiatement.

---

## Phase 24 : Notifications en temps réel

**User stories** : US-80

### Ce qu'on livre

La cloche se met à jour dès qu'une notification est créée pour l'utilisateur, sans attendre ni recharger la page. Elle continue de fonctionner, avec une relecture de secours, quand la connexion temps réel est coupée.

### Critères d'acceptation

- [ ] Une notification apparaît dans la cloche moins de 5 s après l'événement (critère de succès V2 n° 5).
- [ ] Un utilisateur ne reçoit que les notifications de sa propre organisation (test).
- [ ] Après une coupure réseau, le compteur se remet à jour dès le retour de la connexion.

## Bloquée par

Aucune — démarrable immédiatement.

---

## Phase 25 : Import atelier mémorisé

**User stories** : US-81

### Ce qu'on livre

L'association des colonnes de l'import atelier est enregistrée pour l'atelier. Au prochain import, elle est proposée d'office et reste modifiable, comme pour l'import fournisseur.

### Critères d'acceptation

- [ ] Un deuxième import pré-remplit l'association des colonnes du précédent (critère de succès V2 n° 6).
- [ ] Une colonne absente du nouveau fichier est ignorée sans erreur. Les colonnes nouvelles sont devinées comme en V1.
- [ ] L'association est partagée par tous les Éditeurs de l'atelier.

## Bloquée par

Aucune — démarrable immédiatement.
