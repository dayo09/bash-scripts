import re
import os
import sys
import glob
import pandas as pd
import numpy as np


def read_latency(filepath, runtime):
    if runtime == "one":
        return read_latency_one(filepath)
    elif runtime == "tflite_vanilla":
        return read_latency_one(filepath)
    elif runtime == "tflite":
        return read_latency_tflite(filepath)


def read_memory(filepath, runtime):
    if runtime == "one":
        return read_memory_one(filepath)
    elif runtime == "tflite_vanilla":
        return read_memory_one(filepath)
    elif runtime == "tflite":
        return read_memory_tflite(filepath)


def read_latency_one(filepath):
    data = []
    with open(filepath, 'r') as file_raw:
        file_oneline = file_raw.read().replace('\n', '')
        data.extend(re.findall(
            r'MODEL_LOAD\s+takes\s(\d+\.\d+)\sms', file_oneline))
        data.extend(re.findall(
            r'PREPARE\s+takes\s(\d+\.\d+)\sms', file_oneline))
        data.extend(re.findall(
            r'EXECUTE\s+takes\s(\d+\.\d+)\sms', file_oneline))
        return data


def read_memory_one(filepath):
    data = []
    with open(filepath, 'r') as file_raw:
        file_oneline = file_raw.read().replace('\n', '')
        data.append(re.findall(
            r'MODEL_LOAD\s+takes\s(\d+)\skb', file_oneline))
        data.append(re.findall(
            r'PREPARE\s+takes\s(\d+)\skb', file_oneline))
        data.append(re.findall(
            r'EXECUTE\s+takes\s(\d+)\skb', file_oneline))
        data.append(re.findall(r'PEAK\s+takes\s(\d+)\skb', file_oneline))

    return np.transpose(np.array(data)).flatten().tolist()
    # return array(np.array(data).flatten())  # data[PHASE][RSS|HWM|PSS]


"""
def read_memory_with_rss(filepath):
    data = read_memory_one(filepath)

    with open(filepath, 'r') as file_raw:
        file_oneline = file_raw.read()
        rss_from_smaps = re.findall(
            r'RSS\sfrom\ssmaps:\s+(\d+)$', file_oneline, flags=re.MULTILINE)
        data.append(max(rss_from_smaps))
"""


def read_memory_with_rss(filepath):
    data = read_memory_one(filepath)

    with open(filepath, 'r') as file_raw:
        file_oneline = file_raw.read()
        rss_from_smaps = re.findall(
            r'RSS\sfrom\ssmaps:\s+(\d+)$', file_oneline, flags=re.MULTILINE)
        #print(map(int, rss_from_smaps))
        print(max(map(int, rss_from_smaps)))
        print(str(max(map(int, rss_from_smaps))))
        #str(max(map(int, rss_from_smaps)))
        data.append(str(max(map(int, rss_from_smaps))))

        return data


def read_latency_tflite(filepath):
    with open(filepath, 'r') as file_raw:
        file_oneline = file_raw.read().replace('\n', ' ')
        res = re.findall(r'Inference \(avg\): (\d+\.*\d*) ', file_oneline)

        if len(res) == 0:
            print("No Value at: "+filepath)

    return res


def read_memory_tflite(filepath):
    with open(filepath, 'r') as file_raw:
        file_oneline = file_raw.read().replace('\n', ' ')
        res = re.findall(
            r'Peak memory footprint \(MB\): init=\d*\.*\d* overall=(\d+\.\d*) ', file_oneline)

        if len(res) == 0:
            print("No Value at: "+filepath)
    return res


def bcq_one_model_list():
    model = ["joint", "pred", "tran"]
    quant = ["3", "4", "q", "f"]
    model_list = []
    for m in model:
        for q in quant:
            model_list.append(m+q)
    return model_list


def bcq_tflite_model_list():
    model = ["joint", "pred", "tran"]
    quant = ["q", "f"]
    model_list = []
    for m in model:
        for q in quant:
            model_list.append(m+q)
    return model_list


def mocha_model_list():
    return ["enc", "enc1", "enc2", "dec1", "dec2", "dec3"]


def get_modelfile_name(log_path, model_type, model_list, i):
    if model_type == "bcq":
        log_file = log_path + "/" + model_list[i] + ".log"
    elif model_type == "mocha":
        log_file = log_path + "/mocha_" + model_list[i] + ".log"
    else:
        print("Invalid model_type name")
        return

    return log_file


def delete_file(filepath):
    os.remove(filepath)


def parse_latency(runtime):
    result = []

    if runtime == "one" or runtime == "tflite_vanilla":
        label = ["MODEL NAME", "MODEL_LOAD", "PREPARE", "EXECUTE"]
        log_latency_path = log_path + "/latency"
    elif runtime == "tflite":
        label = ["MODEL NAME", "EXECUTE"]
        log_latency_path = log_path
    else:
        print("Invalid runtime")
        return

    result.append(label)

    for i in range(0, len(model_list)):
        log_file = get_modelfile_name(
            log_latency_path, model_type, model_list, i)

        value = []
        value.append(model_list[i])
        value.extend(read_latency(log_file, runtime))
        # print(value)
        result.append(value)

    # print(result)
    df = pd.DataFrame.from_records(result)
    result_path = log_path + '/' + 'latency.xlsx'
    if os.path.exists(result_path):
        delete_file(result_path)
    df.to_excel(result_path)
    return


MODEL_LOAD = 0
PREPARE = 1
EXECUTE = 2
PEAK = 3

RSS = 0
HWM = 1
PSS = 2


def parse_memory(runtime):
    result = []

    if runtime == "one" or runtime == "tflite_vanilla":
        #label = ["MODEL NAME", "MODEL_LOAD", "PREPARE", "EXECUTE", "PEAK"]
        label = ["MODEL NAME"]
        phase = ["MODEL_LOAD", "PREPARE", "EXECUTE", "PEAK"]
        memory_type = ["RSS", "HWM", "PSS"]

        for m in range(len(memory_type)):
            for p in range(len(phase)):
                label.append(phase[p] + "/" + memory_type[m])
        print(label)

        log_memory_path = log_path + "/memory"
    elif runtime == "tflite":
        label = ["MODEL NAME", "PEAK"]
        log_memory_path = log_path
    else:
        print("Invalid runtime")
        return

    result.append(label)
    for i in range(0, len(model_list)):
        log_file = get_modelfile_name(
            log_memory_path, model_type, model_list, i)

        value = []
        value.append(model_list[i])
        value.extend(read_memory(log_file, runtime))

        result.append(value)

    print(result)
    df = pd.DataFrame.from_records(result)
    result_path = log_path + '/' + 'memory.xlsx'

    if os.path.exists(result_path):
        delete_file(result_path)
    df.to_excel(result_path)
    return


def parse_memory_with_rss():
    result = []

    _label = ["MODEL NAME"]
    phase = ["MODEL_LOAD", "PREPARE", "EXECUTE", "PEAK"]
    memory_type = ["RSS", "HWM", "PSS"]

    for m in range(len(memory_type)):
        for p in range(len(phase)):
            _label.append(phase[p] + "/" + memory_type[m])

    _label.append("RSS from smaps")
    log_rss_path = log_path + "/rss/nnpackage_run"

    result.append(_label)
    for i in range(0, len(model_list)):
        log_file = get_modelfile_name(
            log_rss_path, model_type, model_list, i)

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


def get_model_list(runtime, model_type):
    print(runtime + model_type)
    model_list = []
    if model_type == "mocha":
        model_list = mocha_model_list()
    elif model_type == "bcq":
        if runtime == "one":
            model_list = bcq_one_model_list()
        elif runtime == "tflite_vanilla":
            model_list = bcq_tflite_model_list()
        else:
            print("Invalid Runtime Name")
    else:
        print("Invalid Model Name")

    return model_list


log_root = "/home/dayo/nfs/bash_script/log/"
log_name_major = sys.argv[1]
log_name_minor = max(os.listdir(path=log_root+log_name_major))
log_path = log_root + log_name_major + "/" + log_name_minor



runtime = "one"  # "one" "tflite" "tflite_vanilla"
model_type = "bcq"  # "bcq" "mocha"
model_list = get_model_list(runtime, model_type)

parse_latency(runtime)
#parse_memory(runtime)
parse_memory_with_rss()
