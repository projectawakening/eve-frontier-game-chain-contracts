// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "forge-std/Test.sol";
import { World } from "@latticexyz/world/src/World.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { SystemRegistry } from "@latticexyz/world/src/codegen/tables/SystemRegistry.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { WorldResourceIdInstance } from "@latticexyz/world/src/WorldResourceId.sol";
import { PuppetModule } from "@latticexyz/world-modules/src/modules/puppet/PuppetModule.sol";

import { SMART_OBJECT_DEPLOYMENT_NAMESPACE } from "@eve/common-constants/src/constants.sol";
import { SmartObjectFrameworkModule } from "@eve/frontier-smart-object-framework/src/SmartObjectFrameworkModule.sol";
import { EVE_ERC721_PUPPET_DEPLOYMENT_NAMESPACE, STATIC_DATA_DEPLOYMENT_NAMESPACE, SMART_STORAGE_UNIT_DEPLOYMENT_NAMESPACE, ENTITY_RECORD_DEPLOYMENT_NAMESPACE, SMART_DEPLOYABLE_DEPLOYMENT_NAMESPACE, INVENTORY_DEPLOYMENT_NAMESPACE, LOCATION_DEPLOYMENT_NAMESPACE } from "@eve/common-constants/src/constants.sol";

import { EntityRecordOffchainTable, EntityRecordOffchainTableData } from "../../src/codegen/tables/EntityRecordOffchainTable.sol";
import { EntityRecordTableData, EntityRecordTable } from "../../src/codegen/tables/EntityRecordTable.sol";
import { LocationTable, LocationTableData } from "../../src/codegen/tables/LocationTable.sol";
import { DeployableState, DeployableStateData } from "../../src/codegen/tables/DeployableState.sol";
import { InventoryTable, InventoryTableData } from "../../src/codegen/tables/InventoryTable.sol";
import { InventoryItemTable, InventoryItemTableData } from "../../src/codegen/tables/InventoryItemTable.sol";
import { EphemeralInventoryTable, EphemeralInventoryTableData } from "../../src/codegen/tables/EphemeralInventoryTable.sol";
import { EphemeralInvItemTable, EphemeralInvItemTableData } from "../../src/codegen/tables/EphemeralInvItemTable.sol";

import { SmartStorageUnitModule } from "../../src/modules/smart-storage-unit/SmartStorageUnitModule.sol";
import { StaticDataModule } from "../../src/modules/static-data/StaticDataModule.sol";
import { EntityRecordModule } from "../../src/modules/entity-record/EntityRecordModule.sol";
import { ERC721Module } from "../../src/modules/eve-erc721-puppet/ERC721Module.sol";
import { registerERC721 } from "../../src/modules/eve-erc721-puppet/registerERC721.sol";
import { IERC721Mintable } from "../../src/modules/eve-erc721-puppet/IERC721Mintable.sol";
import { SmartDeployableModule } from "../../src/modules/smart-deployable/SmartDeployableModule.sol";
import { LocationModule } from "../../src/modules/location/LocationModule.sol";
import { InventoryModule } from "../../src/modules/inventory/InventoryModule.sol";
import { SmartDeployableLib } from "../../src/modules/smart-deployable/SmartDeployableLib.sol";

import { Utils as SmartStorageUnitUtils } from "../../src/modules/smart-storage-unit/Utils.sol";
import { Utils as EntityRecordUtils } from "../../src/modules/entity-record/Utils.sol";
import { Utils as SmartDeployableUtils } from "../../src/modules/smart-deployable/Utils.sol";
import { Utils as LocationUtils } from "../../src/modules/location/Utils.sol";
import { Utils as InventoryUtils } from "../../src/modules/inventory/Utils.sol";
import { State } from "../../src/modules/smart-deployable/types.sol";

import { SmartStorageUnitLib } from "../../src/modules/smart-storage-unit/SmartStorageUnitLib.sol";
import { StaticDataGlobalTableData } from "../../src/codegen/tables/StaticDataGlobalTable.sol";
import "../../src/modules/smart-storage-unit/types.sol";
import { createCoreModule } from "../CreateCoreModule.sol";

contract SmartStorageUnitTest is Test {
  using SmartStorageUnitUtils for bytes14;
  using EntityRecordUtils for bytes14;
  using SmartDeployableUtils for bytes14;
  using InventoryUtils for bytes14;
  using LocationUtils for bytes14;
  using SmartStorageUnitLib for SmartStorageUnitLib.World;
  using SmartDeployableLib for SmartDeployableLib.World;
  using WorldResourceIdInstance for ResourceId;

  IBaseWorld baseWorld;
  SmartStorageUnitLib.World smartStorageUnit;
  IERC721Mintable erc721Token;
  SmartDeployableLib.World smartDeployable;
  uint256 storageCapacity = 100000;
  uint256 ephemeralStorageCapacity = 100000;

  function setUp() public {
    baseWorld = IBaseWorld(address(new World()));
    baseWorld.initialize(createCoreModule());
    baseWorld.installModule(new SmartObjectFrameworkModule(), abi.encode(SMART_OBJECT_DEPLOYMENT_NAMESPACE));

    // install module dependancies
    baseWorld.installModule(new PuppetModule(), new bytes(0));
    baseWorld.installModule(new StaticDataModule(), abi.encode(STATIC_DATA_DEPLOYMENT_NAMESPACE));
    baseWorld.installModule(new EntityRecordModule(), abi.encode(ENTITY_RECORD_DEPLOYMENT_NAMESPACE));
    baseWorld.installModule(new SmartDeployableModule(), abi.encode(SMART_DEPLOYABLE_DEPLOYMENT_NAMESPACE));
    baseWorld.installModule(new InventoryModule(), abi.encode(INVENTORY_DEPLOYMENT_NAMESPACE));
    baseWorld.installModule(new LocationModule(), abi.encode(LOCATION_DEPLOYMENT_NAMESPACE));
    StoreSwitch.setStoreAddress(address(baseWorld));
    erc721Token = registerERC721(
      baseWorld,
      EVE_ERC721_PUPPET_DEPLOYMENT_NAMESPACE,
      StaticDataGlobalTableData({ name: "SmartStorageUnit", symbol: "SSU", baseURI: "" })
    );
    baseWorld.installModule(new SmartStorageUnitModule(), abi.encode(SMART_STORAGE_UNIT_DEPLOYMENT_NAMESPACE));

    smartStorageUnit = SmartStorageUnitLib.World(baseWorld, SMART_STORAGE_UNIT_DEPLOYMENT_NAMESPACE);
    smartDeployable = SmartDeployableLib.World(baseWorld, SMART_DEPLOYABLE_DEPLOYMENT_NAMESPACE);
    smartDeployable.registerDeployableToken(address(erc721Token));
  }

  function testSetup() public {
    address smartStorageUnitSystem = Systems.getSystem(
      SMART_STORAGE_UNIT_DEPLOYMENT_NAMESPACE.smartStorageUnitSystemId()
    );
    ResourceId smartStorageUnitSystemId = SystemRegistry.get(smartStorageUnitSystem);
    assertEq(smartStorageUnitSystemId.getNamespace(), SMART_STORAGE_UNIT_DEPLOYMENT_NAMESPACE);
  }

  function testCreateAndAnchorSmartStorageUnit(uint256 smartObjectId) public {
    EntityRecordData memory entityRecordData = EntityRecordData({ typeId: 12345, itemId: 45, volume: 10 });
    SmartObjectData memory smartObjectData = SmartObjectData({ owner: address(1), tokenURI: "test" });
    WorldPosition memory worldPosition = WorldPosition({ solarSystemId: 1, position: Coord({ x: 1, y: 1, z: 1 }) });
    smartStorageUnit.createAndAnchorSmartStorageUnit(
      smartObjectId,
      entityRecordData,
      smartObjectData,
      worldPosition,
      storageCapacity,
      ephemeralStorageCapacity
    );
    smartDeployable.bringOnline(smartObjectId);

    State currentState = DeployableState.getState(
      SMART_DEPLOYABLE_DEPLOYMENT_NAMESPACE.deployableStateTableId(),
      smartObjectId
    );
    assertEq(uint8(currentState), uint8(State.ONLINE));

    EntityRecordTableData memory entityRecordTableData = EntityRecordTable.get(
      ENTITY_RECORD_DEPLOYMENT_NAMESPACE.entityRecordTableId(),
      smartObjectId
    );

    assertEq(entityRecordTableData.typeId, entityRecordData.typeId);
    assertEq(entityRecordTableData.itemId, entityRecordData.itemId);
    assertEq(entityRecordTableData.volume, entityRecordData.volume);

    LocationTableData memory locationTableData = LocationTable.get(
      LOCATION_DEPLOYMENT_NAMESPACE.locationTableId(),
      smartObjectId
    );
    assertEq(locationTableData.solarSystemId, worldPosition.solarSystemId);
    assertEq(locationTableData.x, worldPosition.position.x);
    assertEq(locationTableData.y, worldPosition.position.y);
    assertEq(locationTableData.z, worldPosition.position.z);

    assertEq(erc721Token.ownerOf(smartObjectId), address(1));

    smartStorageUnit.setDeploybaleMetadata(smartObjectId, "testName", "testDappURL", "testdesc");

    EntityRecordOffchainTableData memory entityRecordOffchainTableData = EntityRecordOffchainTable.get(
      ENTITY_RECORD_DEPLOYMENT_NAMESPACE.entityRecordOffchainTableId(),
      smartObjectId
    );

    assertEq(entityRecordOffchainTableData.name, "testName");
    assertEq(entityRecordOffchainTableData.dappURL, "testDappURL");
    assertEq(entityRecordOffchainTableData.description, "testdesc");
  }

  function testCreateAndDepositItemsToInventory(uint256 smartObjectId) public {
    testCreateAndAnchorSmartStorageUnit(smartObjectId);

    InventoryItem[] memory items = new InventoryItem[](1);
    items[0] = InventoryItem({
      inventoryItemId: 123,
      owner: address(2),
      itemId: 12,
      typeId: 3,
      volume: 10,
      quantity: 5
    });

    smartStorageUnit.createAndDepositItemsToInventory(smartObjectId, items);

    InventoryTableData memory inventoryTableData = InventoryTable.get(
      INVENTORY_DEPLOYMENT_NAMESPACE.inventoryTableId(),
      smartObjectId
    );
    uint256 useCapacity = items[0].volume * items[0].quantity;

    assertEq(inventoryTableData.capacity, storageCapacity);
    assertEq(inventoryTableData.usedCapacity, useCapacity);

    InventoryItemTableData memory inventoryItemTableData = InventoryItemTable.get(
      INVENTORY_DEPLOYMENT_NAMESPACE.inventoryItemTableId(),
      smartObjectId,
      items[0].inventoryItemId
    );

    assertEq(inventoryItemTableData.quantity, items[0].quantity);
    assertEq(inventoryItemTableData.index, 0);
  }

  function testCreateAndDepositItemsToEphemeralInventory(uint256 smartObjectId) public {
    testCreateAndAnchorSmartStorageUnit(smartObjectId);
    InventoryItem[] memory items = new InventoryItem[](1);
    address inventoryOwner = address(1);
    items[0] = InventoryItem({
      inventoryItemId: 456,
      owner: address(2),
      itemId: 45,
      typeId: 6,
      volume: 10,
      quantity: 5
    });
    smartStorageUnit.createAndDepositItemsToEphemeralInventory(smartObjectId, inventoryOwner, items);

    EphemeralInventoryTableData memory ephemeralInventoryTableData = EphemeralInventoryTable.get(
      INVENTORY_DEPLOYMENT_NAMESPACE.ephemeralInventoryTableId(),
      smartObjectId,
      inventoryOwner
    );

    uint256 useCapacity = items[0].volume * items[0].quantity;
    assertEq(ephemeralInventoryTableData.capacity, ephemeralStorageCapacity);
    assertEq(ephemeralInventoryTableData.usedCapacity, useCapacity);

    EphemeralInvItemTableData memory ephemeralInvItemTableData = EphemeralInvItemTable.get(
      INVENTORY_DEPLOYMENT_NAMESPACE.ephemeralInventoryItemTableId(),
      smartObjectId,
      items[0].inventoryItemId,
      items[0].owner
    );

    assertEq(ephemeralInvItemTableData.quantity, items[0].quantity);
    assertEq(ephemeralInvItemTableData.index, 0);
  }
}
