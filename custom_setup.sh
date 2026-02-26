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
mkdir -p "${MODELS}/latent_upscale_models"

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
    "https://huggingface.co/Kijai/WanVideo_comfy_fp8_scaled/resolve/main/S2V/Wan2_2-S2V-14B_fp8_e4m3fn_scaled_KJ.safetensors" \
    "${MODELS}/checkpoints" \
    "Wan2_2-S2V-14B_fp8_e4m3fn_scaled_KJ.safetensors" &

download \
"https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_480p_14B_fp16.safetensors" \
"${MODELS}/diffusion_models" \
"wan2.1_i2v_480p_14B_fp16.safetensors" &

download \
"https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/InfiniteTalk/Wan2_1-InfiniTetalk-Single_fp16.safetensors" \
"${MODELS}/diffusion_models" \
"Wan2_1-InfiniTetalk-Single_fp16.safetensors" &

# --- loras ---
download \
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_animate_14B_relight_lora_bf16.safetensors" \
    "${MODELS}/loras" \
    "wan2.2_animate_14B_relight_lora_bf16.safetensors" &

download \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors" \
    "${MODELS}/loras" \
    "Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors" &

download \
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors" \
    "${MODELS}/loras" \
    "wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors" &

download \
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors" \
    "${MODELS}/loras" \
    "wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors" &

download \
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors" \
    "${MODELS}/loras" \
    "wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors" &

download \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_I2V_14B_480p_cfg_step_distill_rank256_bf16.safetensors" \
    "${MODELS}/loras" \
    "lightx2v_I2V_14B_480p_cfg_step_distill_rank256_bf16.safetensors" &

download \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Pusa/Wan21_PusaV1_LoRA_14B_rank512_bf16.safetensors" \
    "${MODELS}/loras" \
    "Wan21_PusaV1_LoRA_14B_rank512_bf16.safetensors" &

download \
    "https://huggingface.co/alibaba-pai/Wan2.2-Fun-Reward-LoRAs/resolve/main/Wan2.2-Fun-A14B-InP-low-noise-HPS2.1.safetensors" \
    "${MODELS}/loras" \
    "Wan2.2-Fun-A14B-InP-low-noise-HPS2.1.safetensors" &

# --- text_encoders ---
download \
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" \
    "${MODELS}/text_encoders" \
    "umt5_xxl_fp8_e4m3fn_scaled.safetensors" &

download \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp16.safetensors" \
    "${MODELS}/text_encoders" \
    "umt5_xxl_fp16.safetensors" &

# --- vae ---
download \
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors" \
    "${MODELS}/vae" \
    "wan_2.1_vae.safetensors" &

# --- clip_vision ---
download \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors" \
    "${MODELS}/clip_vision" \
    "clip_vision_h.safetensors" &
    
# --- detection ---
download \
"https://huggingface.co/Wan-AI/Wan2.2-Animate-14B/resolve/main/process_checkpoint/det/yolov10m.onnx" \
"${MODELS}/detection" \
"yolov10m.onnx" &

download \
"https://huggingface.co/Kijai/vitpose_comfy/resolve/main/onnx/vitpose_h_wholebody_model.onnx" \
"${MODELS}/detection" \
"vitpose_h_wholebody_model.onnx" &

download \
"https://huggingface.co/Kijai/vitpose_comfy/resolve/main/onnx/vitpose_h_wholebody_data.bin" \
"${MODELS}/detection" \
"vitpose_h_wholebody_data.bin" &

# --- RIFE models (в папку кастомной ноды) ---
RIFE_DIR="/workspace/ComfyUI/custom_nodes/ComfyUI-Frame-Interpolation/ckpts/rife"
mkdir -p "${RIFE_DIR}"

download \
    "https://huggingface.co/hfmaster/models-moved/resolve/cab6dcee2fbb05e190dbb8f536fbdaa489031a14/rife/rife49.pth" \
    "${RIFE_DIR}" \
    "rife49.pth" &

download \
    "https://huggingface.co/jasonot/mycomfyui/resolve/main/rife47.pth" \
    "${RIFE_DIR}" \
    "rife47.pth" &

echo "Ожидание завершения всех загрузок..."
wait

echo "=== 🚀Запускай комфи, все готово🚀 ==="
