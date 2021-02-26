import xgboost as xgb
import sklearn
import tensorflow
import keras
import numpy as np
import unittest

from tensorflow.python.client import device_lib
from keras import backend as K


def get_available_gpus():
	local_device_protos = device_lib.list_local_devices()
	return [x.name for x in local_device_protos if x.device_type == 'GPU']


class TestGPULibraries(unittest.TestCase):

	def test_tensorflow(self):
		gpus = get_available_gpus()
		assert(len(gpus))

	def test_keras_gpu(self):
		gpus = K.tensorflow_backend._get_available_gpus()
		assert(len(gpus))

	def test_xgboost_gpu(self):
		gbm = xgb.XGBRegressor(silent=False, tree_method = 'gpu_hist')
		X = np.random.rand(10,10)
		y = np.random.rand(10)
		r = gbm.fit(X, y, verbose=True)
		assert(np.mean(np.abs(r.predict(X)-y)))
