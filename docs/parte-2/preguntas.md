# Preguntas de la entrega

## Los límites del emulador

Los dos errores de la Fase 2 fueron:

```text
make_bucket failed: s3://nextgen An error occurred (BucketAlreadyExists) when calling
the CreateBucket operation: The requested bucket name is not available. The bucket
namespace is shared by all users of the system. Please select a different name and try again.
```

```text
ERROR: la web responde con el código 403 (se esperaba 200).
```

**¿Por qué no aparecieron en Floci?** Floci emula una única cuenta en el PC. No existe un espacio de nombres compartido con otros usuarios, así que `nextgen` estaba libre. Además, Floci no aplica las restricciones de acceso de S3 al servir la web: el bloqueo de acceso público y la ausencia de política no impidieron leerla. En la Parte 1 ya se vio lo mismo con IAM: Floci almacena las políticas, pero no las aplica.

Learner Lab añadió dos diferencias más que Floci tampoco podía mostrar. Una SCP de la organización deniega `s3:GetBucketObjectLockConfiguration`, lo que impide usar el recurso `aws_s3_bucket` de Terraform. Y cuando el laboratorio está parado, la política `voc-cancel-cred` deniega todas las acciones.

**¿Probar en Floci garantiza que funcionará en AWS?** No. Floci reproduce las API, pero no las reglas de la cuenta real: unicidad global de nombres, permisos efectivos, políticas de la organización, caducidad de credenciales y presupuesto.

**¿Para qué sirve, si no lo garantiza?** Para descartar, gratis y sin riesgo, los errores que dependen de nuestro código. En la Fase 4 detectó una web sin portada antes de que llegara a producción. También comprueba que Terraform crea y actualiza los recursos y que la web responde. Cada prueba parte de un entorno vacío, así que no depende de restos de ejecuciones anteriores. Los fallos que sí llegan a AWS son de entorno, no de código, y son menos y más fáciles de diagnosticar. Floci es un filtro rápido, no un sustituto de AWS.

## El valor de CI/CD

**¿Qué le pasó a la web pública cuando se subió el error?** Nada. La prueba en Floci falló en el `plan` («La web no tiene portada: falta index.html.»), el trabajo de AWS quedó en `skipped` y la web siguió sirviendo la versión anterior con el nombre del autor. Tras `git revert`, los dos trabajos volvieron a terminar en verde.

**¿Qué habría pasado sin el trabajo de prueba?** Con el `deploy.sh` del kit, el despliegue habría ejecutado `aws s3 sync --delete`: habría borrado `index.html` del bucket y subido `inicio.html`. Desde ese momento, todos los clientes que abrieran la web habrían recibido la página de error en lugar de la portada, hasta que alguien lo detectara y lo arreglara a mano. En una empresa con miles de clientes, eso supone una caída visible, pérdida de ventas y de confianza, y una corrección con prisas sobre producción.

En esta implementación hay además una segunda barrera: la validación del módulo detendría también el `plan` contra AWS. Aun así, el trabajo de prueba sigue siendo necesario para los errores que una validación no puede prever, porque ejecuta el despliegue completo y comprueba que la web responde.

## Gestión de secretos

**¿Por qué las credenciales están en un secret de GitHub y no en el código?** El repositorio es público y Git conserva todo el historial. Una clave escrita en `web-deploy.sh` o en `web.tfvars` quedaría a la vista de cualquiera, y borrarla después no la quita de los commits anteriores. Un secret de GitHub, en cambio:

- se guarda cifrado y ni siquiera el propietario puede volver a leerlo;
- solo llega al trabajo que lo pide (`2. Despliegue en AWS`) y aparece enmascarado como `***` en los logs;
- no se entrega a workflows lanzados desde forks;
- se puede cambiar sin tocar el código, como se hizo en la Fase 3 al reiniciar el laboratorio.

En el runner, las credenciales solo existen en `~/.aws/credentials` de una máquina temporal que se destruye al terminar.

**¿Qué podría ocurrir si se subieran a un repositorio público?** Hay bots que rastrean GitHub en busca de claves y las encuentran en minutos. Con ellas, cualquiera podría actuar como el propietario de la cuenta: crear recursos caros (por ejemplo, instancias para minar criptomonedas), borrar o modificar la web y los datos, leer información privada o usar la cuenta para atacar a terceros. El coste y la responsabilidad recaerían en el propietario. Habría que revocar las claves de inmediato y limpiar el historial. Las credenciales de Learner Lab caducan en unas 4 horas y la cuenta tiene un presupuesto limitado, lo que reduce el daño, pero no lo elimina.

Una observación relacionada: los mensajes `AccessDenied` de AWS incluyen el ID de la cuenta y el nombre del rol. No son credenciales, pero en un repositorio público aparecen en los logs de Actions. En las evidencias de este repositorio se han ocultado.
