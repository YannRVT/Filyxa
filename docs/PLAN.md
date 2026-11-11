# Plan : Filyxa — version pilote (V1)

> PRD source : `docs/PRD.md` · Design : `docs/DESIGN.md`

## Décisions architecturales

Décisions durables qui s'appliquent à toutes les phases :

- **Pile technique** : app Flutter unique pour iOS, Android et Web, avec gestion d'état Riverpod, navigation go_router et modèles freezed. Côté serveur, Supabase hébergé dans l'Union européenne : base Postgres avec règles d'accès par ligne (RLS), authentification, stockage de fichiers et Edge Functions en Deno.
- **IA** : Claude Opus 5.5 en effort `low`, avec sortie JSON structurée et repli côté serveur en cas de refus. Elle est appelée **uniquement** depuis l'Edge Function `analyze-tag`, et la clé ne quitte jamais le serveur. Le modèle se change par un secret.
- **Routes** :
  - Connexion : `/login`, `/invite`, `/reset`.
  - App atelier : `/library` (TissuTech), `/library/:materialId`, `/library/import`, `/scan`, `/studio`, `/studio/collections/:collectionId`, `/studio/models/:modelId`, `/suppliers`, `/notifications`, `/account`, `/account/members`.
  - App fournisseur : `/catalog`, `/catalog/import`, `/catalog/:referenceId`, `/catalog/reports`.
  - Super-admin : `/admin`, `/admin/organizations/:orgId`.
  - Public sans compte : `/s/:token`.
- **Schéma** :
  - `organizations` (`kind` : `atelier` | `supplier`, `plan`, `scan_quota`), `memberships` (`user_id`, `org_id`, `role` : `admin` | `editor` | `viewer`), `invitations` (e-mail, organisation, rôle, expiration 48 h), `profiles` (`locale`, `is_superadmin`).
  - `materials` (`org_id`, `kind` = `textile` en V1, `supplier_reference_id` optionnel, `snapshot` figé au retrait, champs privés : prix, notes, étiquettes, stock atelier en m) et `textile_specs` (composition en codes ISO 2076 avec pourcentages, grammage, laize, armure, coloris, entretien en codes ISO 3758, certifications, usages).
  - `supplier_references` (`supplier_org_id`, `code` normalisé, données techniques, stock brut lisible par le fournisseur seul), `availability_policies` (quantité exacte | paliers avec seuils | masquée, délai de réassort), vue `supplier_availability` (seule lecture autorisée aux ateliers), `error_reports`.
  - `collections`, `models` (`product_type` : vêtement | chaussure | maroquinerie | accessoire), `colorways` (un coloris par défaut caché par modèle), `model_materials` (coloris, rôle, consommation par pièce, unité), `colorway_quantities`, marge de perte par modèle (8 % par défaut).
  - `share_links` (`token` aléatoire, périmètre, `expires_at` 30 jours par défaut, `revoked_at`), `notifications`, `usage_counters` (organisation, mois, scans), `imports` (journal, lignes en erreur).
- **Autorisation** : chaque règle d'accès passe par `memberships` et une fonction `has_role(org_id, role)`. Les droits d'administration complets de la base sont utilisés uniquement dans les Edge Functions. Les ateliers ne lisent jamais les tables des fournisseurs, seulement des vues filtrées.
- **Données normalisées** : fibres en codes ISO 2076, entretien en codes ISO 3758, armures et usages en listes fermées, tout traduit à l'affichage. L'app est traduite en français, anglais, italien, espagnol, portugais et roumain dès le premier écran, sans aucune chaîne en dur.
- **Edge Functions** : `analyze-tag` (scan), `admin-users` (organisations, invitations, rôles), `import-file` (imports atelier et fournisseur), `share-view` (page publique filtrée).
- **Briques reprises de l'ancienne app TissuTech** : pictogrammes ISO 3758, règles de compatibilité et leurs tests, mise en page PDF, prompt et schéma d'extraction, banc d'essai de lecture, étiquettes de démonstration.

---

## Phase 1 : Fondations — accès et coquille de l'app

**User stories** : US-1, US-4, US-5, US-6, US-9, US-49

### Ce qu'on livre

L'app Filyxa démarre sur iOS, Android et Web avec la charte (pétrole, Montserrat et Source Sans 3), une navigation adaptative et les 6 langues. Le super-admin crée une organisation atelier et invite son premier admin. L'invité reçoit un code à 6 chiffres, choisit son mot de passe et arrive dans une app vide mais navigable. Le mot de passe oublié fonctionne par code.

### Critères d'acceptation

- [ ] Sur téléphone, onglets en bas (TissuTech · Studio · Scanner · Fournisseurs · Compte) avec le Scanner central. Au-delà de 1024 px, barre latérale pétrole avec le logo.
- [ ] Le super-admin crée une organisation atelier et une invitation, et l'invité reçoit un e-mail avec un code à 6 chiffres.
- [ ] Un code valide plus un mot de passe de 8 caractères ou plus créent le compte et l'appartenance Admin. Un code expiré (plus de 48 h) affiche le message qui invite à demander une nouvelle invitation.
- [ ] Le mot de passe oublié envoie un code à 6 chiffres qui permet de le réinitialiser.
- [ ] Le changement de langue traduit toute l'interface sans redémarrage, et le choix est conservé.
- [ ] Les règles d'accès sont testées : un utilisateur ne voit aucune donnée d'une autre organisation.

## Bloquée par

Aucune — démarrable immédiatement

---

## Phase 2 : Membres et rôles

**User stories** : US-3, US-7, US-8

### Ce qu'on livre

L'admin d'atelier invite ses collègues avec un rôle, change leur rôle ou les retire. Le Lecteur voit tout mais ne peut rien modifier.

### Critères d'acceptation

- [ ] L'admin invite un collègue par e-mail avec le rôle Admin, Éditeur ou Lecteur, et l'invitation apparaît en attente jusqu'à son acceptation.
- [ ] L'admin change le rôle d'un membre ou le retire. Un membre retiré perd l'accès immédiatement.
- [ ] Le dernier admin d'une organisation ne peut pas se retirer ni se rétrograder.
- [ ] Un Lecteur ne voit aucun bouton de création ou de modification, et toute écriture qu'il tenterait est refusée côté serveur (test).

## Bloquée par

- Phase 1

---

## Phase 3 : TissuTech minimal

**User stories** : US-10, US-13, US-14, US-15

### Ce qu'on livre

Un Éditeur crée une matière textile à la main (composition, grammage, laize, armure, coloris, entretien, certifications, usages, photo) et saisit son stock atelier en mètres. TissuTech affiche les matières en galerie, avec la matière mise en avant, ou en tableau technique. La fiche détaillée s'ouvre depuis les deux vues.

### Critères d'acceptation

- [ ] Quand TissuTech est vide, deux actions sont proposées : « Scanner un échantillon » et « Importer un fichier Excel ».
- [ ] Le formulaire de création valide les champs : la somme des pourcentages fait 100 %, et les valeurs sont numériques avec leur unité.
- [ ] La galerie montre la photo, ou à défaut l'aplat du coloris. Le tableau aligne les chiffres en colonnes et affiche les codes et compositions en police d'étiquette.
- [ ] Les pictogrammes d'entretien ISO 3758 s'affichent sur la fiche.
- [ ] Le stock atelier se modifie depuis la fiche et apparaît dans le tableau.
- [ ] Une fiche saisie en français s'affiche correctement en anglais (codes normalisés).

## Bloquée par

- Phase 1

---

## Phase 4 : Recherche et filtres

**User stories** : US-11, US-12

### Ce qu'on livre

Une recherche instantanée (nom, code article, fournisseur, couleur) et des filtres à facettes (fibre avec pourcentage minimum, plage de grammage, couleur, armure, certification, usage, disponibilité) qui se combinent, avec un compteur de résultats.

### Critères d'acceptation

- [ ] Le résultat s'affiche en moins de 1 s sur une base de 5 000 matières (critère de succès 5).
- [ ] « Laine ≥ 50 % » ne retourne que les matières contenant au moins 50 % de WO.
- [ ] Les filtres actifs s'affichent sous forme de puces amovibles. « Aucun résultat » propose d'effacer les filtres.
- [ ] Les filtres actifs sont conservés quand on revient à la liste après avoir ouvert une fiche.

## Bloquée par

- Phase 3

---

## Phase 5 : Côté fournisseur — catalogue et disponibilité

**User stories** : US-31, US-32, US-33, US-35

### Ce qu'on livre

Le super-admin crée une organisation fournisseur. Son admin importe son catalogue depuis un fichier Excel ou CSV (association des colonnes, aperçu, lignes en erreur), le réimporte pour le mettre à jour, choisit comment sa disponibilité s'affiche et retire des références.

### Critères d'acceptation

- [ ] Un fichier de 500 références est importé en moins de 2 min (critère de succès 4). La limite est de 5 000 lignes par fichier.
- [ ] L'association des colonnes est mémorisée pour le prochain import. Une réimportation met à jour les références existantes par code article, sans créer de doublons.
- [ ] Les lignes en erreur sont listées avec leur motif, et les lignes valides sont importées.
- [ ] Le fournisseur choisit pour sa disponibilité : quantité exacte, paliers avec ses seuils, ou masquée, globalement ou référence par référence, avec un délai de réassort en semaines pour ce qui est sur commande.
- [ ] Un test prouve qu'un compte atelier ne peut pas lire le stock brut, seulement la vue filtrée.
- [ ] Une référence retirée n'apparaît plus dans le catalogue publié.

## Bloquée par

- Phase 1

---

## Phase 6 : Scanner IA

**User stories** : US-23, US-24, US-25, US-27, US-28, US-29, US-30

### Ce qu'on livre

Sur mobile, on photographie l'étiquette d'un échantillon. Sur le Web, on importe une photo. Claude lit l'étiquette et renvoie une fiche pré-remplie où les champs incertains sont surlignés. L'Éditeur la valide ou la corrige, puis l'enregistre. Rien n'est enregistré sans validation. Les doublons et les erreurs sont gérés, et chaque scan est compté dans le quota de l'organisation.

### Critères d'acceptation

- [ ] Fiche pré-remplie affichée en moins de 7 s en 4G pour 9 scans sur 10 (critère de succès 1).
- [ ] Au moins 90 % des champs sont corrects sur un jeu de 50 vraies étiquettes, mesuré avec le banc d'essai (critère de succès 2).
- [ ] Un code article déjà présent dans TissuTech déclenche un avertissement de doublon avec un lien vers la fiche existante.
- [ ] Une photo illisible, une erreur réseau ou un refus de l'IA affiche un message clair, avec les choix « Réessayer » et « Saisir à la main ».
- [ ] Le compteur mensuel s'incrémente à chaque scan. Les admins voient un avertissement à 80 % et à 100 %. À 100 %, le scan est bloqué mais la saisie manuelle reste possible.
- [ ] La clé de l'IA n'apparaît dans aucun build de l'app (vérification).

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
- [ ] Rien n'est lié sans confirmation. « Aucune de ces références » enregistre une fiche propre à l'atelier.
- [ ] Sur une matière liée, les champs techniques ne sont pas modifiables et portent la mention « Données fournisseur ». Prix, notes, étiquettes, photos et stock atelier restent modifiables.
- [ ] Une mise à jour du catalogue du fournisseur apparaît dans la fiche de l'atelier sans action de sa part.
- [ ] Après un retrait, la fiche reste visible avec la mention « Référence retirée par le fournisseur » et les dernières valeurs connues.
- [ ] La pastille de disponibilité respecte la politique du fournisseur (paliers ou quantité exacte).

## Bloquée par

- Phase 5
- Phase 6

---

## Phase 8 : Import atelier et rapprochement automatique

**User stories** : US-21, US-22

### Ce qu'on livre

Un Éditeur importe la base existante de l'atelier depuis un fichier Excel ou CSV, avec le même parcours que les fournisseurs. À la fin de l'import, les matières sont automatiquement rapprochées des catalogues fournisseurs. Les correspondances sûres sont liées, les autres sont proposées à confirmer.

### Critères d'acceptation

- [ ] Association des colonnes, aperçu et lignes en erreur avec leur motif, jusqu'à 5 000 lignes.
- [ ] Le récapitulatif de fin d'import affiche « X importées · Y reliées à un fournisseur · Z à confirmer · W en erreur ».
- [ ] Les correspondances à confirmer apparaissent dans une liste à traiter une par une.
- [ ] Un import relancé ne duplique pas les matières déjà importées.

## Bloquée par

- Phase 7

---

## Phase 9 : Signalements d'erreur

**User stories** : US-18, US-34

### Ce qu'on livre

Depuis une matière liée, un Éditeur signale une erreur sur un champ (valeur attendue et commentaire). Le fournisseur la retrouve dans sa liste de signalements, corrige sa référence ou répond. L'atelier est notifié de la réponse.

### Critères d'acceptation

- [ ] Un signalement précise le champ concerné, la valeur constatée et un commentaire facultatif.
- [ ] Le fournisseur voit les signalements sans le nom de l'atelier, sauf si celui-ci a choisi de partager son identité (option désactivée par défaut en V1).
- [ ] Le statut passe de « Ouvert » à « Corrigé » ou « Rejeté, avec motif ». L'atelier voit ce statut sur la fiche et reçoit une notification dans l'app.

## Bloquée par

- Phase 7

---

## Phase 10 : Studio — collections, modèles, coloris, besoin

**User stories** : US-36, US-37, US-38, US-39, US-40, US-43

### Ce qu'on livre

Un Éditeur crée une collection, puis des modèles typés (vêtement, chaussure, maroquinerie, accessoire). Il associe des matières par rôle (liste par type de produit, complétable) et décline le modèle en coloris. Il saisit la consommation par pièce, les quantités par coloris et la marge de perte, et voit le besoin total par matière.

### Critères d'acceptation

- [ ] Les rôles proposés changent selon le type de produit (par exemple tige, doublure, semelle pour une chaussure), et l'atelier peut en ajouter.
- [ ] Un modèle à un seul coloris n'affiche pas de déclinaisons. Les onglets de coloris apparaissent dès le deuxième.
- [ ] Besoin = consommation × quantité × (1 + marge), avec une marge de 8 % par défaut modifiable par modèle. Les valeurs sont recalculées instantanément.
- [ ] Une collection vide ou un modèle sans matière affiche l'action suivante à faire.
- [ ] Le Lecteur consulte le Studio sans pouvoir le modifier.

## Bloquée par

- Phase 3

---

## Phase 11 : Alertes du Studio et notifications

**User stories** : US-41, US-42

### Ce qu'on livre

Des règles déterministes signalent les problèmes d'entretien, de technique, de certifications et de stock sur chaque modèle et coloris, avec leur explication. Une cloche dans l'app prévient quand une matière d'un modèle en cours passe en stock faible ou en rupture, ou que sa fiche est modifiée ou retirée par le fournisseur.

### Critères d'acceptation

- [ ] Chaque alerte cite les valeurs en cause, par exemple « Doublure : nettoyage à sec uniquement (P). Principal : lavage 30 °C ».
- [ ] Le même modèle donne toujours les mêmes alertes, et les règles sont couvertes par des tests unitaires (repris de l'ancienne app et étendus).
- [ ] L'alerte de stock compare le besoin au stock atelier puis au stock fournisseur, selon les paliers ou la quantité exacte.
- [ ] La notification de rupture apparaît moins de 2 h après le passage en rupture chez le fournisseur (critère de succès 8).
- [ ] La cloche affiche le nombre de notifications non lues, et chaque notification ouvre le modèle ou la fiche concernés.

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
- [ ] La langue du PDF se choisit à l'export, indépendamment de la langue de l'interface.
- [ ] Le PDF n'inclut ni prix ni notes internes.
- [ ] Aperçu, impression et partage du fichier fonctionnent sur iOS, Android et Web.

## Bloquée par

- Phase 10

---

## Phase 13 : Lien partagé public

**User stories** : US-46, US-47, US-48

### Ce qu'on livre

Un Éditeur crée un lien en lecture seule vers une fiche, un modèle ou une collection, valable 30 jours par défaut et révocable. Le façonnier l'ouvre sur son téléphone sans compte et voit des fiches à jour. Le QR code du PDF pointe vers ce lien.

### Critères d'acceptation

- [ ] Le lien s'ouvre sur un téléphone sans compte (critère de succès 7), dans la langue choisie à la création.
- [ ] La page n'affiche jamais les prix, les notes ni le stock atelier, et le serveur ne renvoie pas ces champs (test).
- [ ] Un lien expiré ou révoqué affiche une page qui l'explique.
- [ ] La liste des liens actifs permet de modifier l'expiration et de révoquer un lien.
- [ ] Le QR code du dossier PDF ouvre le lien correspondant.

## Bloquée par

- Phase 12

---

## Phase 14 : Console super-admin — offres et usage

**User stories** : US-2

### Ce qu'on livre

Une section `/admin`, visible uniquement par le super-admin sur le Web : liste des organisations, offre et quota de scans de chacune, usage du mois (scans, membres, références) et coût estimé de l'IA.

### Critères d'acceptation

- [ ] La console est inaccessible à tout compte non super-admin, et l'appel serveur est refusé (test).
- [ ] Changer l'offre ou le quota d'une organisation s'applique immédiatement au scanner.
- [ ] Le coût de l'IA par organisation et par mois est calculé à partir des tokens consommés.

## Bloquée par

- Phase 6
