# Conclusiones

## Parte 1

Terraform desplegó y verificó en Floci seis usuarios, tres grupos, siete pertenencias y tres políticas inline asociadas solo a grupos. El simulador confirmó permisos de desarrollo, operaciones y auditoría, así como denegaciones implícitas para acciones ajenas a cada función.

El caso de `alicia` demuestra la precedencia del `Deny` explícito: recibe permisos de Dev-Team y SecOps-Team, pero no puede borrar objetos S3 según la simulación. La gobernanza por grupos permite mantener y auditar esos permisos sin configuraciones individuales.

El reinicio sin persistencia borró las seis identidades. Terraform detectó y recreó los 18 recursos declarados, lo que confirma que el entorno puede reconstruirse desde código y utilizarse como base limpia para pruebas CI/CD. El simulador verifica decisiones de autorización; una comprobación en AWS real exigiría además revisar ARNs, dependencias entre servicios y restricciones adicionales del entorno de producción.

## Parte 2

El despliegue de la web confirma la misma idea desde otro ángulo: un emulador sirve para probar el código, no la cuenta. Floci aceptó el nombre `nextgen` y sirvió una web privada; AWS rechazó el nombre por ser global y devolvió 403 hasta que se concedió la lectura pública. Learner Lab añadió restricciones propias, como la SCP sobre object lock y la política `voc-cancel-cred`, que ningún emulador local puede anticipar.

Aun así, la prueba en Floci fue la que protegió producción. El commit que eliminaba la portada se detuvo en el primer trabajo, el despliegue no se ejecutó y la web pública siguió funcionando. Que las validaciones estén en el módulo de Terraform permitió que también fallara el workflow `CI`: son dos barreras independientes con el mismo código.

Llevar el kit a Terraform tuvo un coste: estado remoto para los runners efímeros y crear el bucket fuera del proveedor por la SCP. A cambio, el despliegue es declarativo, se puede revisar con `plan` y es idéntico en el PC, en GitHub Actions y en AWS. Solo cambian el endpoint, las credenciales y el estado, y las credenciales nunca salen del secret.
