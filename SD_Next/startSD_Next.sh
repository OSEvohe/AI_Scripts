#!/bin/bash

# Arrêter le script si une commande échoue
set -e

# Dossier de base par défaut
BASE_DIR="/automatic"

# Parse les arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --base-dir)
      BASE_DIR="$2"
      shift
      ;;
    *)
      echo "Option inconnue: $1"
      exit 1
      ;;
  esac
  shift
done

# Fichier pour vérifier si le script a déjà été exécuté
FLAG_FILE="/tmp/first_time_flag"

# Vérifier si c'est la première fois que le script est lancé
if [ ! -f "$FLAG_FILE" ]; then
  
  # Vérifier si le dossier spécifié existe
  if [ -d "$BASE_DIR" ]; then
    # Supprimer le contenu du dossier spécifié
    rm -rf "$BASE_DIR"/*
  fi
  
  # Cloner le repository dans le dossier spécifié
  git clone https://github.com/vladmandic/automatic.git "$BASE_DIR"
  
  # Se placer dans le dossier spécifié
  cd "$BASE_DIR"
  
  # Lancer la commande avec l'option --test
  ./webui.sh --listen --insecure --port 8080 -f --test

  # Télécharger le fichier config.json et le copier dans le dossier où automatic a été cloné
  curl -o "${BASE_DIR}/config.json" https://raw.githubusercontent.com/OSEvohe/AI_Scripts/main/SD_Next/config.json

  # Activer l'environnement virtuel
  source ./venv/bin/activate

  # Cloner le repository dans un sous-dossier de ./extensions
  git clone https://github.com/zanllp/sd-webui-infinite-image-browsing ./extensions/sd-webui-infinite-image-browsing

  # Exécuter le fichier install.py
  python ./extensions/sd-webui-infinite-image-browsing/install.py

  deactivate

  # Créer un fichier pour indiquer que le script a été lancé
  touch "$FLAG_FILE"
fi

# Se placer dans le dossier spécifié
cd "$BASE_DIR"

# Lancer la commande pour la mise à jour
./webui.sh --upgrade --listen --insecure --port 8080