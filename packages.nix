{ pkgs, ... }:

let
  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
    ref = "nixos-25.05";
  });
  agenix = builtins.fetchGit {
    url = "https://github.com/ryantm/agenix";
    ref = "main";
  };
in
{
  imports = [
    nixvim.nixosModules.nixvim
    "${agenix}/modules/age.nix"
  ];

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    atuin
    eza
    gcc
    git
    httpie
    jujutsu
    ripgrep
    rustup
    zellij

    (callPackage "${agenix}/pkgs/agenix.nix" {})
  ];

  programs.fish = {
    enable = true;
    shellInit = ''
      fish_vi_key_bindings
      set fish_cursor_default block
      set fish_cursor_insert line
      set fish_cursor_replace_one underscore
      set fish_cursor_visual block
    '';
    interactiveShellInit = ''
      set -g fish_greeting

      atuin init fish --disable-up-arrow | source
    '';
  };
  users.defaultUserShell = pkgs.fish;
  programs.starship.enable = true;

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;

    colorschemes.tokyonight = {
      enable = true;
      settings.style = "storm";
    };

    lsp.servers.nixd.enable = true;

    opts.number = true;

    plugins = {
      lspconfig.enable = true;
      lualine.enable = true;
      nvim-tree = {
        enable = true;
        actions.openFile.quitOnOpen = true;
      };
      sandwich.enable = true;
      sleuth.enable = true;
      spider = {
        enable = true;
        keymaps.motions = {
          w = "w";
          e = "e";
          b = "b";
          ge = "ge";
        };
      };
      treesitter = {
        enable = true;
        settings = {
          auto_install = true;
          highlight.enable = true;
        };
      };
      treesitter-context.enable = true;
      web-devicons.enable = true;
    };

    keymaps = [
      {
        action = "<cmd>NvimTreeFindFile<cr>";
        key = "<leader>n";
      }
    ];
  };

  programs.bat = {
    enable = true;
    extraPackages = with pkgs.bat-extras; [
      batman
      prettybat
    ];
  };

  programs.htop.enable = true;
}
