#!/bin/bash

echo "=== Custom setup (LTX Video): начало ==="

if [ ! -d "/workspace/ComfyUI" ]; then
    echo "ОШИБКА: /workspace/ComfyUI не найден!"
    exit 1
fi

# ============================================================
# Скачивание моделей — aria2, 16 потоков на файл, все параллельно
# ============================================================
echo "Скачивание моделей (aria2, параллельно)..."

MODELS="/workspace/ComfyUI/models"
mkdir -p "${MODELS}/diffusion_models"
mkdir -p "${MODELS}/text_encoders"
mkdir -p "${MODELS}/vae"
mkdir -p "${MODELS}/loras"

download() {
    local url="$1"
    local dir="$2"
    local filename="$3"

    if [ ! -f "${dir}/${filename}" ]; then
        echo "  -> ${filename}"
        aria2c -x 16 -s 16 -k 1M \
            --file-allocation=none \
            --console-log-level=error \
            --summary-interval=0 \
            -d "$dir" -o "$filename" \
            "$url"
    else
        echo "  -> ${filename} (уже есть, пропуск)"
    fi
}

# --- diffusion_models ---
download \
    "https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-19b-dev.safetensors" \
    "${MODELS}/checkpoints" \
    "ltx-2-19b-dev.safetensors" &

# --- text_encoders ---
download \
    "https://huggingface.co/Comfy-Org/ltx-2/resolve/main/split_files/text_encoders/gemma_3_12B_it.safetensors" \
    "${MODELS}/text_encoders" \
    "gemma_3_12B_it.safetensors" &

# --- vae ---
download \
    "https://huggingface.co/Kijai/LTXV2_comfy/resolve/main/VAE/LTX2_audio_vae_bf16.safetensors" \
    "${MODELS}/vae" \
    "LTX2_audio_vae_bf16.safetensors" &

download \
    "https://huggingface.co/Kijai/LTXV2_comfy/resolve/main/VAE/LTX2_video_vae_bf16.safetensors" \
    "${MODELS}/vae" \
    "LTX2_video_vae_bf16.safetensors" &

# --- loras ---
download \
    "https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-spatial-upscaler-x2-1.0.safetensors" \
    "${MODELS}/upscale_models" \
    "ltx-2-spatial-upscaler-x2-1.0.safetensors" &

download \
    "https://huggingface.co/Lightricks/LTX-2-19b-LoRA-Camera-Control-Static/resolve/main/ltx-2-19b-lora-camera-control-static.safetensors" \
    "${MODELS}/loras" \
    "ltx-2-19b-lora-camera-control-static.safetensors" &

# --- mel_band_roformer ---
download \
    "https://huggingface.co/Kijai/MelBandRoFormer_comfy/resolve/main/MelBandRoformer_fp32.safetensors" \
    "${MODELS}/diffusion_models" \
    "MelBandRoformer_fp32.safetensors" &

echo "Ожидание завершения всех загрузок..."
wait

echo "=== 🚀Запускай комфи, все готово🚀 ==="
