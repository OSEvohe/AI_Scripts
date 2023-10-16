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
    rm -rf "$BASE_DIR"
  fi
  
  # Cloner le repository dans le dossier spécifié
  git clone https://github.com/vladmandic/automatic.git "$BASE_DIR"
  
  # Se placer dans le dossier spécifié
  cd "$BASE_DIR"

  # Autoriser le compte root
  echo "can_run_as_root=1" >> "$BASE_DIR"/webui-user.sh  
  
  # Lancer la commande avec l'option --test
  ./webui.sh --listen --insecure --port 8080 -f --test

   # Créer un fichier pour indiquer que le script a été lancé
  touch "$FLAG_FILE"

  # Télécharger le fichier config.json et le copier dans le dossier où automatic a été cloné
  curl -o "${BASE_DIR}/config.json" https://raw.githubusercontent.com/OSEvohe/AI_Scripts/main/SD_Next/config.json

  # Utiliser trap pour désactiver l'environnement virtuel en cas d'erreur
  trap '[[ $VIRTUAL_ENV ]] && deactivate' EXIT

  # Cloner le repository dans un sous-dossier de ./extensions
  git clone https://github.com/zanllp/sd-webui-infinite-image-browsing ./extensions/sd-webui-infinite-image-browsing
  git clone https://github.com/AbdullahAlfaraj/Auto-Photoshop-StableDiffusion-Plugin.git ./extensions/Auto-Photoshop-StableDiffusion-Plugin
  git clone https://github.com/Coyote-A/ultimate-upscale-for-automatic1111.git ./extensions/ultimate-upscale-for-automatic1111
  
  # Vérifier si le dossier 'models' existe, sinon le créer
  if [ ! -d "./models" ]; then
    mkdir -p ./models
  fi

  # Utiliser curl avec l'option -L pour suivre les redirections et télécharger les fichiers modèles
  curl -L -o ./models/Stable-diffusion/realisticVisionV51_v51VAE.safetensors "https://civitai.com/api/download/models/130072?type=Model&format=SafeTensor&size=pruned&fp=fp16"
  curl -L -o ./models/VAE/vae-ft-ema-560000-ema-pruned.safetensors https://huggingface.co/stabilityai/sd-vae-ft-ema-original/resolve/main/vae-ft-ema-560000-ema-pruned.safetensors

fi

# Se placer dans le dossier spécifié
cd "$BASE_DIR"

# Lancer la commande pour la mise à jour
./webui.sh --upgrade --listen --insecure --port 8080 -f
