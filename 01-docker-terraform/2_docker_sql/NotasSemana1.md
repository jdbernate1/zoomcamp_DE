#### Para usar git bash y docker
hay que usar winpty antes de la sentencia

### Comandos usados para practicar Docker
```bash
docker run -it \
    -e POSTGRES_USER="root" \
    -e POSTGRES_PASSWORD="root" \
    -e POSTGRES_DB="ny_taxi" \
    -v /c:/Users/JuanDiego/Documents/data-engineering-zoomcamp/01-docker-terraform/2_docker_sql/ny_taxi_postgres_data:/var/lib/postgresql/data \
    -p 5432:5432 \
postgres:13
```
#### -e indica que son variables de entorno
#### -v volumen a compartir para persitir datos
#### -p puerto a usar
#### Es clave usar -p 5432:5432 porque en el video del curso aparece solo -p 5432 y no conecta
#### Para conectar usar:
 pgcli -h localhost  -p 5432 -u root -d ny_taxi


#Obtener csv de ejemplo con datos de taxi ny
https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2019-01.csv.gz

#### lo descargo con wget -> pyhton -m pip install wget
#### 
``` python
python -m wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2019-01.csv.gz
```

#### A continuación se usa el codigo del notebook para subir por chunks a la bbdd
```python 
import pandas as pd
from sqlalchemy import create_engine

engine = create_engine('postgresql://root:root@localhost:5432/ny_taxi')
print(pd.io.sql.get_schema(df, name='yellow_taxi_data', con=engine))

df_iter = pd.read_csv('yellow_tripdata_2019-01.csv.gz', iterator=True, chunksize=100000)
df = next(df_iter)
len(df)
df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime) #asegurar los tipos datetime
df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

df.head(n=0).to_sql(name='yellow_taxi_data', con=engine, if_exists='replace')

##Con esto lo que se hace es que al pasar solo los titulos ejecuta el create statement
%time df.to_sql(name='yellow_taxi_data', con=engine, if_exists='append')

from time import time
while True: 
    t_start = time()

    df = next(df_iter)

    df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
    df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)
    
    df.to_sql(name='yellow_taxi_data', con=engine, if_exists='append')

    t_end = time()

    print('inserted another chunk, took %.3f second' % (t_end - t_start))

```

### PGadmin
Ahora que nos conectamos a la ddbb con pgcli por consola, pgadmin se puede usar para mejorar la usabilidad de postgres. Usando postgres

```bash
docker run -it \
    -e PGADMIN_DEFAULT_EMAIL=admin@admin.com \
    -e PGADMIN_DEFAULT_PASSWORD=root \
    -p 8080:80 \
    dpage/pgadmin4
```

### OK, esto funciona, pero postgres y pgadmin estan aislados.
hay que crear una red (network) unica donde ambos contenedores se puedan conectar

```bash
docker network create pg-network
```

con lo anterior ahora las llamadas de docker serían


```bash
docker run -it \
    -e POSTGRES_USER="root" \
    -e POSTGRES_PASSWORD="root" \
    -e POSTGRES_DB="ny_taxi" \
    -v /c:/Users/JuanDiego/Documents/data-engineering-zoomcamp/01-docker-terraform/2_docker_sql/ny_taxi_postgres_data:/var/lib/postgresql/data \
    -p 5432:5432 \
    --network=pg-network \
    --name pg-database \
postgres:13
```
name especifica como va ser reconocido en la red

```bash
docker run -it \
    -e PGADMIN_DEFAULT_EMAIL=admin@admin.com \
    -e PGADMIN_DEFAULT_PASSWORD=root \
    -p 8080:80 \
    --network=pg-network \
    --name pg-admin \
    dpage/pgadmin4
```

### Ingesta de datos con arg parser
Ahora, se organiza el .py extrayendo de upload-data.ipynb con el fin de extraer data desde los csv de viajes de taxis y cargarlos directamente a postgres.
#### ingest_data.py
```python
import os
import argparse

from time import time

import pandas as pd
from sqlalchemy import create_engine


def main(params):
    user = params.user
    password = params.password
    host = params.host 
    port = params.port 
    db = params.db
    table_name = params.table_name
    url = params.url
    
    # the backup files are gzipped, and it's important to keep the correct extension
    # for pandas to be able to open the file
    if url.endswith('.csv.gz'):
        csv_name = 'output.csv.gz'
    else:
        csv_name = 'output.csv'

    os.system(f"wget {url} -O {csv_name}")

    engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{db}')

    df_iter = pd.read_csv(csv_name, iterator=True, chunksize=100000)

    df = next(df_iter)

    df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
    df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

    df.head(n=0).to_sql(name=table_name, con=engine, if_exists='replace')

    df.to_sql(name=table_name, con=engine, if_exists='append')


    while True: 

        try:
            t_start = time()
            
            df = next(df_iter)

            df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
            df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

            df.to_sql(name=table_name, con=engine, if_exists='append')

            t_end = time()

            print('inserted another chunk, took %.3f second' % (t_end - t_start))

        except StopIteration:
            print("Finished ingesting data into the postgres database")
            break

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Ingest CSV data to Postgres')

    parser.add_argument('--user', required=True, help='user name for postgres')
    parser.add_argument('--password', required=True, help='password for postgres')
    parser.add_argument('--host', required=True, help='host for postgres')
    parser.add_argument('--port', required=True, help='port for postgres')
    parser.add_argument('--db', required=True, help='database name for postgres')
    parser.add_argument('--table_name', required=True, help='name of the table where we will write the results to')
    parser.add_argument('--url', required=True, help='url of the csv file')

    args = parser.parse_args()

    main(args)

```

Para llamar este .py desde la consola.
Ojo, hay que descargar wget.exe y añadirlo "C:\Program Files\Git\mingw64\bin\"

``` bash
URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2019-09.csv.gz"
python ingest_data.py \
    --user=root \
    --password=root \
    --host=localhost \
    --port=5432 \
    --db=ny_taxi \
    --table_name=yellow_taxi_trips\
    --url=${URL}

```
Este ultimo va tardar un poco subiendo los datos.

## Dockerizar esta ejecucion

con <b>Dockerfile</b>
``` Dockerfile
FROM python:3.9.1 

RUN apt-get install wget
RUN pip install pandas sqlalchemy psycopg2

WORKDIR /app
COPY ingest_data.py ingest_data.py 

ENTRYPOINT [ "python", "ingest_data.py" ]
```
FROM indica que imagen usar.
RUN son alistamientos que usamos para asegurar que todo funcione. Instalar wget y las librerias de pandas.
WORKDIR equivalente a cd
COPY copia los archivos especificados
ENTRYPOINT indica que hacer al terminar los pasos anterior

#### BUILD del dockerfile
Ahora que el dockerfile esta definido como necesitamos. Es necesario hacer el build de la imagen para que pueda ser llamada despues.
Ojo que el punto del final es clave.
```bash
docker build -t taxi_ingest:v001 .
```
Una vez que el build fue hecho se puede llamar de la siguiente manera.
Ojo, hay que tener en cuenta que el host ya no sería localhost, sino pg-database. Porque el localhost del container es el mismo. Por esto declaramos el parametro network antes de la imagen.
``` bash
URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2019-09.csv.gz"
docker run -it \
    --network=pg-network \
    -it taxi_ingest:v001 \
    --user=root \
    --password=root \
    --host=pg-database \
    --port=5432 \
    --db=ny_taxi \
    --table_name=yellow_taxi_trips\
    --url=${URL}
```

Despues de esperar esto deberia popular la tabla yellow_taxi_trips.

#### Nota aparte.
para probar que descargue más rapido. Se puede iniciar un http.server en python y los archivos van a poder simular ser descargados desde el localhost

```python
python -m http.server
```

## Docker Compose
Ahora para que siempre esten en la misma red y se levanten al mismo tiempo usamos docker compose.
Hay que crear un docker_compose.yml es diferente a los docker file pero los parametros son los mismos

```yaml
services:
  pgdatabase:
    image: postgres:13
    environment:
      - POSTGRES_USER = "root"
      - POSTGRES_PASSWORD = "root" 
      - POSTGRES_DB = "ny_taxi" 
    volumes:
      - ./ny_taxi_postgres_data:/var/lib/postgresql/data:rw
    ports:
      - "5432:5432"
  pgadmin:
    image: dpage/pgadmin4
    environment:
      - PGADMIN_DEFAULT_EMAIL=admin@admin.com
      - PGADMIN_DEFAULT_PASSWORD=root
    ports:
      - "8080:80"
```
Para usarlo hacemos

```bash
docker-compose up
```
o también se puede hacer
Añadiendo -d para usarlo en modo detached, se puede seguir usando la misma consola.

```bash
docker-compose up -d
```
Luego para inactivarlo ctrl+c y/o

```bash
docker-compose down
```

sobre el docker-compose 
```bash
URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2019-09.csv.gz"
docker run -it \
    --network=pg-network \
    -it taxi_ingest:v001 \
    --user=root \
    --password=root \
    --host=pgdatabase \
    --port=5432 \
    --db=ny_taxi \
    --table_name=yellow_taxi_trips\
    --url=${URL}
```