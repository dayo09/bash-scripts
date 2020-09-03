#!/system/bin/sh

```
export ONE_PATH=/data/local/tmp/one
export LIB_PATH="$ONE_PATH"/lib

export LIB_1THREAD="$LIB_PATH"/libbackend_cpu_bcq_1thread.so
export LIB_4THREAD="$LIB_PATH"/libbackend_cpu_bcq_4thread.so

echo $LIB_1THREAD
# [[ -f "$LIB_1THREAD" && -f "$LIB_4THREAD" ]] && echo "hi"
```