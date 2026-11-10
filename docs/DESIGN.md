# Design System — Filyxa

## Product Context
- **Quoi** : plateforme qui relie les ateliers et marques de mode à leurs fournisseurs autour d'une base de matières fiable. Elle comprend la bibliothèque TissuTech, le scan d'étiquettes d'échantillons, le Studio (collections, modèles, coloris) et l'export du dossier matières.
- **Pour qui** : responsables matières, stylistes et modélistes d'ateliers de 5 à 15 personnes (utilisateurs principaux) ; commerciaux de fournisseurs textiles (utilisateurs secondaires) ; façonniers, qui consultent un lien partagé.
- **Espace** : logiciels de gestion de collection mode (PLM) et bibliothèques de matières numériques. Références : Centric, Backbone, Swatchbook, Frontier.
- **Type** : web app / dashboard (iOS, Android, Web).
- **Memorable thing** : « Le tissu à portée d'aiguille. »

## Aesthetic Direction
- **Direction** : Utilitaire raffiné (Industrial/Utilitarian adouci). Précision de labo textile, calme de showroom.
- **Décoration** : intentionnelle. L'interface reste quasi monochrome (pétrole et nuage). La couleur vient des photos de matières. Un seul motif : le **point de couture**, un trait en pointillés émeraude réservé à quatre usages (page active de la navigation, contour de l'élément sélectionné au clavier, zone de dépôt d'import, cadre du scanner).
- **Mood** : la matière est la seule chose vive à l'écran, et la donnée technique est lisible comme sur une étiquette de rouleau. Sérieux, précis, jamais froid.
- **Principes signature** :
  - **La matière d'abord** : la photo du tissu, ou à défaut un aplat de la couleur du coloris, est l'élément le plus coloré de chaque vignette et de chaque fiche.
  - **Police d'étiquette technique** : codes article, compositions et valeurs mesurées en monospace, identiques dans l'app, le PDF et le lien partagé.
- **Références** :
  - https://www.onbrandplm.com/blog/best-apparel-plm-software
  - https://www.lectra.com/en/library/what-is-the-best-plm-software-for-fashion-brands-in-2026
  - https://blog.waveplm.com/building-smarter-collections-with-a-fashion-materials-library/
  - https://www.textileworld.com/textile-world/knitting-apparel/2019/04/esmetex-launches-game-changing-frontier-digital-platform-for-fabrics/
  - https://apps.apple.com/us/app/swatchbook/id1289003065
  - https://www.saasframe.io/blog/the-anatomy-of-high-performance-saas-dashboard-design-2026-trends-patterns
  - https://925studios.co/blog/saas-dashboard-design-examples-2026

## Typography
- **Display/Hero** : Montserrat 600/700. C'est la police imposée par la charte Filyxa, réservée aux titres, aux chiffres clés et au logo. Jamais en texte courant.
- **Body** : Source Sans 3 400/500/600/700. Elle reste très lisible en petite taille dans les tableaux et formulaires denses, et couvre les six langues, y compris les signes roumains ș ț.
- **Data/Tables** : Source Sans 3 avec `tabular-nums` pour les nombres en colonne, et IBM Plex Mono 400/500 pour les codes article, les compositions (« 62 % WO · 38 % PES ») et les libellés techniques.
- **Code** : IBM Plex Mono.
- **Loading** : `https://fonts.googleapis.com/css2?family=Montserrat:wght@600;700&family=Source+Sans+3:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500&display=swap`. Dans l'app, ces polices sont embarquées pour fonctionner hors connexion et dans les PDF.
- **Scale** : 12 / 13 / 14 / 15 (texte de base) / 16 / 20 / 24 / 32 / 48 / 64 px.

## Color
- **Approche** : balanced.
- **Primary** : `#064E49` vert pétrole. Barre latérale, titres, bouton principal (texte blanc 9,6:1), éléments forts.
- **Secondary** : `#0D9488` émeraude. Graphismes, icônes actives, point de couture, indicateurs. **Jamais pour du texte** (3,7:1 sur blanc).
  - `#0F766E` émeraude texte : liens, focus, texte interactif (5,5:1 sur blanc, 5,1:1 sur nuage).
  - `#A5E5D9` menthe : accents sur fond sombre (6,8:1 sur pétrole), avatars.
  - `#E3F4F0` menthe pâle : fond du bouton secondaire et des fonds doux.
- **Neutrals** : `#FFFFFF` blanc (cartes) → `#F1F7F6` nuage (fond) → `#D9E6E3` trait (bordures) → `#B9CCC8` trait fort (bordures de champ) → `#556B68` encre douce (texte secondaire, 5,3:1 sur nuage) → `#1B2B29` encre (texte, 13,6:1 sur nuage).
- **Semantic** : success `#0F766E` (fond `#E3F4F0`), warning `#B45309` ambre (fond `#FDF1E4`), error `#B42318` garance (fond `#FDECEA`), info `#1D6FA3` indigo (fond `#E7F1F8`).
- **Disponibilité** (pastilles, constantes dans toute l'app) : Disponible `#0F766E` · Stock faible `#B45309` · Sur commande `#5B6B7A` ardoise (avec le délai en semaines) · Rupture `#B42318`.
- **Dark mode** : fond pétrole très profond `#0B2421`, surfaces `#10302C`, texte `#E6F2EF` (14,2:1), texte secondaire `#9FB3AF` (7,4:1), liens et focus `#5FD3C0` (9,0:1). Les couleurs sémantiques sont éclaircies d'un cran. Les photos de matières restent inchangées.

## Spacing
- **Base** : 8 px, avec un demi-pas de 4 px.
- **Densité** : confortable dans le Studio et les fiches, compacte dans les tableaux (lignes de 48 px, en-tête collant).
- **Scale** : 2xs(2) xs(4) sm(8) md(16) lg(24) xl(32) 2xl(48) 3xl(64).

## Layout
- **Approche** : grid-disciplined.
- **Grid** : téléphone 4 colonnes (gouttière latérale 16 px, onglets en bas avec le bouton Scanner central) · tablette 8 colonnes (barre latérale réduite aux icônes) · ordinateur 12 colonnes à partir de 1024 px (barre latérale pétrole de 232 px).
- **Max content width** : 1440 px pour les écrans de données, 720 px pour les formulaires et les fiches.
- **Border radius** : sm:6px (champs, pastilles carrées), md:10px (boutons, vignettes), lg:12px (cartes, panneaux), full:9999px (pastilles de statut, filtres, avatar).

## Motion
- **Approche** : minimal-fonctionnel. Les transitions servent uniquement à comprendre : arrivée du résultat de scan, changement de statut, ouverture d'un panneau.
- **Easing** : enter(ease-out) exit(ease-in) move(ease-in-out).
- **Duration** : micro(50-100ms) court(150-250ms) moyen(250-400ms) long(400-700ms). Le long est réservé à la transition photo vers fiche pré-remplie du scanner. L'option « réduire les animations » du système est respectée.

## Decisions Log
| Date | Décision | Rationale |
|------|----------|-----------|
| 2026-11-10 | Création initiale | /design — SaaS B2B matières pour ateliers et fournisseurs. Charte Filyxa imposée (pétrole, émeraude, menthe, nuage, Montserrat). Direction utilitaire raffinée, la matière d'abord, données en monospace, point de couture comme seul ornement. |
| 2026-11-10 | Montserrat limitée aux titres | Police de la charte, mais trop large et peu lisible en petit. Le texte courant passe en Source Sans 3. |
| 2026-11-10 | Ajout de l'émeraude texte `#0F766E` | L'émeraude de la charte `#0D9488` n'atteint pas le contraste AA pour du texte (3,7:1). |
