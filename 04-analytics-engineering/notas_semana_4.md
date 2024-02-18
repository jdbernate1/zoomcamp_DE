#### dbt labs
## Comandos
dbt build
dbt deps - instala dependencias

## Materializations

- Ephemeral
- View
- Table
- Incremental

## En dbt existen:
- Sources:
Tablas o data cargada en el data warehouse.
Los sources pueden tener definido un "freshness".
- Seeds:
csvs en el repositorio de trabajo. Deben ser pequeños y no cambiar frecuentemente porque lo ideal es que esten dentro del control de versiones

```bash
dbt seeds -s file_name
```

## Ref

es una funcionalidad (macro) que permite enmascarar las ejecuciones para hacerlas más cortas y declarativas además de manterner las dependencias bien definidas.

## En models
Creamos un folder llamado "staging" con un "schema.yml" donde se definen los  sources

```yml
version: 2

sources:
  - name: staging
    database: dezoomcampjdbv
    schema: trips_data_all
    tables:
      - name: green_taxi_data
      - name: yellow_taxi_data
```


## Macros
Generar estructuras de control (if, loops, etc) en sql como variables para generalizar su uso.

```sql
{#
    This macro returns the description of the payment_type 
#}

{% macro get_payment_type_description(payment_type) -%} --simil fx(parameter)

    case {{ dbt.safe_cast("payment_type", api.Column.translate_type("integer")) }}  
        when 1 then 'Credit card'
        when 2 then 'Cash'
        when 3 then 'No charge'
        when 4 then 'Dispute'
        when 5 then 'Unknown'
        when 6 then 'Voided trip'
        else 'EMPTY'
    end

{%- endmacro %}
```

## Variables

Como correr con variables
```bash
dbt build --select stg_green_taxi_data --vars '{'is_test_run':'false'}'

```


Como correr con variables fact_trips y todas las dependencias
```bash
dbt build --select +fact_trips+ --vars '{'is_test_run':'false'}'

#Este si me funciona
dbt build --select +fact_trips+  --vars '{"is_test_run":False}'

```


## Test
dbt permite hacer testeos de la calidad de los datos que se generan.

### Un dato utilitario.
Con el paquete
```yml
  - package: dbt-labs/codegen
    version: 0.12.1
```
Se pueden generar el schema.yml para obtener todas las columnas y añadir los testeos necesarios. Un ejemplo de como usarlo

```sql
{%set models_to_generate = codegen.get_models(directory='staging',prefix='stg')%}

{{codegen.generate_model_yaml(
    model_names = models_to_generate
)

}}
```