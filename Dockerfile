FROM ashleykza/comfyui:latest

RUN apt-get update && apt-get install -y --no-install-recommends aria2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN cd /ComfyUI/custom_nodes && \
    git clone --depth 1 https://github.com/Lightricks/ComfyUI-LTXVideo.git && \
    git clone --depth 1 https://github.com/rgthree/rgthree-comfy.git && \
    git clone --depth 1 https://github.com/kijai/ComfyUI-KJNodes.git && \
    git clone --depth 1 https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git && \
    git clone --depth 1 https://github.com/ltdrdata/was-node-suite-comfyui.git && \
    git clone --depth 1 https://github.com/kijai/ComfyUI-MelBandRoFormer.git

RUN . /ComfyUI/venv/bin/activate && \
    for dir in /ComfyUI/custom_nodes/*/; do \
        if [ -f "${dir}requirements.txt" ]; then \
            echo "Installing deps for $(basename $dir)..." && \
            pip install -r "${dir}requirements.txt" --quiet; \
        fi; \
    done && \
    deactivate

COPY custom_setup.sh /custom_setup.sh
RUN chmod +x /custom_setup.sh
RUN sed -i '/^# Start application manager/i # === Custom setup: models ===\n/custom_setup.sh\n' /pre_start.sh