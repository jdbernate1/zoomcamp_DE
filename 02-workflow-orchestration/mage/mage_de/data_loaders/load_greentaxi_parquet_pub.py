import io
import pandas as pd
import requests
if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test

periods =[
    '2022-01',
    '2022-02',
    '2022-03',
    '2022-04',
    '2022-05',
    '2022-06',
    '2022-07',
    '2022-08',
    '2022-09',
    '2022-10',
    '2022-11',
    '2022-12'
]

@data_loader
def load_data_from_api(*args, **kwargs):

    dfs = []
    url_source = kwargs['configuration'].get('url_source')
    for p in periods:
        url = url_source+'green_tripdata_'+p+'.parquet'
        print(url)
        df_raw = pd.read_parquet(url)
        dfs.append(df_raw)
    
    data = pd.concat(dfs)
    print(data.dtypes)

    return data


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'
