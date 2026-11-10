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

LOG="$(mktemp -t filyxa-functions)"
supabase functions serve admin-users >"$LOG" 2>&1 &
FUNCTIONS_PID=$!
trap 'kill $FUNCTIONS_PID 2>/dev/null || true' EXIT

echo "▸ API      ${API_URL}"
echo "▸ E-mails  ${INBUCKET_URL}"
echo "▸ Logs de la fonction admin-users : ${LOG}"
echo "▸ Lancement de l'app (${DEVICE})… « r » recharge, « R » redémarre, « q » quitte."
"$FLUTTER" run -d "$DEVICE" --dart-define-from-file=env.json
