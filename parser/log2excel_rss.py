import re
import os
import sys
import glob
import pandas as pd
import numpy as np

def read_memory_one(filepath):
    data = []
    with open(filepath, 'r') as file_raw:
        file_oneline = file_raw.read().replace('\n', '')
        data.append(re.findall(
            r'MODEL_LOAD\s+takes\s(\d+)\skb', file_oneline)[0])
        data.append(re.findall(r'PREPARE\s+takes\s(\d+)\skb', file_oneline)[0])
        data.append(re.findall(r'EXECUTE\s+takes\s(\d+)\skb', file_oneline)[0])
        data.append(re.findall(r'PEAK\s+takes\s(\d+)\skb', file_oneline)[0])

        return data

def read_memory_with_rss(filepath):
    data = read_memory_one(filepath)

    with open(filepath, 'r') as file_raw:
        file_oneline = file_raw.read()
        rss_from_smaps = re.findall(
            r'RSS\sfrom\ssmaps:\s+(\d+)$', file_oneline, flags=re.MULTILINE)
        data.append(str(max(map(int,rss_from_smaps))))
        return data

def get_model_list():
    model = ["joint", "pred", "tran"]
    quant = ["q", "f"]
    model_list = []
    for m in model:
        for q in quant:
            model_list.append(m+q)
    return model_list

def get_modelfile_name(log_path, model_list, i):
    return log_path + "/" + model_list[i] + ".log"

def delete_file(filepath):
    os.remove(filepath)

def parse_memory_with_rss():
    result = []

    label = ["MODEL NAME", "MODEL_LOAD", "PREPARE", "EXECUTE", "PEAK", "RSS"]

    result.append(label)
    for i in range(0, len(model_list)):
        log_file = get_modelfile_name(
            log_memory_path, model_list, i)

        value = []
        value.append(model_list[i])
        value.extend(read_memory_with_rss(log_file))

        result.append(value)

    print(result)
    df = pd.DataFrame.from_records(result)
    result_path = log_path + '/' + 'memory.xlsx'

    if os.path.exists(result_path):
        delete_file(result_path)
    df.to_excel(result_path)
    return


# log_name_major = sys.argv[1]
# log_name_minor = sys.argv[2]
# log_root = "/home/dayo/nfs/bash_script/log/"
log_path = sys.argv[1]
log_memory_path = log_path
model_list = get_model_list()

#parse_latency(runtime)
#parse_memory(runtime)
parse_memory_with_rss()
