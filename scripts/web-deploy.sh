#!/usr/bin/env bash
# Publica la web con Terraform y comprueba que responde.
# Es el MISMO módulo en Floci, en GitHub Actions y en AWS: solo cambia el
# entorno (endpoint y credenciales), nunca el código de la web ni el módulo.
#
# Uso: bash scripts/web-deploy.sh floci|aws [destroy]
set -euo pipefail

cd "$(dirname "$0")/.."

DESTINO="${1:-}"
ACCION="${2:-apply}"
CONFIG="$PWD/config/web.tfvars"
INTENTOS="${INTENTOS:-6}"
BUCKET="$(sed -nE 's/^bucket_name *= *"([^"]+)".*/\1/p' "$CONFIG")"

case "$DESTINO" in
  floci)
    echo "== Destino: FLOCI (http://localhost:4566) =="
    ENV_DIR=envs/web-floci
    export AWS_ENDPOINT_URL=http://localhost:4566
    export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test
    unset AWS_SESSION_TOKEN AWS_PROFILE
    ;;
  aws)
    echo "== Destino: AWS REAL (us-east-1) =="
    ENV_DIR=envs/web-aws
    # Si la terminal apuntaba a Floci, la AWS CLI y Terraform irían a localhost.
    unset AWS_ENDPOINT_URL AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
    ;;
  *)
    echo "Uso: bash scripts/web-deploy.sh floci|aws [destroy]" >&2
    exit 2
    ;;
esac
export AWS_DEFAULT_REGION=us-east-1

if [ "$DESTINO" = "aws" ]; then
  # Estado remoto: GitHub Actions arranca cada vez en un equipo limpio.
  CUENTA="$(aws sts get-caller-identity --query Account --output text)"
  STATE_BUCKET="nextgen-tfstate-$CUENTA"
  if ! aws s3api head-bucket --bucket "$STATE_BUCKET" >/dev/null 2>&1; then
    echo "Creando el bucket del estado de Terraform"
    aws s3api create-bucket --bucket "$STATE_BUCKET" >/dev/null
    aws s3api put-bucket-versioning --bucket "$STATE_BUCKET" \
      --versioning-configuration Status=Enabled
  fi
  terraform -chdir="$ENV_DIR" init -input=false -reconfigure \
    -backend-config="bucket=$STATE_BUCKET" >/dev/null
else
  terraform -chdir="$ENV_DIR" init -input=false >/dev/null
fi

if [ "$ACCION" = "destroy" ]; then
  terraform -chdir="$ENV_DIR" destroy -input=false -auto-approve -var-file="$CONFIG"
  echo "Borrando el bucket $BUCKET"
  aws s3 rb "s3://$BUCKET" --force
  exit 0
fi

# El bucket se crea con la AWS CLI: en Learner Lab el recurso aws_s3_bucket
# de Terraform falla (ver modules/s3-website/main.tf).
echo "Bucket: $BUCKET"
if ! aws s3api head-bucket --bucket "$BUCKET" >/dev/null 2>&1; then
  aws s3 mb "s3://$BUCKET"
fi

terraform -chdir="$ENV_DIR" apply -input=false -auto-approve -var-file="$CONFIG"

HOST_WEB="$(terraform -chdir="$ENV_DIR" output -raw website_host)"
URL_PRUEBA="$(terraform -chdir="$ENV_DIR" output -raw check_url)"
URL_WEB="$(terraform -chdir="$ENV_DIR" output -raw website_url)"

echo "Comprobando que la web responde..."
for ((i = 1; i <= INTENTOS; i++)); do
  CODIGO="$(curl -s -o /dev/null -m 10 -w '%{http_code}' -H "Host: $HOST_WEB" "$URL_PRUEBA" || true)"
  [ "$CODIGO" = "200" ] && break
  [ "$i" -lt "$INTENTOS" ] && sleep 5
done

if [ "$CODIGO" != "200" ]; then
  echo "ERROR: la web responde con el código $CODIGO (se esperaba 200)."
  exit 1
fi
echo "OK. Tu web está en: $URL_WEB"
