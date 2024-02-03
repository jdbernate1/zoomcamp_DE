if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@transformer
def transform(data, *args, **kwargs):
    data = data[(data['passenger_count']>0) & (data['trip_distance']>0)]

    data['lpep_pickup_date'] = data['lpep_pickup_datetime'].dt.date
    data.columns = (data.columns
                .str.replace('(?<=[a-z])(?=[A-Z])', '_', regex=True)
                .str.lower()
             )


    return data


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output['passenger_count'].isin([0]).sum()==0, "Hay viajes con 0 pasajeros"

    assert output['trip_distance'].isin([0]).sum()==0, "Hay trip_distance igual a 0"

    assert 'vendor_id' in output.columns, "No existe la columna vendor_id"


