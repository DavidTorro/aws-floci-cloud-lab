# AWS IAM Governance Lab

Memoria de las dos partes de la práctica de NextGen Solutions, resueltas con Terraform:

- **Parte 1 · IAM**: estructura de identidades desplegada en Floci. Seis usuarios y tres grupos; los permisos se heredan exclusivamente por pertenencia a grupos. Las decisiones se han comprobado con `simulate-principal-policy`.
- **Parte 2 · Despliegue**: la web de la empresa se publica en un bucket S3. Cada cambio se prueba primero en Floci y GitHub Actions solo lo despliega en AWS (Learner Lab) si la prueba pasa.

## Resultado

**Parte 1.** El simulador confirmó los permisos previstos para `roberto`, `alicia`, `marta` y `camila`. En particular, `alicia` combina la lectura de auditoría con los permisos de desarrollo, pero `s3:DeleteObject` devuelve `explicitDeny`. Tras parar y reiniciar Floci sin persistencia, la lista de usuarios pasó de seis identidades a cero.

**Parte 2.** El mismo módulo `s3-website` publicó la web en Floci y en AWS. AWS mostró dos diferencias que Floci no detecta: `BucketAlreadyExists` con el nombre `nextgen` y un 403 mientras la web no tenía permiso público. En GitHub Actions, un cambio correcto llegó solo a producción. Un cambio que eliminaba la portada se detuvo en la prueba en Floci, el despliegue no se ejecutó y la web pública siguió funcionando.

## Contenido de la memoria

| Sección | Contenido |
| --- | --- |
| [Entorno Floci](entorno/floci.md) | Preparación, endpoint local y límite del emulador |
| [Flujo de trabajo](entorno/flujo-de-trabajo.md) | Plan y despliegue Terraform, verificación y reinicio |
| [Usuarios y grupos](usuarios-y-grupos.md) | Identidades, pertenencias y ausencia de políticas directas |
| [Dev-Team](politicas/dev-team.md) | Lectura S3, operaciones DynamoDB y denegación de borrado |
| [Ops-Team](politicas/ops-team.md) | Operaciones EC2 y gestión Lambda |
| [SecOps-Team](politicas/secops-team.md) | Consulta para auditoría y protección frente a operaciones destructivas |
| [Auditoría](auditoria/simulador.md) | Resultados reales del simulador IAM |
| [Decisiones](decisiones.md) | Seguridad, gobernanza y ciclo de vida efímero |
| [De local a la nube](parte-2/index.md) | Arquitectura del despliegue y adaptación del kit a Terraform |
| [Fases](parte-2/fases.md) | Floci, AWS, GitHub Actions y el error a propósito, con capturas |
| [Comparativa](parte-2/comparativa.md) | Floci frente a AWS real |
| [Preguntas](parte-2/preguntas.md) | Límites del emulador, valor de CI/CD y gestión de secretos |
| [Conclusiones](conclusiones.md) | Evaluación del diseño y límites |

La infraestructura IAM está en `envs/floci/` y `modules/iam-group/`, con las políticas JSON en `policies/`. La de la web está en `envs/web-floci/`, `envs/web-aws/` y `modules/s3-website/`. Los scripts están en `scripts/` y los datos íntegros obtenidos de Floci y de AWS, en `evidence/`.
