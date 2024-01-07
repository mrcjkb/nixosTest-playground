# nixosTest-playground

A playground for [`nixosTest`](https://nixos.org/manual/nixos/stable/index.html#sec-test-options-reference)

## Run all tests

```sh
nix flake check -Lv
```

## Run single test

```sh
nix build .#<package>
# e.g. nix build .#basic
```

## Interactive mode

```sh
nix run .#<package>.driverInteractive
```

## Credit:

- [@NorfairKing](https://github.com/NorfairKing)



