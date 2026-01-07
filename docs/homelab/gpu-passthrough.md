# GPU Passthrough Setup (Quadro M4000)

**Status:** Fully operational
**Completed:** December 20, 2025
**GPU:** NVIDIA Quadro M4000 (8GB GDDR5, 1664 CUDA cores, Maxwell)

---

## Configuration Summary

| Component | Setting |
|-----------|---------|
| **Host Driver** | vfio-pci (passthrough to VM) |
| **VM Driver** | nvidia-driver-535.274.02, CUDA 12.2 |
| **IOMMU Group** | 45 (GPU + Audio isolated) |
| **VM Machine Type** | q35 (required for PCIe passthrough) |
| **VM Network Interface** | `enp6s18` (changed from `ens18` due to q35) |

---

## Host Configuration (prox-tower)

### GRUB
`/etc/default/grub`:
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"
```

### VFIO
`/etc/modprobe.d/vfio.conf`:
```
options vfio-pci ids=10de:13f1,10de:0fbb
softdep nouveau pre: vfio-pci
softdep snd_hda_intel pre: vfio-pci
```

### Blacklist
`/etc/modprobe.d/blacklist-nouveau.conf`:
```
blacklist nouveau
blacklist nvidiafb
options nouveau modeset=0
```

### VM 101 PCI Config
```
hostpci0: 0000:01:00,pcie=1,x-vga=1
machine: q35
```

---

## Performance Results

### Ollama LLM Inference

| Model | VRAM Used | Prompt Eval | Token Gen |
|-------|-----------|-------------|-----------|
| llama3.2:3b | 4.2 GB | 78 tok/s | 25 tok/s |
| qwen2.5:7b | 6.8 GB | 104 tok/s | 12 tok/s |
| phi4:14b | N/A | N/A | Exceeds 8GB |

### Model Compatibility

- **Full GPU:** All models ≤7B
- **Hybrid GPU/CPU:** 14B-18B models via `-hybrid` variants
- **CPU Only:** 19GB+ models (slow: 70B=1.47 tok/s)

---

## Hybrid GPU Offloading

Large models (>8GB VRAM) run in hybrid mode - part GPU, part CPU RAM.

### Pre-configured Hybrid Models

| Model | GPU Layers | VRAM Used | Speedup |
|-------|------------|-----------|---------|
| `phi4-hybrid` | 24 | ~7.9GB | 2x |
| `qwen3-hybrid` | 24 | ~7.9GB | ~2x |
| `devstral-hybrid` | 20 | ~6GB | ~1.5x |

### Usage
```bash
# Pre-configured hybrid
ollama run phi4-hybrid "Your prompt"

# Manual GPU layers
ollama run phi4:14b "prompt" --num-gpu 24

# Via API
curl http://localhost:11434/api/generate -d '{
  "model": "phi4:14b",
  "prompt": "...",
  "options": {"num_gpu": 24}
}'
```

---

## Creating Custom Model Variants

Ollama variants only store config changes, not duplicate weights.

### Quick Hybrid Model
```bash
ssh jaded@192.168.1.126 'cat > /tmp/Modelfile << EOF
FROM model-name:tag
PARAMETER num_gpu 24
EOF
ollama create model-hybrid -f /tmp/Modelfile'
```

### Full Modelfile Reference
```dockerfile
FROM llama3.2:3b
PARAMETER num_gpu 24           # GPU layers (0 = CPU only)
PARAMETER num_ctx 16384        # Context window
PARAMETER temperature 0.7      # 0.0-2.0 (lower = deterministic)
PARAMETER top_p 0.9
PARAMETER top_k 40
PARAMETER repeat_penalty 1.1
PARAMETER stop "<|endoftext|>"
SYSTEM """You are a helpful assistant."""
```

### num_gpu Guidelines

| Model Size | Recommended | VRAM Used |
|------------|-------------|-----------|
| 1-3B | 99 (all) | 2-4 GB |
| 7B | 30-35 | 6-8 GB |
| 14B | 24-26 | 7-8 GB |
| 30B+ | 18-22 | 7-8 GB |

### Managing Variants
```bash
ollama list                        # List all
ollama show model --modelfile      # Show config
ollama rm model-variant            # Delete variant
ollama cp old-name new-name        # Copy/rename
```

---

## Verification Commands

```bash
# GPU status in VM
ssh jaded@192.168.1.126 "nvidia-smi"

# VRAM usage
ssh jaded@192.168.1.126 "nvidia-smi --query-gpu=memory.used,memory.total --format=csv"

# Test Ollama GPU
ssh jaded@192.168.1.126 "ollama run llama3.2:3b 'Hello' --verbose 2>&1 | grep 'eval rate'"

# Check host vfio binding
ssh root@192.168.2.249 "lspci -nnk -s 01:00 | grep 'driver in use'"
# Should show: vfio-pci
```

---

## Troubleshooting

### GPU Not Showing in VM
```bash
# Host: Check vfio binding
lspci -nnk -s 01:00

# Verify IOMMU enabled
dmesg | grep -i dmar
```

### nvidia-smi Not Working
```bash
lspci | grep -i nvidia    # Check visible
lsmod | grep nvidia       # Check driver
sudo apt install --reinstall nvidia-driver-535
```

### Network Broken After Passthrough
- q35 changes network device names
- Check `ip link` for new name (e.g., `enp6s18`)
- Update `/etc/netplan/*.yaml`
- `sudo netplan apply`

### 14B+ Models Crashing
- Quadro M4000 = 8GB VRAM
- Use hybrid mode with num_gpu 24 or lower
- 19GB+ models require num_gpu 0 (CPU only)
