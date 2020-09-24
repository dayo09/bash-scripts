import adb
from config import Config
import json


def RunLatency():
    pass


class OneRunner:
    def __init__(self, config: Config):
        self.config = config
        self.adb_root = "/data/local/tmp/"
        self.adb_onert = self.adb_root + title
        self.adb_onert_lib = self.adb_onert + '/lib'
        self.adb_onert_bin = self.adb_onert + '/bin'
        self.adb_nnpkg_run = self.adb_onert_bin + '/nnpackage_run'

        self.backends = ""
        self.model = ""

    def GetModelPath(self):
        if self.config.model == Config.Model.RNN_T_July:
            self.model = "model/RNN_T_July"
        elif self.config.model == Config.Model.RNN_T_June:
            self.model = "model/RNN_T_June"
        elif self.config.model == Config.Model.Mocha:
            self.model = "model/Mocha"
            assert("TODO : Mocha")

    def GetModelList(self):
        modellist = []
        for s in self.config.submodel:
            for q in self.config.quant:
                print(s + q)
                modellist.append(s+q)
        return modellist
        

    def SetRuyThreads(self, ruy_threads: int):
        self.ruy_threads = ruy_threads
    def SetBackends(self, backends : Config.Backends) :
        if backends == Config.Backends.cpu :
          self.backends = "cpu"
        elif backends = Config.Backends.bcq : 
          self.backends = "cpu;bcq"
        elif backends = Config.Bakcends.acl_cl : 
          self.backends = "acl_cl"
        elif backends = Config.Bakcends.acl_neon : 
          self.backends = "acl_neon"
        else
          assert("Unknown Bakcends")

    def RunCommand(self, warmup: int, run: int, memory: int):
        env = "LD_LIBRARY_PATH=" + self.adb_onert_lib + " " + \
            "BACKENDS=" + self.backends + " "
            "RUY_THREADS=" + self.ruy_threads + " "  # add here
        cmd = self.adb_nnpkg_run + " "
        args = "-w " + warmup + " " + "-r " + run + " " + "-m " + memory

        return env + cmd + args

    def RunBenchmark(self) :
        cmd_warmup = RunCommand(w=1) # warmup
        cmd_latency = RunCommand(w=1, r=100) # latency
        cmd_memory = RunCommand(w=1, r=5, m=1) # memory

        for m in self.GetModelList() :
          # run 
          # cmd_latency + m
          # cmd_memory + m
          

