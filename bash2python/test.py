import subprocess, os

class AdbCommander:
  def __init__(self, output_path=None):
    if output_path is None :
      self._output_path = './output_adb.txt'
    else :
      self._output_path = output_path
    self._output = open(_output_path, 'w+')
  
  def RunADBCommand(_command):
    print("RunCommand : " + _command)
    out = subprocess.Popen(_command.split(' '), stdout=_output, stderr=_output, universal_newlines=True)
    print(out)

# @input
# - _command : command
# - _output : set output path
# @return 
# - stdout : _output_path (default : './output.txt')
# - stderr : print
def RunCommand(_command, _output_path = './output.txt'):

  _output = open(_output_path, 'w+')

  print("RunCommand : " + _command)

  out = subprocess.Popen(_command.split(' '), stdout=_output, stderr=subprocess.PIPE, universal_newlines=True)
  
  stdout, stderr = out.communicate()
  print(stderr)

def adb_push(_name):
  _directory_path = "~/nfs/bash_script/" + _name
  
  #if not os.path.exists(_directory_path) :
    # subprocess.call()

my_command = """adb shell ls """

adb = AdbCommander()
adb.RunADBCommand(my_command)
#example(my_command, './output.txt')
#RunCommand(my_command)
