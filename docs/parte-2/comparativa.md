# Comparativa Floci frente a AWS real

| | Floci | AWS real |
| --- | --- | --- |
| **¿Desde dónde se puede ver la web?** | Solo desde el PC que ejecuta Floci: `http://nextgen.s3-website-us-east-1.localhost:4566/`. En el móvil no carga, porque `localhost` es el propio dispositivo. | Desde cualquier dispositivo con Internet: `http://nextgen-david-torro.s3-website-us-east-1.amazonaws.com/`. |
| **¿Se puede usar el nombre `nextgen`?** | Sí. El emulador es una nube privada de una sola cuenta y nadie más usa ese nombre. | No. `BucketAlreadyExists`: el espacio de nombres de S3 es global y otra cuenta ya tiene `nextgen`. |
| **¿Se puede leer la web sin dar permiso público?** | Sí. Responde 200 con `public_read = false` y todo el acceso público bloqueado: Floci no aplica esa restricción. | No. Responde 403 hasta que se permite la política pública y se añade `LecturaPublica`. |
| **¿Qué credenciales se usan?** | Ficticias (`test` / `test`), fijadas en `envs/web-floci/providers.tf`. | Temporales de Learner Lab (clave, secreto y token de sesión, unas 4 horas): en `~/.aws/credentials` en el PC y en el secret `AWS_CREDENTIALS` en GitHub Actions. |
| **¿Qué cambia en `deploy.sh` para usarlo aquí?** | Nada del código. Se ejecuta `bash scripts/web-deploy.sh floci`, que usa `envs/web-floci`: endpoint `localhost:4566`, credenciales de prueba y estado local. | Nada del código. Se ejecuta `bash scripts/web-deploy.sh aws`, que usa `envs/web-aws`: sin endpoint (AWS por defecto), credenciales reales y estado remoto en S3. |

El módulo `modules/s3-website`, la web y `config/web.tfvars` son idénticos en los dos destinos. Solo cambian tres cosas: el endpoint, las credenciales y el lugar donde se guarda el estado. Es el equivalente de las dos variables del kit, `AWS_ENDPOINT_URL` y las credenciales, más el estado, que Terraform necesita.
