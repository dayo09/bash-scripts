import re
import sys

filepath = sys.argv[1]

def read_rss_from_smaps(filepath):
    with open(filepath, 'r') as file_raw:
        file_oneline = file_raw.read()
        rss_from_smaps = re.findall(
            r'RSS\sfrom\ssmaps:\s+(\d+)$', file_oneline, flags=re.MULTILINE)
        return max(rss_from_smaps)

print(max(read_rss_from_smaps(filepath)))

"""
with open(filepath, 'r') as file_object:
  data = []
  new_file = file_object.read().replace('\n',' ')
  #rls = new_file.readline()
  #m = re.search(r'takes\s+(d+.d+)\s+ms', new_file)
  print(re.findall(r'Inference \(avg\): (\d+\.\d*) ', new_file))
  print(re.findall(r'Peak memory footprint \(MB\): init=\d*\.\d* overall=(\d+\.\d*) ', new_file))
"""
