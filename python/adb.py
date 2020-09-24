import subprocess, os, configparser
import warnings

# [Example]
# cmd = adb.CommandWriter()
# cmd.append("ls -l")
# cmd.reset()
# cmd.append("ls -lll")
class CommandWriter:
  def __init__(self, path):
    self.adb_root = '/data/local/tmp/'
    self.adb_cmd_path = '/data/local/tmp/cmd.sh'

    self.local_cmd_path = './cmd.sh'
    self.local_cmd_file = ''
    self.reset()

  def append(self, command):
    with open(self.local_cmd_path, 'a') as local_cmd_file :
      local_cmd_file.write(command + '\n')
  
  def close(self):
    if self.local_cmd_file :
      self.local_cmd_file.close()
    else :
      assert("ERROR : command file opened")

  def reset(self):
    if self.local_cmd_file :
      self.local_cmd_file.close()

 #   with open(self.local_cmd_path, 'w') as local_cmd_file :
 #     local_cmd_file.write("#!/system/bin/sh\n")

class AdbRunner:
  def __init__(self, output_path=None):
    if output_path is None :
      self.output_path = './output.txt'
    else :
      self.output_path = output_path
      
    self.output = open(self.output_path, 'w+')
    self.adb_root = '/data/local/tmp/'
    self.adb_cmd_path = '/data/local/tmp/cmd.sh'
    self.local_cmd_path = './cmd.sh'
    self.local_temp = './.temp/'
    self.adb_exist = self.adb_root + self.local_temp + 'exist.sh'

    self.command_writer = CommandWriter(self.local_cmd_path)
    self.temp = []

    self.init_script()

  # remove temporal scripts in android
  def close(self) :
    #remove temp script in android
    _adb_command = 'adb shell rm '+ self.adb_cmd_path
    proc = subprocess.Popen(_adb_command.split(' '), universal_newlines=True)
    out, err = proc.communicate()
    
    if out :
      print(out)

    #remove temp script in local
    _local_command = 'rm ' + self.local_cmd_path
    proc = subprocess.Popen(_local_command.split(' '), universal_newlines=True)
    out, err = proc.communicate()
    
    if out :
      print(out)

  def push_temp_script(self, path, body) :
    with open(path, mode='w') as f :
      f.write("#!/system/bin/bash \n")
      f.write(body)
    
    cmd = "adb push " + path + " " + self.adb_root + path
    out, err = subprocess.Popen(cmd.split(" "), universal_newlines=True).communicate()
    print(out)

    cmd = "adb shell chmod +x " + self.adb_root + path
    out, err = subprocess.Popen(cmd.split(" "), universal_newlines=True).communicate()
    print(out)

    self.temp.append(path)

  def init_script(self) :
    subprocess.Popen(["mkdir", self.local_temp], universal_newlines=True).communicate()

    # push exist script
    name = self.local_temp + "exist.sh"
    body = """#!/system/bin/sh \n [ -e $1 1> /dev/null 2>&1 ] && echo 1 || echo 0"""
    self.push_temp_script(name, body)

  def check_exists(self, src) :
    cmd = "adb shell sh " + self.adb_exist + " " +  self.adb_root + src
    out, err = subprocess.Popen(cmd.split(" "), universal_newlines=True).communicate()
    print("exist ? err")
    print(err)
    print("exist ? out")

    print(out)

  # push files from src to (adb root/)dest
  def push_files(self, src, dest = "") :
    if dest == "" :
      dest = src    

    cmd = 'adb shell mkdir -p ' + self.adb_root + dest
    proc = subprocess.Popen(cmd.split(' '), universal_newlines=True)
    out, err = proc.communicate()
    print(out)

    cmd = 'adb push ' + src + ' ' + self.adb_root + dest
    proc = subprocess.Popen(cmd.split(' '), universal_newlines=True)
    out, err = proc.communicate()
    print(out)

  # TODO : check directory exist using script transplant
  def check(self, path):
    # check if path already exist
    cmd = "adb shell \"[ -e " + self.adb_root + path + " 1> /dev/null 2>&1 ] && echo 1 || echo 0"
    proc = subprocess.Popen(cmd.split(' '), stdout=out, stderr=out, universal_newlines=True)
    proc.communicate()

    pass



  # append comamnd to the script
  def append_script(self, command) :
    self.command_writer.append(command)

  # push script to device
  def push_script(self, clean : bool):
    self.command_writer.close()
    _command = 'adb push ' + self.local_cmd_path + ' ' + self.adb_root
    proc = subprocess.Popen(_command.split(' '), universal_newlines=True)
    proc.communicate()

    if clean == True :
      self.command_writer.reset()

  # run script in device
  def run_script(self):
    _command = 'adb shell sh '+ self.adb_cmd_path
    proc = subprocess.Popen(_command.split(' '), universal_newlines=True)
    output, errors =  proc.communicate()

    if output :
      print("output: " + output)

  # run command using script transplant
  def run(self, command, clean : bool):
    self.append_script(command)
    self.push_script(clean)
    self.run_script()


