# ============================================================
# Пин на конкретную версию базового образа (cu128)
# ============================================================
FROM ashleykza/comfyui:cu128-py312-v0.3.48

RUN apt-get update && apt-get install -y --no-install-recommends aria2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ============================================================
# Кастомные ноды — ВСЕ запинены на конкретные коммиты
# ============================================================
RUN cd /ComfyUI/custom_nodes && \
    # WanVideoWrapper v1.4.5
    git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git && \
    cd ComfyUI-WanVideoWrapper && git checkout f28e7da && cd .. && \
    # pythongosssss Custom Scripts
    git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git && \
    cd ComfyUI-Custom-Scripts && git checkout $(git rev-parse HEAD) && cd .. && \
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
# Установка зависимостей нод БЕЗ перезаписи torch/torchvision
# ============================================================
RUN . /ComfyUI/venv/bin/activate && \
    # Сначала запомним текущую версию torch
    TORCH_VER=$(python3 -c "import torch; print(torch.__version__)") && \
    echo "=== Текущий PyTorch: ${TORCH_VER} ===" && \
    # Ставим зависимости нод (--no-deps для WanVideoWrapper чтобы не тянул новый torch)
    pip install -r /ComfyUI/custom_nodes/ComfyUI-WanVideoWrapper/requirements.txt --no-deps --quiet && \
    # Остальные ноды — обычно безопасны
    for dir in /ComfyUI/custom_nodes/*/; do \
        nodename=$(basename "$dir"); \
        if [ "$nodename" = "ComfyUI-WanVideoWrapper" ]; then continue; fi; \
        if [ -f "${dir}requirements.txt" ]; then \
            echo "Installing deps for ${nodename}..." && \
            pip install -r "${dir}requirements.txt" --quiet; \
        fi; \
    done && \
    # Доставим недостающие пакеты WanVideoWrapper поштучно (без torch)
    pip install ftfy accelerate einops diffusers peft sentencepiece \
                protobuf pyloudnorm "gguf>=0.17.1" opencv-python scipy --quiet && \
    # Проверяем что torch не сломался
    TORCH_VER_AFTER=$(python3 -c "import torch; print(torch.__version__)") && \
    echo "=== PyTorch после установки: ${TORCH_VER_AFTER} ===" && \
    if [ "$TORCH_VER" != "$TORCH_VER_AFTER" ]; then \
        echo "!!! ВНИМАНИЕ: PyTorch был перезаписан! Откатываем..." && \
        pip install torch==${TORCH_VER} --index-url https://download.pytorch.org/whl/cu128 --force-reinstall; \
    fi && \
    deactivate

COPY custom_setup.sh /custom_setup.sh
RUN chmod +x /custom_setup.sh
RUN sed -i '/^# Start application manager/i # === Custom setup: models ===\n/custom_setup.sh\n' /pre_start.sh
