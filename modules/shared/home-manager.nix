{ config, pkgs, lib, ... }:

let 
  name = "Senai Teklemichael";
  user = "steklemichael";
  email = "steklemichael@integralads.com"; 
in
{
  direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

  zsh = {
    enable = true;
    autocd = false;
    cdpath = [ "~/.local/share/src" ];
    plugins = [
      {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
          name = "powerlevel10k-config";
          src = lib.cleanSource ./config;
          file = "p10k.zsh";
      }
    ];
    initExtraFirst = ''
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi

      if [[ "$(uname)" == "Linux" ]]; then
        alias pbcopy='xclip -selection clipboard'
      fi

      # Define variables for directories
      export PATH=$HOME/.pnpm-packages/bin:$HOME/.pnpm-packages:$PATH
      export PATH=$HOME/.npm-packages/bin:$HOME/bin:$PATH
      export PATH=$HOME/.composer/vendor/bin:$PATH
      export PATH=$HOME/.local/share/bin:$PATH

      export PNPM_HOME=~/.pnpm-packages
      alias pn=pnpm
      alias px=pnpx

      # Remove history data we don't want to see
      export HISTIGNORE="pwd:ls:cd"

      # Ripgrep alias
      alias search='rg -p --glob "!node_modules/*" --glob "!vendor/*" "$@"'

      alias watch="tmux new-session -d -s watch-session 'bash ./bin/watch.sh'"
      alias unwatch='tmux kill-session -t watch-session'

      # Use difftastic, syntax-aware diffing
      alias diff=difft

      # Always color ls and group directories
      alias ls='ls --color=auto'

      # Reboot into my dual boot Windows partition
      alias windows='systemctl reboot --boot-loader-entry=auto-windows'
    '';
  };

  git = {
    enable = true;
    ignores = [ "*.swp" ];
    userName = name;
    userEmail = email;
    lfs = {
      enable = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      core = {
	    editor = "vim";
        autocrlf = "input";
      };
      commit.gpgsign = false;
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };

  vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [ vim-airline vim-airline-themes copilot-vim vim-startify ];
    settings = { ignorecase = true; };
    extraConfig = ''
      "" General
      set number
      set history=1000
      set nocompatible
      set modelines=0
      set encoding=utf-8
      set scrolloff=3
      set showmode
      set showcmd
      set hidden
      set wildmenu
      set wildmode=list:longest
      set cursorline
      set ttyfast
      set nowrap
      set ruler
      set backspace=indent,eol,start
      set laststatus=2
      set clipboard=autoselect

      " Dir stuff
      set nobackup
      set nowritebackup
      set noswapfile
      set backupdir=~/.config/vim/backups
      set directory=~/.config/vim/swap

      " Relative line numbers for easy movement
      set relativenumber
      set rnu

      "" Whitespace rules
      set tabstop=8
      set shiftwidth=2
      set softtabstop=2
      set expandtab

      "" Searching
      set incsearch
      set gdefault

      "" Statusbar
      set nocompatible " Disable vi-compatibility
      set laststatus=2 " Always show the statusline
      let g:airline_theme='bubblegum'
      let g:airline_powerline_fonts = 1

      "" Local keys and such
      let mapleader=","
      let maplocalleader=" "

      "" Change cursor on mode
      :autocmd InsertEnter * set cul
      :autocmd InsertLeave * set nocul

      "" File-type highlighting and configuration
      syntax on
      filetype on
      filetype plugin on
      filetype indent on

      "" Paste from clipboard
      nnoremap <Leader>, "+gP

      "" Copy from clipboard
      xnoremap <Leader>. "+y

      "" Move cursor by display lines when wrapping
      nnoremap j gj
      nnoremap k gk

      "" Map leader-q to quit out of window
      nnoremap <leader>q :q<cr>

      "" Move around split
      nnoremap <C-h> <C-w>h
      nnoremap <C-j> <C-w>j
      nnoremap <C-k> <C-w>k
      nnoremap <C-l> <C-w>l

      "" Easier to yank entire line
      nnoremap Y y$

      "" Move buffers
      nnoremap <tab> :bnext<cr>
      nnoremap <S-tab> :bprev<cr>

      "" Like a boss, sudo AFTER opening the file to write
      cmap w!! w !sudo tee % >/dev/null

      let g:startify_lists = [
        \ { 'type': 'dir',       'header': ['   Current Directory '. getcwd()] },
        \ { 'type': 'sessions',  'header': ['   Sessions']       },
        \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      }
        \ ]

      let g:startify_bookmarks = [
        \ '~/.local/share/src',
        \ ]

      let g:airline_theme='bubblegum'
      let g:airline_powerline_fonts = 1
      '';
     };

  ssh = {
    enable = true;
    includes = [
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
        "/home/${user}/.ssh/config_external"
      )
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        "/Users/${user}/.ssh/config_external"
      )
    ];
    matchBlocks = {
      "github.com" = {
        identitiesOnly = true;
        identityFile = [
          (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
            "/home/${user}/.ssh/id_github"
          )
          (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
            "/Users/${user}/.ssh/id_github"
          )
        ];
      };
    };
  };

  # Home Manager configuration for dotfiles
  home.file = {
    # Bat configuration
    ".config/bat/config".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/bat/config";
    ".config/bat/themes/Catppuccin Frappe.tmTheme".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/bat/themes/Catppuccin Frappe.tmTheme";
    ".config/bat/themes/Catppuccin Latte.tmTheme".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/bat/themes/Catppuccin Latte.tmTheme";
    ".config/bat/themes/Catppuccin Macchiato.tmTheme".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/bat/themes/Catppuccin Macchiato.tmTheme";
    ".config/bat/themes/Catppuccin Mocha.tmTheme".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/bat/themes/Catppuccin Mocha.tmTheme";

    # Btop configuration
    ".config/btop/btop.conf".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/btop/btop.conf";

    # Fish shell configuration
    ".config/fish/config.fish".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/fish/config.fish";
    ".config/fish/fish_plugins".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/fish/fish_plugins";
    ".config/fish/fish_variables".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/fish/fish_variables";
    ".config/fish/conf.d".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/fish/conf.d";
    ".config/fish/functions".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/fish/functions";

    # FZF configuration
    ".config/fzf/fzf".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/fzf/fzf";

    # GitHub CLI configuration
    ".config/gh/config.yml".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/gh/config.yml";
    ".config/gh/hosts.yml".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/gh/hosts.yml";

    # Ripgrep configuration
    ".config/ripgrep/ripgrep".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/ripgrep/ripgrep";

    # Wezterm configuration
    ".config/wezterm/wezterm.lua".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/wezterm/wezterm.lua";

    # Zellij configuration
    ".config/zellij/config.kdl".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/zellij/config.kdl";
    ".config/zellij/themes/catppuccin.kdl".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/zellij/themes/catppuccin.kdl";
    ".config/zellij/themes/catppuccin.yaml".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/zellij/themes/catppuccin.yaml";

    # Starship configuration
    ".config/starship/starship.toml".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/starship/starship.toml";

    # Neovim configuration
    ".config/nvim/init.lua".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/nvim/init.lua";
    ".config/nvim/lazy-lock.json".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/nvim/lazy-lock.json";
    ".config/nvim/lua".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/nvim/lua";
    ".config/nvim/spell/en.utf-8.add".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/nvim/spell/en.utf-8.add";
    ".config/nvim/spell/en.utf-8.add.spl".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/nvim/spell/en.utf-8.add.spl";

    # K9s configuration
    ".config/k9s/config.yml".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/k9s/config.yml";
    ".config/k9s/skin.yml".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/k9s/skin.yml";

    # Mise configuration
    ".config/mise/config.toml".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/mise/config.toml";

    # Chezmoi state file
    # ".local/share/chezmoi/chezmoistate.boltdb".source = "${config.home.homeDirectory}/nixos-config/modules/shared/config/chezmoi/chezmoistate.boltdb";

  };
}
