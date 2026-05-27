#!/bin/bash
set -euo pipefail

usage() {
    cat >&2 <<EOF
usage: $(basename "$0") <repertoire> <extension> [--dry-run]
  Supprime récursivement tous les fichiers d'une extension donnée.
  --dry-run   Affiche les fichiers qui seraient supprimés, sans rien faire.
EOF
    exit 1
}

# --- Vérification des arguments minimaux ---
(( $# >= 2 )) || usage

target="$1"
extension="$2"
shift 2

dry_run=false
for arg in "$@"; do
    [[ "$arg" == "--dry-run" ]] && dry_run=true
done

# --- Validations ---
[[ -d "$target" ]]      || { echo "erreur: '$target' n'est pas un répertoire" >&2; exit 1; }
[[ -n "$extension" ]]   || { echo "erreur: extension vide" >&2; exit 1; }

# --- Recherche et suppression via find ---
found=0
while IFS= read -r -d '' fichier; do
    found=1
    if $dry_run; then
        echo "[dry-run] $fichier"
    else
        rm -- "$fichier" && echo "supprimé: $fichier"
    fi
done < <(find "$target" -type f -name "*.$extension" -print0 | sort -z)

(( found )) || echo "aucun fichier '.$extension' trouvé dans '$target'"