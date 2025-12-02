#!/bin/bash
# Minimal ComfyUI startup script for Vast.ai
set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 ComfyUI Quick Start"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🕒 Started: $(date)"

cd /root || cd /workspace || cd ~

# Clone ComfyUI if not exists
if [ ! -d "ComfyUI" ]; then
    echo "📦 Cloning ComfyUI..."
    git clone https://github.com/comfyanonymous/ComfyUI.git
    cd ComfyUI

    echo "📦 Installing dependencies..."
    pip install --no-cache-dir -r requirements.txt
else
    echo "✅ ComfyUI already exists"
    cd ComfyUI
fi

echo "🎬 Starting ComfyUI server..."
echo "🌐 Will be available at: http://\$PUBLIC_IP:8188"

# Start ComfyUI (nohup to keep running)
nohup python main.py --listen 0.0.0.0 --port 8188 > /tmp/comfyui.log 2>&1 &

echo "✅ ComfyUI started!"
echo "📝 Logs: tail -f /tmp/comfyui.log"
echo "🕒 Finished: $(date)"
