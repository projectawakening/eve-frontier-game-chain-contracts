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
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { NamespaceOwner } from "@latticexyz/world/src/codegen/tables/NamespaceOwner.sol";
import { IModule } from "@latticexyz/world/src/IModule.sol";

import { ENTITY_RECORD_DEPLOYMENT_NAMESPACE as DEPLOYMENT_NAMESPACE, SMART_OBJECT_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";
import { SmartObjectFrameworkModule } from "@eveworld/smart-object-framework/src/SmartObjectFrameworkModule.sol";
import { EntityCore } from "@eveworld/smart-object-framework/src/systems/core/EntityCore.sol";
import { HookCore } from "@eveworld/smart-object-framework/src/systems/core/HookCore.sol";
import { ModuleCore } from "@eveworld/smart-object-framework/src/systems/core/ModuleCore.sol";

import { ModulesInitializationLibrary } from "../../src/utils/ModulesInitializationLibrary.sol";
import { SOFInitializationLibrary } from "@eveworld/smart-object-framework/src/SOFInitializationLibrary.sol";
import { SmartObjectLib } from "@eveworld/smart-object-framework/src/SmartObjectLib.sol";
import { CLASS, OBJECT } from "@eveworld/smart-object-framework/src/constants.sol";

import { Utils } from "../../src/modules/entity-record/Utils.sol";
import { EntityRecordModule } from "../../src/modules/entity-record/EntityRecordModule.sol";
import { EntityRecordLib } from "../../src/modules/entity-record/EntityRecordLib.sol";
import { createCoreModule } from "../CreateCoreModule.sol";
import { EntityRecordTable, EntityRecordTableData } from "../../src/codegen/tables/EntityRecordTable.sol";
import { EntityRecordData } from "../../src/modules/smart-storage-unit/types.sol";
import { EntityRecordOffchainTable, EntityRecordOffchainTableData } from "../../src/codegen/tables/EntityRecordOffchainTable.sol";

contract EntityRecordTest is Test {
  using Utils for bytes14;
  using EntityRecordLib for EntityRecordLib.World;
  using SmartObjectLib for SmartObjectLib.World;
  using ModulesInitializationLibrary for IBaseWorld;
  using SOFInitializationLibrary for IBaseWorld;
  using WorldResourceIdInstance for ResourceId;

  IBaseWorld world;
  EntityRecordLib.World entityRecord;
  SmartObjectLib.World smartObject;

  function setUp() public {
    world = IBaseWorld(address(new World()));
    world.initialize(createCoreModule());
    // required for `NamespaceOwner` and `WorldResourceIdLib` to infer current World Address properly
    StoreSwitch.setStoreAddress(address(world));

    // installing SOF module (dependancy)
    world.installModule(
      new SmartObjectFrameworkModule(),
      abi.encode(SMART_OBJECT_DEPLOYMENT_NAMESPACE, new EntityCore(), new HookCore(), new ModuleCore())
    );
    world.initSOF();

    _installModule(new EntityRecordModule(), DEPLOYMENT_NAMESPACE);
    world.initEntityRecord();

    entityRecord = EntityRecordLib.World(world, DEPLOYMENT_NAMESPACE);
    smartObject = SmartObjectLib.World(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE);
  }

  // helper function to guard against multiple module registrations on the same namespace
  // TODO: Those kind of functions are used across all unit tests, ideally it should be inherited from a base Test contract
  function _installModule(IModule module, bytes14 namespace) internal {
    if (NamespaceOwner.getOwner(WorldResourceIdLib.encodeNamespace(namespace)) == address(this))
      world.transferOwnership(WorldResourceIdLib.encodeNamespace(namespace), address(module));
    world.installModule(module, abi.encode(namespace));
  }

  function testSetup() public {
    address entityRecordSystem = Systems.getSystem(DEPLOYMENT_NAMESPACE.entityRecordSystemId());
    ResourceId entityRecordSystemId = SystemRegistry.get(entityRecordSystem);
    assertEq(entityRecordSystemId.getNamespace(), DEPLOYMENT_NAMESPACE);
  }

  function testCreateEntityRecord(uint256 entityId, uint256 itemId, uint256 typeId, uint256 volume) public {
    vm.assume(entityId != 0);
    EntityRecordData memory data = EntityRecordData({ itemId: itemId, typeId: typeId, volume: volume });

    // SOF entity registration
    smartObject.registerEntity(entityId, OBJECT);
    world.associateEntityRecord(entityId);

    entityRecord.createEntityRecord(entityId, itemId, typeId, volume);
    EntityRecordTableData memory tableData = EntityRecordTable.get(
      DEPLOYMENT_NAMESPACE.entityRecordTableId(),
      entityId
    );

    assertEq(data.itemId, tableData.itemId);
    assertEq(data.typeId, tableData.typeId);
    assertEq(data.volume, tableData.volume);
    assertEq(tableData.recordExists, true);
  }

  function testCreateEntityRecordOffchain(
    uint256 entityId,
    string memory name,
    string memory dappURL,
    string memory description
  ) public {
    vm.assume(entityId != 0);
    vm.assume(bytes(name).length != 0);
    vm.assume(bytes(dappURL).length != 0);
    vm.assume(bytes(description).length != 0);
    EntityRecordOffchainTableData memory data = EntityRecordOffchainTableData({
      name: name,
      dappURL: dappURL,
      description: description
    });

    // SOF entity registration
    smartObject.registerEntity(entityId, OBJECT);
    world.associateEntityRecord(entityId);

    entityRecord.createEntityRecordOffchain(entityId, name, dappURL, description);
    EntityRecordOffchainTableData memory tableData = EntityRecordOffchainTable.get(
      DEPLOYMENT_NAMESPACE.entityRecordOffchainTableId(),
      entityId
    );

    assertEq(data.name, tableData.name);
    assertEq(data.dappURL, tableData.dappURL);
    assertEq(data.description, tableData.description);
  }

  function testSetEntityRecordOffchain(
    uint256 entityId,
    string memory name,
    string memory dappURL,
    string memory description
  ) public {
    vm.assume(entityId != 0);
    vm.assume(bytes(name).length != 0);
    vm.assume(bytes(dappURL).length != 0);
    vm.assume(bytes(description).length != 0);
    EntityRecordOffchainTableData memory data = EntityRecordOffchainTableData({
      name: name,
      dappURL: dappURL,
      description: description
    });

    testCreateEntityRecordOffchain(entityId, "name", "dappURL.com", "descriptive description");

    entityRecord.setEntityMetadata(entityId, name, dappURL, description);
    EntityRecordOffchainTableData memory tableData = EntityRecordOffchainTable.get(
      DEPLOYMENT_NAMESPACE.entityRecordOffchainTableId(),
      entityId
    );

    assertEq(data.name, tableData.name);
    assertEq(data.dappURL, tableData.dappURL);
    assertEq(data.description, tableData.description);
  }

  function testSetEntityRecordName(uint256 entityId, string memory name) public {
    vm.assume(entityId != 0);
    vm.assume(bytes(name).length != 0);

    testCreateEntityRecordOffchain(entityId, "name", "dappURL.com", "descriptive description");

    entityRecord.setName(entityId, name);
    EntityRecordOffchainTableData memory tableData = EntityRecordOffchainTable.get(
      DEPLOYMENT_NAMESPACE.entityRecordOffchainTableId(),
      entityId
    );

    assertEq(name, tableData.name);
  }

  function testSetEntityRecordDappURL(uint256 entityId, string memory dappURL) public {
    vm.assume(entityId != 0);
    vm.assume(bytes(dappURL).length != 0);

    testCreateEntityRecordOffchain(entityId, "name", "dappURL.com", "descriptive description");

    entityRecord.setDappURL(entityId, dappURL);
    EntityRecordOffchainTableData memory tableData = EntityRecordOffchainTable.get(
      DEPLOYMENT_NAMESPACE.entityRecordOffchainTableId(),
      entityId
    );

    assertEq(dappURL, tableData.dappURL);
  }

  function testSetEntityRecordDescription(uint256 entityId, string memory description) public {
    vm.assume(entityId != 0);
    vm.assume(bytes(description).length != 0);

    testCreateEntityRecordOffchain(entityId, "name", "dappURL.com", "descriptive description");

    entityRecord.setDescription(entityId, description);
    EntityRecordOffchainTableData memory tableData = EntityRecordOffchainTable.get(
      DEPLOYMENT_NAMESPACE.entityRecordOffchainTableId(),
      entityId
    );

    assertEq(description, tableData.description);
  }
}