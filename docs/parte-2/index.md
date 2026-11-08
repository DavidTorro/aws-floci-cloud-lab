# Parte 2: de local a la nube

NextGen Solutions quiere publicar su web sin riesgos: cada cambio se prueba primero en Floci y solo llega a AWS si la prueba pasa. El profesorado entregó un kit con la web, un `deploy.sh` en bash basado en la AWS CLI y un workflow de GitHub Actions. En este repositorio, el despliegue se ha llevado a Terraform para seguir el mismo enfoque que la Parte 1: un módulo reutilizable y un entorno por destino.

## Arquitectura

```text
 Tu PC                       GitHub Actions                        AWS real
┌──────────────────┐ push  ┌───────────────────────────┐        ┌────────────────────┐
│ web-deploy.sh    │──────▶│ 1. Prueba en Floci        │        │ Bucket S3          │
│ floci            │       │    Floci limpio en el     │        │ modo sitio web     │
│ localhost:4566   │       │    runner                 │        │ URL pública        │
└──────────────────┘       │            │ solo si pasa │        └────────────────────┘
                           │            ▼              │                  ▲
                           │ 2. Despliegue en AWS      │──────────────────┘
                           │    secret AWS_CREDENTIALS │
                           └───────────────────────────┘
          El mismo módulo modules/s3-website en los tres sitios
```

| Pieza | Equivalente en el kit | Función |
| --- | --- | --- |
| `web/` | `web/` | La web, sin cambios salvo el nombre del pie |
| `config/web.tfvars` | `config.sh` | `bucket_name` y `public_read`; es lo único que se configura |
| `modules/s3-website/` | Pasos 2 a 4 de `deploy.sh` | Modo sitio web, bloqueo de acceso público, política de lectura pública y archivos |
| `envs/web-floci/` | `usar-floci.sh` | Endpoint `localhost:4566`, credenciales `test` y estado local |
| `envs/web-aws/` | `usar-aws.sh` | AWS real, credenciales de Learner Lab y estado remoto en S3 |
| `scripts/web-deploy.sh` | `deploy.sh` | Crea el bucket, aplica Terraform y comprueba que la web responde 200 |
| `.github/workflows/web.yml` | `.github/workflows/deploy.yml` | Prueba en Floci y, solo si pasa, despliegue en AWS |

```bash
bash scripts/web-deploy.sh floci          # Fase 1
bash scripts/web-deploy.sh aws            # Fase 2
bash scripts/web-deploy.sh aws destroy    # Limpieza
```

## Decisiones de diseño

**Un módulo, dos entornos.** El módulo no sabe dónde se despliega. `envs/web-floci` y `envs/web-aws` solo difieren en el proveedor (endpoint y credenciales) y en el lugar donde se guarda el estado. Así se mantiene la idea del enunciado: el mismo código en los tres sitios.

**Estado remoto en AWS.** Cada ejecución de GitHub Actions arranca en un equipo limpio. Con un estado local, el segundo despliegue no sabría que la web ya existe e intentaría crearla de nuevo. `envs/web-aws` guarda el estado en un bucket `nextgen-tfstate-<cuenta>`, con versionado y bloqueo mediante `use_lockfile`; el script lo crea la primera vez. En Floci el estado local es correcto: interesa partir siempre de un entorno vacío.

**Validación antes de desplegar.** El módulo exige un nombre de bucket válido y que existan `index.html` y `error.html`. Una web sin portada se detiene en el `plan`, antes de tocar ningún recurso.

**El bucket lo crea el script.** En Learner Lab, una política de control de servicio (SCP) de la organización deniega `s3:GetBucketObjectLockConfiguration`. El recurso `aws_s3_bucket` del proveedor de Terraform lee siempre esa configuración después de crear el bucket, y en AWS real trata la denegación como un error fatal. El primer intento dejó el bucket creado pero marcado como *tainted* ([evidencia](https://github.com/DavidTorro/aws-iam-governance-lab/blob/main/evidence/parte2/2b-learner-lab-object-lock.txt)). Se comprobaron las demás lecturas del bucket y solo esa estaba denegada. Por eso `web-deploy.sh` crea el bucket con la AWS CLI, como el paso 1/4 del kit, y Terraform gestiona todo lo que va dentro.

## Contenido

| Página | Contenido |
| --- | --- |
| [Fases](fases.md) | Ejecución de las fases 1 a 4 con sus resultados y capturas |
| [Comparativa](comparativa.md) | Tabla Floci frente a AWS real |
| [Preguntas](preguntas.md) | Límites del emulador, valor de CI/CD y gestión de secretos |
