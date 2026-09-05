{ config, lib, pkgs, ... }:
{
  options = {
    ollama.enable = lib.mkEnableOption "Enable local Ollama server for LLMs (vulkan/rocm)";
  };

  config = lib.mkIf config.ollama.enable {
    services.ollama = {
      enable = true;
      # Prefer Vulkan backend for RDNA1 (RX 5700 XT). Less fragile than ROCm override.
      package = pkgs.ollama-vulkan;
      # Preload qwen2.5-coder:7b (quantized, fits 8GB VRAM)
      loadModels = [ "qwen2.5-coder:7b" ];
    };

    # ROCm fallback (commented):
    # If Vulkan doesn't perform on your hardware, switch to rocm package and
    # consider setting rocmOverrideGfx = "10.1.0" for RX 5700 XT (fragile).
    # services.ollama.package = pkgs.ollama-rocm;
  };
}
