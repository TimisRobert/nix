update:
    nix flake update
    nvim --headless "+Lazy! sync" +qa
    nh os switch
