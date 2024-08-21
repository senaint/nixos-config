{ pkgs, ... }:

with pkgs; [
  # General packages for development and system management

  age
  age-plugin-yubikey
  awscli2
  bash-completion
  bat
  btop
  chezmoi
  coreutils
  difftastic
  dust
  evil-helix
  eza
  fd
  fish
  font-awesome
  fx
  fzf
  glow
  gnupg
  go
  gopls
  hack-font
  helm
  jpegoptim
  jq
  just
  k9s
  kubectx
  kustomize
  lazygit
  libfido2
  meslo-lgs-nf
  neovim
  nerdfonts
  ngrok
  noto-fonts
  noto-fonts-emoji
  openai-whisper
  pngquant
  podman
  procs
  ripgrep
  rust
  sd
  starship
  steampipe
  tealdeer
  terraform
  tflint
  tree
  unrar
  unzip
  wezterm
  yazi
  zellij
  zip
  zoxide

  (pkgs.catppuccin)
  (pkgs.nerdfonts.override { fonts = [ "CaskaydiaCove" ]; })
  
  # Python packages
 # black
 # python311
 # python311Packages.virtualenv
]
