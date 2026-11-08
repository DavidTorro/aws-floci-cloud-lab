# Ejecuciones del workflow Web

Ejecuciones reales de `.github/workflows/web.yml` en `main` el 8 de noviembre de 2026.

| Fase | Commit | Ejecución | 1. Prueba en Floci | 2. Despliegue en AWS |
| --- | --- | --- | --- | --- |
| 3. Primera versión (merge de la PR #5) | `344908a` | [Web #1](https://github.com/DavidTorro/aws-iam-governance-lab/actions/runs/42516989560) | ✅ success | ✅ success (intento 3) |
| 4.1 Añado mi nombre | `0afed6c` | [Web #2](https://github.com/DavidTorro/aws-iam-governance-lab/actions/runs/42517612497) | ✅ success | ✅ success |
| 4.2 Error a propósito | `2144944` | [Web #3](https://github.com/DavidTorro/aws-iam-governance-lab/actions/runs/42517814371) | ❌ failure | ⏭️ skipped |
| 4.2 Revert | `02c17f6` | [Web #4](https://github.com/DavidTorro/aws-iam-governance-lab/actions/runs/42517932022) | ✅ success | ✅ success |

## Detalles

- **Web #1, intentos 1 y 2**: el despliegue en AWS falló con `AccessDenied … explicit deny in an identity-based policy … policy/voc-cancel-cred`. El laboratorio de Learner Lab estaba parado y esa política deniega todas las acciones. Tras pulsar *Start Lab* y actualizar el secret `AWS_CREDENTIALS`, el intento 3 terminó en verde con `Apply complete! Resources: 0 added, 1 changed, 0 destroyed.`, porque reutilizó el estado remoto creado en la Fase 2.
- **Web #3**: la prueba en Floci se detuvo en el `plan` con `La web no tiene portada: falta index.html.`. El trabajo de AWS quedó en `skipped` y la web pública siguió respondiendo 200 con el nombre del commit anterior.
- **CI #13**, sobre el mismo commit `2144944`: el trabajo *Validar Terraform* también falló, porque los tests del módulo comprueban la carpeta `web/` real.
