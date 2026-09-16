#!/bin/bash

llama-server \
  --hf-repo "ggml-org/Qwen3.8-27B-GGUF:Q4_K_M" \
  --alias "qwen3.8-27b" \
  --host 127.0.0.1 \
  --port 8080 \
  --n-gpu-layers 26 \
  --ctx-size 100000 \
  --flash-attn on \
  --cache-type-k q8_0 \
  --cache-type-v q8_0 \
  --spec-type draft-mtp \
  --reasoning-format deepseek \
  --reasoning-effort xhigh \
  --chat-template-kwargs '{"preserve_thinking":true}'
