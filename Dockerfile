# ============================================================
# Базовый образ — latest (ComfyUI 0.15.1+, PyTorch 2.10.0+cu128)
# ============================================================
FROM ashleykza/comfyui:latest

RUN apt-get update && apt-get install -y --no-install-recommends aria2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ============================================================
# Запоминаем версию PyTorch из базового образа
# ============================================================
RUN . /ComfyUI/venv/bin/activate && \
    python3 -c "import torch; print(torch.__version__)" > /tmp/torch_version_base && \
    echo "=== Base PyTorch: $(cat /tmp/torch_version_base) ===" && \
    deactivate

# ============================================================
# Кастомные ноды — WanVideoWrapper запинен на v1.4.5
# ============================================================
RUN cd /ComfyUI/custom_nodes && \
    # WanVideoWrapper v1.4.5 (коммит f28e7da)
    git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git && \
    cd ComfyUI-WanVideoWrapper && git checkout f28e7da && cd .. && \
    # Custom Scripts (pythongosssss)
    git clone --depth 1 https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git && \
    # LTXVideo
    git clone --depth 1 https://github.com/Lightricks/ComfyUI-LTXVideo.git && \
    # rgthree
    git clone --depth 1 https://github.com/rgthree/rgthree-comfy.git && \
    # KJNodes
    git clone --depth 1 https://github.com/kijai/ComfyUI-KJNodes.git && \
    # VideoHelperSuite
    git clone --depth 1 https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git && \
    # WAS Node Suite
    git clone --depth 1 https://github.com/ltdrdata/was-node-suite-comfyui.git && \
    # MelBandRoFormer
    git clone --depth 1 https://github.com/kijai/ComfyUI-MelBandRoFormer.git && \
    # Frame Interpolation
    git clone --depth 1 https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git

# ============================================================
# Зависимости нод — БЕЗ перезаписи torch
# ============================================================
RUN . /ComfyUI/venv/bin/activate && \
    TORCH_BASE=$(cat /tmp/torch_version_base) && \
    echo "=== Защищаем PyTorch ${TORCH_BASE} ===" && \
    \
    # WanVideoWrapper — зависимости поштучно, БЕЗ torch
    pip install ftfy accelerate einops "diffusers>=0.33.0" "peft>=0.17.0" \
                "sentencepiece>=0.2.0" protobuf pyloudnorm "gguf>=0.17.1" \
                opencv-python scipy --quiet && \
    \
    # Остальные ноды — через requirements.txt
    for dir in /ComfyUI/custom_nodes/*/; do \
        nodename=$(basename "$dir"); \
        if [ "$nodename" = "ComfyUI-WanVideoWrapper" ]; then continue; fi; \
        if [ -f "${dir}requirements.txt" ]; then \
            echo "Installing deps for ${nodename}..." && \
            pip install -r "${dir}requirements.txt" --quiet; \
        fi; \
    done && \
    \
    # Проверяем и восстанавливаем torch если перезаписан
    TORCH_NOW=$(python3 -c "import torch; print(torch.__version__)") && \
    echo "=== PyTorch после установки нод: ${TORCH_NOW} ===" && \
    if [ "$TORCH_BASE" != "$TORCH_NOW" ]; then \
        echo "!!! PyTorch перезаписан! Откатываем на ${TORCH_BASE}..." && \
        CUDA_TAG=$(echo "$TORCH_BASE" | grep -oP '\+cu\K[0-9]+') && \
        pip install "torch==${TORCH_BASE}" "torchvision" "torchaudio" \
            --index-url "https://download.pytorch.org/whl/cu${CUDA_TAG}" \
            --force-reinstall --quiet && \
        echo "=== PyTorch восстановлен: $(python3 -c 'import torch; print(torch.__version__)') ==="; \
    else \
        echo "=== PyTorch не тронут, всё ок ==="; \
    fi && \
    deactivate

COPY custom_setup.sh /custom_setup.sh
RUN chmod +x /custom_setup.sh
RUN sed -i '/^# Start application manager/i # === Custom setup: models ===\n/custom_setup.sh\n' /pre_start.sh
