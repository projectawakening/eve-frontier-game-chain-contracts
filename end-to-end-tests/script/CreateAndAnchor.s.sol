pragma solidity >=0.8.20;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@eve/frontier-world/src/codegen/world/IWorld.sol";
import { EntityRecordData, SmartObjectData, WorldPosition, Coord } from "@eve/frontier-world/src/modules/smart-storage-unit/types.sol";
import { SmartStorageUnitLib } from "@eve/frontier-world/src/modules/smart-storage-unit/SmartStorageUnitLib.sol";

contract CreateAndAnchor is Script {
  using SmartStorageUnitLib for SmartStorageUnitLib.World;

  function run(address worldAddress) public {
    StoreSwitch.setStoreAddress(worldAddress);
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address player = vm.addr(deployerPrivateKey);

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);
    SmartStorageUnitLib.World memory smartStorageUnit = SmartStorageUnitLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: "frontier"
    });

    uint256 smartObjectId = uint256(keccak256(abi.encode("item:<tenant_id>-<db_id>-2345")));
    uint256 storageCapacity = 100000000;
    uint256 ephemeralStorageCapacity = 100000000000;
    EntityRecordData memory entityRecordData = EntityRecordData({ typeId: 7888, itemId: 111, volume: 10 });
    SmartObjectData memory smartObjectData = SmartObjectData({ owner: player, tokenURI: "test" });
    WorldPosition memory worldPosition = WorldPosition({ solarSystemId: 1, position: Coord({ x: 1, y: 1, z: 1 }) });
    uint256 fuelUnitVolume = 1e18;
    uint256 fuelConsumptionPerMinute = 1;
    uint256 fuelMaxCapacity = 1000000 * 1e18;
    smartStorageUnit.createAndAnchorSmartStorageUnit(
      smartObjectId,
      entityRecordData,
      smartObjectData,
      worldPosition,
      fuelUnitVolume,
      fuelConsumptionPerMinute,
      fuelMaxCapacity,
      storageCapacity,
      ephemeralStorageCapacity
    );

    vm.stopBroadcast();
  }
}
