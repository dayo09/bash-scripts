from enum import Enum
from optparse import OptionParser
import json
from typing import List, Sequence

class Config:
  class Runtime(Enum):
    one = 1
    tflite_vanilla = 2
    tflite = 3

  class Backends(Enum):
    cpu = 1
    bcq = 2
    acl_cl = 3
    acl_neon = 4

  class Model(Enum):
    RNN_T_July = 1
    RNN_T_June = 2
    Mocha = 3

  class Submodel(Enum):
    joint = 1
    pred = 2
    tran = 3

  class Quant(Enum):
    bcq3 = 3
    bcq4 = 4
    bcq5 = 5
    int8 = 8
    fpt32 = 32

  title = ""
  runtime = Runtime.one
  backends = Backends.cpu
  model = Model.RNN_T_July
  submodel = [Submodel.joint]
  quant = [Quant.bcq3]

  def __init__(self, title: str, runtime: Runtime, backends: Backends, model: Model, submodel: List[Submodel], quant: List[Quant]):
    self.title = title
    self.runtime = runtime
    self.backends = backends
    self.model = model
    self.submodel = submodel
    self.quant = quant
    # TODO : add runtime version, device info(binary-user/engineering, processor-exy/snap)

  def print(self):
    print("title : " + self.title)
    print("runtime : " + self.runtime)
    print("backends : " + self.backends)
    print("model : " + self.model)

    print("submodel : ")
    for s in self.submodel:
      print("   " + s)

    print("quant : ")
    for q in self.quant:
      print("   " + q)


def ReadConfig(path_to_config : str):
  with open(path_to_config, 'r') as f:
    config = json.load(f)
    config = Config("Hi", config['Runtime'], config['Backends'],
                    config['Model'], config['Submodel'], config['Quant'])
  return config


#  usage = "usage : %prog [options]"
#  parser = OptionParser(usage=usage)
#  parser.add_option("--runtime", dest="Config.runtime", help="[one(default), tflite_vanilla, tflite]")
#  parser.add_option("--backends", dest="Config.backends", help="[cpu(default), bcq, acl_cl, acl_neon")
  # Fill Options In
#  options, args = parser.parse_args()
  
  # print(options)
  # print(args)
