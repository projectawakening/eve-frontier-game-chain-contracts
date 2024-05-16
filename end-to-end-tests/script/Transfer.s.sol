pragma solidity >=0.8.20;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@eve/frontier-world/src/codegen/world/IWorld.sol";
import { InventoryItem } from "@eve/frontier-world/src/modules/inventory/types.sol";
import { SmartStorageUnitLib } from "@eve/frontier-world/src/modules/smart-storage-unit/SmartStorageUnitLib.sol";
import { InventoryLib } from "@eve/frontier-world/src/modules/inventory/InventoryLib.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eve/common-constants/src/constants.sol";

contract Transfer is Script {
  using InventoryLib for InventoryLib.World;

  function run(address worldAddress) public {
    StoreSwitch.setStoreAddress(worldAddress);

    InventoryLib.World memory inventory = InventoryLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    // SSU ID
    uint256 smartObjectId = uint256(88750310860499360732505883297808147371421307735913825520559343264455778961940);

    // LOAD THE KEY THAT IS INTERACTING WITH THE TRANSFER FUNCTION
    uint256 ephemeralPrivateKey = uint256(0xd91fe4a592c3c739c6d800eea076c87d1c5a84cfbb03d2e6a4d7b1e9a2d48979);
    address ephemeralOwner = vm.addr(ephemeralPrivateKey);

    // LOAD THE KEY OF THE OWNER FOR THE OWNER ADDRESS
    uint256 ownerPrivateKey = uint256(0x99c28d665bea5ff926b43b240cfda380b3ddf9251c5e83364f6e674578c9c22d);
    address ownerSSU = vm.addr(ownerPrivateKey);

    // // Start broadcasting transactions from the deployer account
    vm.startBroadcast(ephemeralPrivateKey);

    // CHOOSE WHICH ITEM TO MOVE FROM INVENTORY TO EPHEMERAL
    uint256 inventoryItemId = uint256(17190961797274822652727777991308785890587906484718369996777961591379039493110);
    InventoryItem[] memory items = new InventoryItem[](1);
    items[0] = InventoryItem({ inventoryItemId: inventoryItemId, owner: ownerSSU, itemId: 0, typeId: 77818, volume: 1000000000, quantity: 1 });

    // CHOOSE WHICH ITEM TO MOVE FROM EPHEMERAL TO INVENTORY
    uint256 ephInventoryItemId = uint256(17190961797274822652727777991308785890587906484718369996777961591379039493110);
    InventoryItem[] memory itemsBack = new InventoryItem[](1);
    itemsBack[0] = InventoryItem({ inventoryItemId: ephInventoryItemId, owner: ownerSSU, itemId: 0, typeId: 77818, volume: 100000000, quantity: 2 });
    
    // TRANSFER
    // inventory.inventoryToEphemeralTransfer(smartObjectId, items);
    inventory.ephemeralToInventoryTransfer(smartObjectId, ownerSSU, itemsBack);

    // STOP THE BROADCAST
    vm.stopBroadcast();

  }
}