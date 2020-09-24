from enum import Enum

class Backend(Enum):
  ACL_CL = 1
  ACL_NEON = 2


class Configuration :
  def __init__(self, backend = Backend.ACL_CL, version = 0): 
    self.backend = backend
    self.version = version

config = Configuration(1)

print(config.backend)
