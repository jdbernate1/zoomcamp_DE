if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@transformer
def transform(data, *args, **kwargs):
    print('Preprocessing: rows with zero passenger:', data['passenger_count'].isin([0]).sum() )


    return data[data['passenger_count']>0]

@test
def test_output(output, *args):
    assert output['passenger_count'].isin([0]).sum()==0, "Hay viajes con 0 pasajeros"