// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;
import { ResourceId, WorldResourceIdLib, WorldResourceIdInstance } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM, RESOURCE_TABLE } from "@latticexyz/world/src/worldResourceTypes.sol";
import { ResourceIds } from "@latticexyz/store/src/codegen/tables/ResourceIds.sol";

import { ENTITY_RECORD_SYSTEM_NAME, FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eve/common-constants/src/constants.sol";

import "./constants.sol";

library Utils {
  using WorldResourceIdInstance for ResourceId;

  function getSystemId(bytes14 namespace, bytes16 name) internal pure returns (ResourceId) {
    return WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: namespace, name: name });
  }

  function entityRecordTableId(bytes14 namespace) internal pure returns (ResourceId) {
    return WorldResourceIdLib.encode({ typeId: RESOURCE_TABLE, namespace: namespace, name: ENTITY_RECORD_TABLE_NAME });
  }

  function entityRecordOffchainTableId(bytes14 namespace) internal pure returns (ResourceId) {
    return
      WorldResourceIdLib.encode({
        typeId: RESOURCE_TABLE,
        namespace: namespace,
        name: ENTITY_RECORD_OFFCHAIN_TABLE_NAME
      });
  }

  function entityRecordSystemId(bytes14 namespace) internal view returns (ResourceId systemId) {
    systemId = WorldResourceIdLib.encode({
      typeId: RESOURCE_SYSTEM,
      namespace: namespace,
      name: ENTITY_RECORD_SYSTEM_NAME
    });
    if (!ResourceIds.getExists(WorldResourceIdLib.encodeNamespace(namespace))) {
      // in the way this is used, that would mean we registered this on `FRONTIER_WORLD_DEPLOYMENT_NAMESPACE`
      systemId = WorldResourceIdLib.encode({
        typeId: RESOURCE_SYSTEM,
        namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE,
        name: ENTITY_RECORD_SYSTEM_NAME
      });
    }
  }
}
