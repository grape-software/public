#!/bin/bash
# Script para agregar el workflow agnostic a un nuevo proyecto .NET
target_repo_path="$1"

if [ -z "$target_repo_path" ]; then
  echo "Uso: $0 <ruta_al_nuevo_repo>"
  exit 1
fi

workflow_dir="$target_repo_path/.github/workflows"
mkdir -p "$workflow_dir"
cp "$(dirname "$0")/agnostic_workflow.yml" "$workflow_dir/agnostic_workflow.yml"
echo "Workflow agnostic_workflow.yml copiado a $workflow_dir"

# Copiar Dockerfile estándar desde grape-software/ReusableWorkflow si existe en public/init-repos
DOCKERFILE_SRC="$(dirname "$0")/Dockerfile"
DOCKERFILE_DEST="$target_repo_path/Dockerfile"
if [ -f "$DOCKERFILE_SRC" ]; then
  cp "$DOCKERFILE_SRC" "$DOCKERFILE_DEST"
  echo "Dockerfile estándar copiado a $DOCKERFILE_DEST"
else
  echo "No se encontró Dockerfile estándar en $DOCKERFILE_SRC. Por favor, cópielo manualmente si es necesario."
fi
