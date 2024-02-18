import pyarrow as pa
import pyarrow.parquet as pq
import os

if 'data_exporter' not in globals():
    from mage_ai.data_preparation.decorators import data_exporter



os.environ['GOOGLE_APPLICATION_CREDENTIALS']= "/home/src/keys/dezoomcampjdbv-5c85d5d501cf.json"
project_id = 'dezoomcampjdbv'



@data_exporter
def export_data(data,*args, **kwargs):
    bucket_name = kwargs['configuration'].get('bucket_name')
    table_name = kwargs['configuration'].get('table_name')
    str_col_part = kwargs['configuration'].get('datetitme_column')
    print("bucket name: ", bucket_name)
    print("table name: ", table_name)
    print("datetime_col: ", str_col_part)

    root_path = f'{bucket_name}/{table_name}'
    data['pickup_date'] = data[str_col_part].dt.strftime('%Y-%m')

    table = pa.Table.from_pandas(data)

    gcs = pa.fs.GcsFileSystem()

    pq.write_to_dataset(
        table,
        root_path = root_path,
        partition_cols = ['pickup_date'],
        filesystem = gcs
    )

