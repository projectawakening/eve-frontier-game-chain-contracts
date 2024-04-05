// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { IInventorySystem } from "./interfaces/IInventorySystem.sol";
import { IEphemeralInventorySystem } from "./interfaces/IEphemeralInventorySystem.sol";
import { Utils } from "./Utils.sol";
import { InventoryItem } from "../types.sol";

/**
 * @title InventoryLib (makes interacting with the underlying systems cleaner)
 * Works similary to direct calls to world, without having to deal with dynamic method's function selectors due to namespacing
 * @dev To preserve _msgSender() and other context dependant properties, Library methods like those MUST be `internal`.
 * That way, the compiler is forced to inline the method's implementation in the contract they're imported into
 */
library InventoryLib {
  using Utils for bytes14;

  struct World {
    IBaseWorld iface;
    bytes14 namespace;
  }

  function setInventoryCapacity(World memory world, uint256 smartObjectId, uint256 storageCapacity) internal {
    world.iface.call(
      world.namespace.inventorySystemId(),
      abi.encodeCall(IInventorySystem.setInventoryCapacity, (smartObjectId, storageCapacity))
    );
  }

  function depositToInventory(World memory world, uint256 smartObjectId, InventoryItem[] memory items) internal {
    world.iface.call(
      world.namespace.inventorySystemId(),
      abi.encodeCall(IInventorySystem.depositToInventory, (smartObjectId, items))
    );
  }

  function setEphemeralInventoryCapacity(
    World memory world,
    uint256 smartObjectId,
    address owner,
    uint256 ephemeralStorageCapacity
  ) internal {
    world.iface.call(
      world.namespace.ephemeralInventorySystemId(),
      abi.encodeCall(
        IEphemeralInventorySystem.setEphemeralInventoryCapacity,
        (smartObjectId, owner, ephemeralStorageCapacity)
      )
    );
  }
}
