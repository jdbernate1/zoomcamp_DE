if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@transformer
def transform(data, *args, **kwargs):

    data['lpep_pickup_datetime'] = data['lpep_pickup_datetime'].dt.strftime('%Y/%m/%d %H:%M:%S')
    data['lpep_dropoff_datetime'] = data['lpep_dropoff_datetime'].dt.strftime('%Y/%m/%d %H:%M:%S')

    return data


