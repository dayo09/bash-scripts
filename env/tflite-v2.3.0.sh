#!/bin/bash

export OPTIONS="-DBUILD_TFLITE_VANILLA_RUN=ON"

echo "    ★ Check ruy on/off ★ "
echo "    infra/nnfw/cmake/packages/TensorFlowLite-2.3.0/CMakeLists.txt::line 113"
echo "      @ target_compile_definitions(... -DTFLITE_WITH_RUY_GEMV)"
echo "      @  - exist(on)"
echo "      @  - non-exist(off)"
