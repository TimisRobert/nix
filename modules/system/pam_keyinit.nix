{lib, ...}: {
  options.security.pam.services = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      config.text = lib.mkDefault (lib.mkAfter "session required pam_keyinit.so force revoke");
    });
  };
}
