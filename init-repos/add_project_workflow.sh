#!/bin/bash
# Script para agregar el workflow agnostic y el Dockerfile estándar a un nuevo proyecto .NET o el workflow dev_web_Server.yml a un nuevo proyecto Angular

target_repo_path="$1"
project_type="$2" # "dotnet" o "angular"

if [ -z "$target_repo_path" ] || [ -z "$project_type" ]; then
  echo "Uso: $0 <ruta_al_nuevo_repo> <dotnet|angular>"
  exit 1
fi

workflow_dir="$target_repo_path/.github/workflows"
mkdir -p "$workflow_dir"

if [ "$project_type" = "dotnet" ]; then
  cp "$(dirname "$0")/agnostic_workflow.yml" "$workflow_dir/agnostic_workflow.yml"
  echo "Workflow agnostic_workflow.yml copiado a $workflow_dir"
  # Copiar Dockerfile estándar si existe
  DOCKERFILE_SRC="$(dirname "$0")/Dockerfile"
  DOCKERFILE_DEST="$target_repo_path/Dockerfile"
  if [ -f "$DOCKERFILE_SRC" ]; then
    cp "$DOCKERFILE_SRC" "$DOCKERFILE_DEST"
    echo "Dockerfile estándar copiado a $DOCKERFILE_DEST"
  else
    echo "No se encontró Dockerfile estándar en $DOCKERFILE_SRC. Por favor, cópielo manualmente si es necesario."
  fi
elif [ "$project_type" = "angular" ]; then
  cp "$(dirname "$0")/dev_web_Server.yml" "$workflow_dir/dev_web_Server.yml"
  echo "Workflow dev_web_Server.yml copiado a $workflow_dir"
else
  echo "Tipo de proyecto no reconocido. Usa 'dotnet' o 'angular'."
  exit 1
fi
