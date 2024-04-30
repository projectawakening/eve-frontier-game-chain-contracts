// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { PuppetModule } from "@latticexyz/world-modules/src/modules/puppet/PuppetModule.sol";
import { IERC20Mintable } from "@latticexyz/world-modules/src/modules/erc20-puppet/IERC20Mintable.sol";
import { ERC20Module } from "@latticexyz/world-modules/src/modules/erc20-puppet/ERC20Module.sol";
import { registerERC20 } from "@latticexyz/world-modules/src/modules/erc20-puppet/registerERC20.sol";

import { ERC20MetadataData } from "@latticexyz/world-modules/src/modules/erc20-puppet/tables/ERC20Metadata.sol";

contract CreateMintERC20 is Script {
  function run(address worldAddress) external {
    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    string memory namespace = vm.envString("ERC20_NAMESPACE");
    string memory name = vm.envString("ERC20_NAME");
    string memory symbol = vm.envString("ERC20_SYMBOL");
    uint8 decimals = uint8(vm.envUint("ERC20_DECIMALS"));
    address to = vm.envAddress("MINT_TO");
    uint256 amount = vm.envUint("MINT_AMOUNT");

    vm.startBroadcast(deployerPrivateKey);
    // TODO: Need to make a ERC20 Factory that feeds into the static data module
    IERC20Mintable erc20Token;
    StoreSwitch.setStoreAddress(address(world));
    erc20Token = registerERC20(
      world,
      stringToBytes14(namespace),
      ERC20MetadataData({ decimals: decimals, name: name, symbol: symbol})
    );

    console.log("Deploying ERC20 token with address: ", address(erc20Token));

    address erc20Address = address(erc20Token);

    IERC20Mintable erc20 = IERC20Mintable(erc20Address);
    erc20.mint(to, amount * 1 ether);

    console.log("minting to: ", address(to));
    console.log("amount: ", amount * 1 ether);

    vm.stopBroadcast();
  }

  function stringToBytes14(string memory str) public pure returns (bytes14) {
        bytes memory tempBytes = bytes(str);

        // Ensure the bytes array is not longer than 14 bytes.
        // If it is, this will truncate the array to the first 14 bytes.
        // If it's shorter, it will be padded with zeros.
        require(tempBytes.length <= 14, "String too long");

        bytes14 converted;
        for (uint i = 0; i < tempBytes.length; i++) {
            converted |= bytes14(tempBytes[i] & 0xFF) >> (i * 8);
        }

        return converted;
    }
}
