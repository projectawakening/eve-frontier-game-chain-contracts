// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { RootRoleData } from "./../../modules/access-control/types.sol";

/**
 * @title IAccessControl
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IAccessControl {
  function eveworld__createRootRole(address callerConfirmation) external returns (RootRoleData memory);

  function eveworld__createRole(
    string memory name,
    address rootAcctConfirmation,
    bytes32 adminId
  ) external returns (bytes32);

  function eveworld__transferRoleAdmin(bytes32 roleId, bytes32 newAdminId) external;

  function eveworld__grantRole(bytes32 roleId, address account) external;

  function eveworld__revokeRole(bytes32 roleId, address account) external;

  function eveworld__renounceRole(bytes32 roleId, address callerConfirmation) external;

  function eveworld__hasRole(bytes32 roleId, address account) external view returns (bool);

  function eveworld__getRoleAdmin(bytes32 roleId) external view returns (bytes32);

  function eveworld__getRoleId(address rootAcct, string calldata name) external pure returns (bytes32);

  function eveworld__roleExists(bytes32 roleId) external view returns (bool);

  function eveworld__isRootRole(bytes32 roleId) external view returns (bool);
}
