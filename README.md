# ComfyUI Server - Vast.ai Provisioning

Auto-provisioning script for ComfyUI on Vast.ai GPU pods.

## What This Does

Automatically installs:
- ✅ ComfyUI-MMAudio (Audio generation)
- ✅ ComfyUI-WanVideoWrapper (Text-to-Video)
- ✅ Wan 2.2 LightX2V model (~10GB)
- ✅ MMAudio model (~2GB)

## Usage

**Provisioning Script URL:**
```
https://raw.githubusercontent.com/Nodejssx/Comyfyui_Server/main/provisioning.sh
```

Use this URL when creating Vast.ai instances.

## Models Included

| Model | Size | Purpose |
|-------|------|---------|
| Wan 2.2 LightX2V | ~10GB | Text-to-Video generation (8x faster) |
| MMAudio Medium | ~2GB | Audio generation for videos |

## Setup Time

- First run: ~5-10 minutes (model downloads)
- Subsequent runs: ~1 minute (cached)

## Requirements

- Vast.ai account
- Docker image: `ghcr.io/ai-dock/comfyui:latest`
- Minimum 50GB storage
- RTX 4090 recommended

---

Generated for UGC video pipeline automation.
