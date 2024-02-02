# Game Chain Contracts

Disclaimer: This is very much a work in progess.

# Development

The development stack consists of:

- An anvil node for etherum local development
- Scripts deploying a mud world and all or selected modules for developments

We are running the anvil node explicitly ourselves for three reasons:

- Making the development environment as similar to live ones as possible
- Decoupling from MUD's opinionated dev tools
- Having a stand alone development node allows us to deploy modules in a deterministic an selective manner

To start developing against the world and all of the CCP modules run:

```
pnpm run dev
```

You can also run

```
./dev module1,module2  # comma separated list of modules to load into the base world
```

To interact with the MUD world in a raw fashion you can use the cast CLI tool.

```bash
DEV_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
DEV_WORLD_ADDRESS=0x6e9474e9c83676b9a71133ff96db43e7aa0a4342
cast send $DEV_WORLD_ADDRESS --rpc-url http://localhost:8545 --private-key $DEV_PRIVATE_KEY  "createSmartStorageUnit(string,string)" "name" "description"
```

In the example above the method being invoked belongs to a system in the root namespace. To invoke a method in a different namespace i.e. the non-root namespace. The method name should be prefixed with the namespace name and an underscore e.g. `namespaced_createSmartStorageUnit`.
