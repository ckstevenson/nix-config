{ config, lib, osConfig, pkgs, ... }:
{
  options = {
    alacrittyFontSize = lib.mkOption {
      type = lib.types.int;
      default = if pkgs.stdenv.hostPlatform.isDarwin then 16 else 14;
    };
  };

  config = lib.mkIf ((osConfig.desktop.enable or false) || pkgs.stdenv.hostPlatform.isDarwin) {
    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          size = config.alacrittyFontSize;
        } // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          normal = {
            family = "DejaVuSansM Nerd Font";
            style = "Regular";
          };
          bold = {
            family = "DejaVuSansM Nerd Font";
            style = "Bold";
          };
          italic = {
            family = "DejaVuSansM Nerd Font";
            style = "Italic";
          };
        };

        window = {
          decorations = "buttonless";
        };

        scrolling = {
          history = 50000;
        };

        keyboard.bindings = [
          { key = "Return"; mods = "Control|Shift"; action = "SpawnNewInstance"; }
          { key = "V"; mods = "Alt"; action = "Paste"; }
          { key = "C"; mods = "Alt"; action = "Copy"; }
          { key = "J"; mods = "Alt"; action = "ScrollLineDown"; }
          { key = "K"; mods = "Alt"; action = "ScrollLineUp"; }
          { key = "U"; mods = "Alt"; action = "ScrollHalfPageUp"; }
          { key = "D"; mods = "Alt"; action = "ScrollHalfPageDown"; }
          { key = "Key0"; mods = "Alt"; action = "ResetFontSize"; }
          { key = "K"; mods = "Shift|Alt"; action = "IncreaseFontSize"; }
          { key = "J"; mods = "Shift|Alt"; action = "DecreaseFontSize"; }
        ];

        hints.enabled = [
          {
            # Nix indented strings pass backslashes through. json2x then
            # writes TOML, so use one slash here for regex escapes.
            regex = ''(ipfs:|ipns:|magnet:|mailto:|gemini://|gopher://|https://|http://|news:|file:|git://|ssh:|ftp://)[^\u0000-\u001F\u007F-\u009F<>"\s{-}\^⟨⟩`\\]+'';
            command =
              if pkgs.stdenv.hostPlatform.isDarwin
              then { program = "open"; args = [ ]; }
              else { program = "xdg-open"; args = [ ]; };
            hyperlinks = true;
            post_processing = true;
            mouse.enabled = true;
            binding = {
              key = "L";
              mods = "Alt";
            };
          }
        ];

        colors = with config.colorScheme.palette; {
          bright = {
            black = "0x${base03}";
            blue = "0x${base0D}";
            cyan = "0x${base0C}";
            green = "0x${base0B}";
            magenta = "0x${base0E}";
            red = "0x${base08}";
            white = "0x${base06}";
            yellow = "0x${base09}";
          };
          cursor = {
            cursor = "0x${base06}";
            text = "0x${base06}";
          };
          normal = {
            black = "0x${base00}";
            blue = "0x${base0D}";
            cyan = "0x${base0C}";
            green = "0x${base0B}";
            magenta = "0x${base0E}";
            red = "0x${base08}";
            white = "0x${base06}";
            yellow = "0x${base0A}";
          };
          primary = {
            background = "0x${base00}";
            foreground = "0x${base06}";
          };
        };
      };
    };
  };
}
