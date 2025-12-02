#!/bin/bash
# ComfyUI Auto-Provisioning Script for Vast.ai
# Installs custom nodes and downloads models

set -e

echo "🚀 Starting ComfyUI provisioning..."
echo "📍 Working directory: $(pwd)"

# Navigate to ComfyUI directory
cd /workspace/ComfyUI 2>/dev/null || cd /opt/ComfyUI 2>/dev/null || cd ~/ComfyUI 2>/dev/null || {
    echo "❌ ComfyUI directory not found!"
    exit 1
}

echo "✅ ComfyUI found at: $(pwd)"

# ==============================================
# STEP 1: Update ComfyUI
# ==============================================
echo ""
echo "📦 Updating ComfyUI..."
git pull origin master || echo "⚠️  Git pull failed, continuing..."

# ==============================================
# STEP 2: Install Custom Nodes
# ==============================================
echo ""
echo "📦 Installing custom nodes..."

# Create custom_nodes directory if not exists
mkdir -p custom_nodes

# ComfyUI-MMAudio (Audio Generation)
echo "  → Installing ComfyUI-MMAudio..."
if [ ! -d "custom_nodes/ComfyUI-MMAudio" ]; then
    cd custom_nodes
    git clone https://github.com/1038lab/ComfyUI-MMAudio.git
    cd ComfyUI-MMAudio
    pip install -r requirements.txt --no-cache-dir || echo "⚠️  Requirements install failed"
    cd ../..
else
    echo "    ✓ Already installed"
fi

# ComfyUI-WanVideoWrapper (Text-to-Video Wan 2.2)
echo "  → Installing ComfyUI-WanVideoWrapper..."
if [ ! -d "custom_nodes/ComfyUI-WanVideoWrapper" ]; then
    cd custom_nodes
    git clone https://github.com/turkyden/ComfyUI-WanVideoWrapper.git
    cd ComfyUI-WanVideoWrapper
    pip install -r requirements.txt --no-cache-dir || echo "⚠️  Requirements install failed"
    cd ../..
else
    echo "    ✓ Already installed"
fi

# ==============================================
# STEP 3: Download Models
# ==============================================
echo ""
echo "📥 Downloading models..."

# Wan 2.2 LightX2V Model (Text-to-Video)
echo "  → Downloading Wan 2.2 LightX2V (~10GB)..."
mkdir -p models/checkpoints/wan2.2
cd models/checkpoints/wan2.2

if [ ! -f "wan2.2_lightx2v_5b_v1.safetensors" ]; then
    wget -c --progress=bar:force:noscroll \
        -O wan2.2_lightx2v_5b_v1.safetensors \
        "https://huggingface.co/Kwai-Kolors/Wan2.2-LightX2V-5B-v1/resolve/main/wan2.2_lightx2v_5b_v1.safetensors" \
        || echo "⚠️  Wan 2.2 download failed"
else
    echo "    ✓ Already downloaded"
fi
cd ../../..

# MMAudio Model
echo "  → Downloading MMAudio (~2GB)..."
mkdir -p models/mmaudio
cd models/mmaudio

if [ ! -f "mmaudio_medium_44k.pth" ]; then
    wget -c --progress=bar:force:noscroll \
        -O mmaudio_medium_44k.pth \
        "https://huggingface.co/hf-audio/mmaudio-medium-44k/resolve/main/mmaudio_medium_44k.pth" \
        || echo "⚠️  MMAudio download failed"
else
    echo "    ✓ Already downloaded"
fi
cd ../..

# ==============================================
# STEP 4: Verify Installation
# ==============================================
echo ""
echo "✅ Provisioning complete!"
echo ""
echo "📊 Installation Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Count custom nodes
CUSTOM_NODES_COUNT=$(ls -1 custom_nodes 2>/dev/null | wc -l)
echo "  Custom Nodes: $CUSTOM_NODES_COUNT installed"

# Check Wan 2.2 model
if [ -f "models/checkpoints/wan2.2/wan2.2_lightx2v_5b_v1.safetensors" ]; then
    WAN_SIZE=$(du -h models/checkpoints/wan2.2/wan2.2_lightx2v_5b_v1.safetensors | cut -f1)
    echo "  ✓ Wan 2.2 LightX2V: $WAN_SIZE"
else
    echo "  ✗ Wan 2.2 LightX2V: NOT FOUND"
fi

# Check MMAudio model
if [ -f "models/mmaudio/mmaudio_medium_44k.pth" ]; then
    MMAUDIO_SIZE=$(du -h models/mmaudio/mmaudio_medium_44k.pth | cut -f1)
    echo "  ✓ MMAudio: $MMAUDIO_SIZE"
else
    echo "  ✗ MMAudio: NOT FOUND"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎬 ComfyUI is ready for video generation!"
echo "🌐 Access at: http://YOUR_POD_IP:8188"
echo ""
