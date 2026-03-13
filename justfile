update:
    nix flake update
    nvim --headless "+Lazy! sync" +qa
    claude update
    nh os switch
