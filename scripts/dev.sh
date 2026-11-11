#!/usr/bin/env bash
# Lance Filyxa en local en une commande :
#   ./scripts/dev.sh            démarre Supabase si besoin, la fonction admin-users et l'app (Chrome)
#   ./scripts/dev.sh --reset    repart d'une base vide avec les comptes de démonstration
#   ./scripts/dev.sh -d macos   autre appareil Flutter (ex. un simulateur iOS : -d "iPhone 16")
#
# Comptes de démonstration (mot de passe Filyxa2027) : claire@filyxa.local (Admin),
# lea@filyxa.local (Lectrice), super@filyxa.local (super-admin).
# Le bouton « Connexion rapide (dev) » connecte directement Claire.
# E-mails de test (codes à 6 chiffres) : voir la ligne « E-mails » au démarrage.
#
# Flutter doit être dans le PATH, ou indiqué par la variable FLUTTER.
set -euo pipefail
cd "$(dirname "$0")/.."

FLUTTER="${FLUTTER:-flutter}"
DEVICE="chrome"
RESET=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --reset) RESET=1 ;;
    -d) DEVICE="$2"; shift ;;
    *) echo "Option inconnue : $1" >&2; exit 1 ;;
  esac
  shift
done

if ! command -v "$FLUTTER" >/dev/null 2>&1; then
  echo "Flutter introuvable. Ajoutez-le au PATH ou lancez : FLUTTER=/chemin/vers/flutter/bin/flutter $0" >&2
  exit 1
fi

if ! supabase status >/dev/null 2>&1; then
  echo "▸ Démarrage de Supabase…"
  supabase start >/dev/null
  RESET=1
fi
if [[ $RESET -eq 1 ]]; then
  echo "▸ Base remise à zéro avec les comptes de démonstration…"
  supabase db reset >/dev/null
  # Après un reset, la passerelle locale ne sert plus les modèles d'e-mail
  # (les codes à 6 chiffres disparaissent) : on la redémarre.
  docker restart supabase_kong_filyxa >/dev/null
  # Attend que les modèles d'e-mail soient de nouveau servis (60 s maximum).
  for _ in $(seq 1 30); do
    docker exec supabase_auth_filyxa wget -qO- http://supabase_kong_filyxa:8088/email/invite.html >/dev/null 2>&1 && break
    sleep 2
  done
fi

eval "$(supabase status -o env 2>/dev/null | grep -E '^(API_URL|PUBLISHABLE_KEY|INBUCKET_URL)=')"

cat > env.json <<JSON
{
  "SUPABASE_URL": "${API_URL}",
  "SUPABASE_ANON_KEY": "${PUBLISHABLE_KEY}",
  "DEV_EMAIL": "claire@filyxa.local",
  "DEV_PASSWORD": "Filyxa2027"
}
JSON

# Fonctions serveur (admin-users, analyze-tag). Sans clé Claude dans
# supabase/functions/.env, le scanner tourne en mode démonstration (aucun appel à l'IA).
ENV_FILE="supabase/functions/.env"
if ! grep -q '^ANTHROPIC_API_KEY=.' "$ENV_FILE" 2>/dev/null; then
  ENV_FILE="$(mktemp -t filyxa-env)"
  echo "ANALYZE_TAG_MOCK=true" >"$ENV_FILE"
  echo "▸ Scanner en mode démonstration (aucune clé ANTHROPIC_API_KEY dans supabase/functions/.env)"
fi
LOG="$(mktemp -t filyxa-functions)"
supabase functions serve --env-file "$ENV_FILE" >"$LOG" 2>&1 &
FUNCTIONS_PID=$!
trap 'kill $FUNCTIONS_PID 2>/dev/null || true' EXIT

echo "▸ API      ${API_URL}"
echo "▸ E-mails  ${INBUCKET_URL}"
echo "▸ Logs des fonctions : ${LOG}"
echo "▸ Lancement de l'app (${DEVICE})… « r » recharge, « R » redémarre, « q » quitte."
"$FLUTTER" run -d "$DEVICE" --dart-define-from-file=env.json
