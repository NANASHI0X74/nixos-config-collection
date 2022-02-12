builtins.mapAttrs (name: value: value // { file = ./${name}; }) {
  "psprices-token.age" = {
    publicKeys =
      [ (import ../../../resources/ssh-pubkeys.nix).negidio.root.host ];
    owner = "nginx";
    group = "nginx";
    mode = "440";
  };
}
