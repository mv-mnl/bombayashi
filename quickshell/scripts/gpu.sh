#!/bin/bash
# Uso del iGPU Intel en % (vacío si intel_gpu_top no está disponible).
# Requiere: intel-gpu-tools + setcap cap_perfmon,cap_sys_ptrace=ep sobre intel_gpu_top
intel_gpu_top -d drm:/dev/dri/card1 -J -s 800 -n 2 2>/dev/null \
    | jq -r '[.[-1].engines[].busy] | max | floor' 2>/dev/null
