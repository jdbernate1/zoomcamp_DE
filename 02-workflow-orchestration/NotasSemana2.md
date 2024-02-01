### Levantar Mage con Docker Build
Antes de correr docker compose build
```bash
docker compose build
```
hay que hacer:
```bash
cp dev.env .env
```
Para asegurar que nuestros secretos, los que se usan o cualquier otro este en el .env que espera docker.

Al hacer docker compose build, va crear la imagen, tarda un poco. 