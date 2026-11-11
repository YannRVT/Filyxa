# Filyxa

Textile Intelligence Platform : relie les ateliers et marques de mode à leurs fournisseurs autour
d'une base de matières fiable et à jour. Application Flutter (iOS, Android, Web) adossée à Supabase.

- Cadrage produit : [`docs/PRD.md`](docs/PRD.md)
- Design system : [`docs/DESIGN.md`](docs/DESIGN.md)
- Plan de livraison : [`docs/PLAN.md`](docs/PLAN.md)

## Architecture

```
lib/
  app/        thème, routeur (go_router), navigation adaptative, langue
  core/       configuration, client Supabase
  features/
    auth/     connexion, invitation par code, mot de passe oublié
    session/  profil et organisation de l'utilisateur connecté
    account/  mon compte (langue, déconnexion)
    admin/    console super-admin (ateliers pilotes)
  l10n/       traductions : fr, en, it, es, pt, ro
  shared/     widgets communs
supabase/
  migrations/ schéma et règles d'accès
  functions/admin-users/  organisations et invitations (droits d'administration côté serveur)
  templates/  e-mails avec code à 6 chiffres
  tests/      tests pgTAP des règles d'accès
```

## Mise en route

Prérequis : Flutter 3.47+, [Supabase CLI](https://supabase.com/docs/guides/cli), Docker (pour Supabase en local), Deno.

### Démarrage rapide (local)

```sh
FLUTTER=/chemin/vers/flutter/bin/flutter ./scripts/dev.sh   # ou ./scripts/dev.sh si flutter est dans le PATH
```

Le script démarre Supabase si besoin, crée les comptes de démonstration, écrit `env.json`, lance la
fonction `admin-users` et ouvre l'app dans Chrome. Sur l'écran de connexion, **Connexion rapide (dev)**
connecte directement Claire. `--reset` repart d'une base vierge, `-d <appareil>` change de cible.

| Compte (mot de passe `Filyxa2027`) | Rôle |
|---|---|
| `claire@filyxa.local` | Admin de « Atelier Démo » |
| `lea@filyxa.local` | Lectrice de « Atelier Démo » |
| `super@filyxa.local` | Super-admin (console de création d'ateliers) |

### 1. Supabase en local

```sh
supabase start          # démarre Postgres, Auth, Storage, Inbucket (e-mails de test)
supabase db reset       # applique les migrations
supabase functions serve admin-users
```

Les e-mails envoyés en local sont visibles dans Inbucket (`http://127.0.0.1:54524`).

### 2. Supabase hébergé (projet dans l'Union européenne)

Créez le projet dans une région UE (Paris ou Francfort), puis :

```sh
supabase link --project-ref <ref-du-projet>
supabase db push
supabase functions deploy admin-users
supabase functions deploy analyze-tag
```

Dans le tableau de bord, rubrique **Authentication** :

1. **Sign In / Providers** : désactivez *Allow new users to sign up* (accès sur invitation uniquement).
2. **Policies / Password** : longueur minimale **8**, exigence *lettres et chiffres*.
3. **Providers › Email** : *Email OTP Expiration* à **86400** secondes (24 h, le maximum). L'invitation
   elle-même vaut 48 h : l'écran d'invitation permet de redemander un code.
4. **Emails › Templates** : collez le contenu de `supabase/templates/invite.html` (*Invite user*),
   `code.html` (*Magic Link*) et `recovery.html` (*Reset Password*). Chacun affiche le code
   `{{ .Token }}`, sans lien à ouvrir.
5. **Emails › SMTP** : configurez un serveur SMTP de production (le service intégré de Supabase est
   limité à quelques e-mails par heure).

### Scanner (IA)

L'Edge Function `analyze-tag` lit les étiquettes avec Claude Opus 5.5 (effort `low`, sortie JSON
structurée, repli serveur en cas de refus). La clé ne quitte jamais le serveur :

```sh
supabase secrets set ANTHROPIC_API_KEY=sk-ant-...
supabase secrets set CLAUDE_FAST=true          # facultatif : mode rapide (facturé le double)
supabase functions deploy analyze-tag
```

En local, placez `ANTHROPIC_API_KEY=...` dans `supabase/functions/.env` (non versionné). Sans clé,
`./scripts/dev.sh` lance le scanner en **mode démonstration** (`ANALYZE_TAG_MOCK=true`) : réponse
fixe, aucun appel ni coût. Chaque scan est compté sur le quota mensuel de l'atelier
(`organizations.scan_quota`, 300 par défaut).

**Banc d'essai** (critères : 9 scans sur 10 en moins de 7 s, au moins 90 % des champs justes) :

```sh
deno run -A tools/label-eval/eval.ts --init ~/etiquettes   # puis compléter les .truth.json
ANTHROPIC_API_KEY=sk-ant-... deno run -A tools/label-eval/eval.ts ~/etiquettes
```

### 3. Premier super-admin

Créez votre compte dans *Authentication › Users › Add user* (cochez *Auto Confirm User*), puis dans
l'éditeur SQL :

```sql
update public.profiles set is_superadmin = true where email = 'vous@exemple.fr';
```

Le super-admin crée ensuite les ateliers pilotes et invite leur premier admin depuis l'app
(*Compte › Console super-admin*).

### 4. Application

```sh
cp env.example.json env.json   # URL du projet et clé publique (publishable/anon)
flutter pub get
flutter run --dart-define-from-file=env.json            # appareil par défaut
flutter run -d chrome --dart-define-from-file=env.json  # Web
```

**Connexion rapide** : renseignez `DEV_EMAIL` et `DEV_PASSWORD` dans `env.json` pour afficher un
bouton sur l'écran de connexion. Il n'existe qu'en mode debug.

## Tests

```sh
flutter analyze
flutter test                                        # règles, redirections, langues, navigation
deno test supabase/functions/admin-users/           # règles de la fonction admin-users
supabase test db                                    # règles d'accès (Supabase local démarré)
```
