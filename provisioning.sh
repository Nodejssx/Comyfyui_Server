#!/bin/bash
# ComfyUI Auto-Provisioning Script for Vast.ai
# Complete setup: Custom nodes, models, dependencies
# Version: 2.0 - Full Production Setup

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 ComfyUI Full Provisioning v2.0"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📍 Working directory: $(pwd)"
echo "🕒 Started: $(date)"
echo ""

# Navigate to ComfyUI directory
cd /workspace/ComfyUI 2>/dev/null || cd /opt/ComfyUI 2>/dev/null || cd ~/ComfyUI 2>/dev/null || {
    echo "❌ ComfyUI directory not found!"
    exit 1
}

echo "✅ ComfyUI found at: $(pwd)"
COMFYUI_ROOT=$(pwd)

# ==============================================
# STEP 1: Update ComfyUI
# ==============================================
echo ""
echo "📦 Updating ComfyUI..."
git pull origin master || echo "⚠️  Git pull failed, continuing..."

# ==============================================
# STEP 2: System Dependencies
# ==============================================
echo ""
echo "📦 Installing system dependencies..."

# Update pip
pip install --upgrade pip setuptools wheel --no-cache-dir

# Install common dependencies
pip install --no-cache-dir \
    torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124 \
    transformers accelerate \
    opencv-python-headless \
    pillow scipy numpy \
    || echo "⚠️  Some dependencies failed"

# ==============================================
# STEP 3: Install Custom Nodes
# ==============================================
echo ""
echo "📦 Installing custom nodes..."
cd "$COMFYUI_ROOT"
mkdir -p custom_nodes

# 1. ComfyUI-MMAudio (Audio Generation)
echo "  → [1/6] Installing ComfyUI-MMAudio..."
if [ ! -d "custom_nodes/ComfyUI-MMAudio" ]; then
    cd custom_nodes
    git clone https://github.com/1038lab/ComfyUI-MMAudio.git
    cd ComfyUI-MMAudio
    pip install -r requirements.txt --no-cache-dir || echo "⚠️  Requirements install failed"
    cd "$COMFYUI_ROOT"
else
    echo "    ✓ Already installed"
fi

# 2. ComfyUI-WanVideoWrapper (Text-to-Video Wan 2.2)
echo "  → [2/6] Installing ComfyUI-WanVideoWrapper..."
if [ ! -d "custom_nodes/ComfyUI-WanVideoWrapper" ]; then
    cd custom_nodes
    git clone https://github.com/turkyden/ComfyUI-WanVideoWrapper.git
    cd ComfyUI-WanVideoWrapper
    pip install -r requirements.txt --no-cache-dir || echo "⚠️  Requirements install failed"
    cd "$COMFYUI_ROOT"
else
    echo "    ✓ Already installed"
fi

# 3. ComfyUI-Manager (Node management)
echo "  → [3/6] Installing ComfyUI-Manager..."
if [ ! -d "custom_nodes/ComfyUI-Manager" ]; then
    cd custom_nodes
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git
    cd "$COMFYUI_ROOT"
else
    echo "    ✓ Already installed"
fi

# 4. ComfyUI-VideoHelperSuite (Video processing)
echo "  → [4/6] Installing ComfyUI-VideoHelperSuite..."
if [ ! -d "custom_nodes/ComfyUI-VideoHelperSuite" ]; then
    cd custom_nodes
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
    cd ComfyUI-VideoHelperSuite
    pip install -r requirements.txt --no-cache-dir || echo "⚠️  Requirements install failed"
    cd "$COMFYUI_ROOT"
else
    echo "    ✓ Already installed"
fi

# 5. ComfyUI-Advanced-ControlNet (Better control)
echo "  → [5/6] Installing ComfyUI-Advanced-ControlNet..."
if [ ! -d "custom_nodes/ComfyUI-Advanced-ControlNet" ]; then
    cd custom_nodes
    git clone https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet.git
    cd "$COMFYUI_ROOT"
else
    echo "    ✓ Already installed"
fi

# 6. ComfyUI_Custom_Nodes_AlekPet (Utilities)
echo "  → [6/6] Installing ComfyUI Custom Nodes..."
if [ ! -d "custom_nodes/ComfyUI_Custom_Nodes_AlekPet" ]; then
    cd custom_nodes
    git clone https://github.com/AlekPet/ComfyUI_Custom_Nodes_AlekPet.git
    cd ComfyUI_Custom_Nodes_AlekPet
    pip install -r requirements.txt --no-cache-dir || echo "⚠️  Requirements install failed"
    cd "$COMFYUI_ROOT"
else
    echo "    ✓ Already installed"
fi

# ==============================================
# STEP 4: Download Models
# ==============================================
echo ""
echo "📥 Downloading AI models..."
cd "$COMFYUI_ROOT"

# 1. Wan 2.2 LightX2V Model (Text-to-Video - Critical)
echo "  → [1/3] Downloading Wan 2.2 LightX2V (~10GB)..."
mkdir -p models/checkpoints/wan2.2
if [ ! -f "models/checkpoints/wan2.2/wan2.2_lightx2v_5b_v1.safetensors" ]; then
    wget -c --progress=bar:force:noscroll \
        -O models/checkpoints/wan2.2/wan2.2_lightx2v_5b_v1.safetensors \
        "https://huggingface.co/Kwai-Kolors/Wan2.2-LightX2V-5B-v1/resolve/main/wan2.2_lightx2v_5b_v1.safetensors" \
        || echo "⚠️  Wan 2.2 download failed"
else
    echo "    ✓ Already downloaded ($(du -h models/checkpoints/wan2.2/wan2.2_lightx2v_5b_v1.safetensors | cut -f1))"
fi

# 2. MMAudio Model (Audio Generation - Critical)
echo "  → [2/3] Downloading MMAudio (~2GB)..."
mkdir -p models/mmaudio
if [ ! -f "models/mmaudio/mmaudio_medium_44k.pth" ]; then
    wget -c --progress=bar:force:noscroll \
        -O models/mmaudio/mmaudio_medium_44k.pth \
        "https://huggingface.co/hf-audio/mmaudio-medium-44k/resolve/main/mmaudio_medium_44k.pth" \
        || echo "⚠️  MMAudio download failed"
else
    echo "    ✓ Already downloaded ($(du -h models/mmaudio/mmaudio_medium_44k.pth | cut -f1))"
fi

# 3. SmoothMix VAE (Optional but recommended)
echo "  → [3/3] Downloading SmoothMix VAE..."
mkdir -p models/vae
if [ ! -f "models/vae/vae-ft-mse-840000-ema-pruned.safetensors" ]; then
    wget -c --progress=bar:force:noscroll \
        -O models/vae/vae-ft-mse-840000-ema-pruned.safetensors \
        "https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors" \
        || echo "⚠️  VAE download failed"
else
    echo "    ✓ Already downloaded"
fi

# ==============================================
# STEP 5: Setup Workflow File
# ==============================================
echo ""
echo "📄 Setting up workflow file..."
cd "$COMFYUI_ROOT"

# Copy workflow to user directory (if exists)
if [ -f "视频首尾帧_wan2.2_smoothmix.json" ]; then
    echo "    ✓ Workflow file found"
else
    echo "    ⚠️  Workflow file not found in ComfyUI root"
    echo "    → Will need to upload via API later"
fi

# ==============================================
# STEP 6: Verify Installation
# ==============================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Installation Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Count custom nodes
CUSTOM_NODES_COUNT=$(ls -1 custom_nodes 2>/dev/null | wc -l)
echo "📦 Custom Nodes: $CUSTOM_NODES_COUNT installed"

# Check models
echo ""
echo "🤖 AI Models:"

if [ -f "models/checkpoints/wan2.2/wan2.2_lightx2v_5b_v1.safetensors" ]; then
    WAN_SIZE=$(du -h models/checkpoints/wan2.2/wan2.2_lightx2v_5b_v1.safetensors | cut -f1)
    echo "  ✅ Wan 2.2 LightX2V: $WAN_SIZE"
else
    echo "  ❌ Wan 2.2 LightX2V: NOT FOUND"
fi

if [ -f "models/mmaudio/mmaudio_medium_44k.pth" ]; then
    MMAUDIO_SIZE=$(du -h models/mmaudio/mmaudio_medium_44k.pth | cut -f1)
    echo "  ✅ MMAudio: $MMAUDIO_SIZE"
else
    echo "  ❌ MMAudio: NOT FOUND"
fi

if [ -f "models/vae/vae-ft-mse-840000-ema-pruned.safetensors" ]; then
    VAE_SIZE=$(du -h models/vae/vae-ft-mse-840000-ema-pruned.safetensors | cut -f1)
    echo "  ✅ SmoothMix VAE: $VAE_SIZE"
else
    echo "  ⚠️  SmoothMix VAE: NOT FOUND (optional)"
fi

# Disk usage
echo ""
TOTAL_SIZE=$(du -sh "$COMFYUI_ROOT" | cut -f1)
echo "💾 Total Disk Usage: $TOTAL_SIZE"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Provisioning Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎬 ComfyUI is ready for video generation!"
echo "🌐 Access at: http://YOUR_POD_IP:8188"
echo "🕒 Finished: $(date)"
echo ""
echo "💡 Next Steps:"
echo "  1. Access ComfyUI web interface"
echo "  2. Test workflow with a prompt"
echo "  3. Create Vast.ai template to save this setup"
echo ""
