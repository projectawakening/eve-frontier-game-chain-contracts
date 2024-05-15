/// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { AcccessConfig, AccessConfigData } from "../../../codegen/tables/AccessConfig.sol";
import { IAccessRulesErrors } from "../IAccessRulesErrors.sol";
import "../types.sol";
import { Utils } from "../Utils.sol";

/**
 * @title Access Rules contract
 * @author The CCP Games Development Team
 * @notice A contract which implements access control enforcement logic.
 * @dev All functions in this contract are intended to be hook logic implementations and associated (and thereafter
 *   executed) with other target functions that implement the `hookable()` modfier. 
 * Association occurs by using the {HookCore} functionality of the Smart Object Framework. After asosciation with a
 *   target function, this hook logic will then also be executed anytime the target function is executed for a given
 *   `entityId`.
 */
contract AccessRules {
  using Utils for bytes14;

  /**
   * @dev All of the following accessControlRule implementations are hook based logic that implement access control
   *   rules enforcement for a specific configuration.
   * e.g., `accessRule1()` will use the EnforcementLevel and RolesByContext configuration set for `configId = 1` in
   * {AccessConfig}.
   *
   * In all instances, if the accessing account value is not a member of one of the defined roleIds for its context
   *   AND that access context is configured to be enforced, then an {AccessRulesUnauthorizedAccount} error
   *   will be thrown.
   *   
   * @param data - the `calldata` of a target function this hook function is associated with. `data` is populated when
   *   the `hookable()` modifier logic of the target function has been invoked. `data` is an `abi.encodePacked` payload
   *   which includes the function selector and function argument values of the target function being passed during
   *   execution. See {EveSystem-_executeHook}.
   */
  function accessControlRule1(bytes data) public {
    uint256 entityId = abi.decode(data[4:36]); // this assumes the target function has entityId as its first parameter (which is our standard pattern for hookable functions in the Smart Object Framework)
    uint256 configId = 1;
    _accessControlByConfigOR(entityId, configId);
  }

  /**
   * @dev Hook logic that references configId 2 for rules enforcement of access context roles and enforcement level.
   */
  function accessControlRule2(bytes data) public {
    uint256 entityId = abi.decode(data[4:36]); // this assumes the target function has entityId as its first parameter (which is our standard pattern for hookable functions in the Smart Object Framework)
    uint256 configId = 2;
    _accessControlByConfigOR(entityId, configId);
  }

  /**
   * @dev Hook logic that references configId 3 for rules enforcement of access context roles and enforcement level.
   */
  function accessControlRule3(bytes data) public {
    uint256 entityId = abi.decode(data[4:36]); // this assumes the target function has entityId as its first parameter (which is our standard pattern for hookable functions in the Smart Object Framework)
    uint256 configId = 3;
    _accessControlByConfigOR(entityId, configId);
  }

  /**
   * @dev - Hook logic that references configId 4 for rules enforcement of access context roles and enforcement level.
   */
  function accessControlRule4(bytes data) public {
    uint256 entityId = abi.decode(data[4:36]); // this assumes the target function has entityId as its first parameter (which is our standard pattern for hookable functions in the Smart Object Framework)
    uint256 configId = 4;
    _accessControlByConfigOR(entityId, configId);
  }

  /**
   * @dev - Hook logic that references configId 5 for rules enforcement of access context roles and enforcement level.
   */
  function accessControlRule5(bytes data) public {
    uint256 entityId = abi.decode(data[4:36]); // this assumes the target function has entityId as its first parameter (which is our standard pattern for hookable functions in the Smart Object Framework)
    uint256 configId = 5;
    _accessControlByConfigOR(entityId, configId);
  }

  /**
   * @dev Role based access control enforcement logic per `entityId` and `configId`
   * NOTE: this is an OR implementation. That is to say, if the account being checked is a member of any of the roles
   *   set in the configuration for its context, then access is granted.
   *
   * Throws an {AccessRulesUnauthorizedAccount} error if the account of any of the enforced access contexts is
   *   not a member of any of the configured roles for that context.
   */
  function _accessControlByConfigOR(uint256 entityId, uint256 configId) internal {
    AccessConfigData accessConfigData = AccessConfig.get(_namespace().accessConfigTableId(), entityId, configId);
    uint256 length = accessConfigData.initialMsgSender.length;
    EnforcementLevel configuredEnforcement = EnforcementLevel(accessConfigData.enforcementLevel);
    
    IAccessRulesError.AccessReport memory transientReport;
    IAccessRulesError.AccessReport memory mudReport;
    IAccessRulesError.AccessReport memory originReport;
    bool access = false;
    

    if(uint8(configuredEnforcement) > 0) {
      if(configuredEnforcement == EnforcementLevel.TRANSIENT_ONLY) {
        for (uint256 i = 0; i < accessConfigData.initialMsgSender.length; i++) {
          if (AccessControlLib.hasRole(world().initialMsgSender(), accessConfigData.initialMsgSender[i])) {
            access = true;
            break;
          }
        }
        if (!access) {
          transientReport = IAccessRulesError.AccessReport(
            world().initialMsgSender(),
            accessConfigData.initialMsgSender
          );

          revert IAccessRulesErrors.AccessRulesUnauthorizedAccount(
            configuredEnforcement,
            transientReport,
            mudReport,
            originReport
          );
        }
      } else if (configuredEnforcement == EnforcementLevel.MUD_ONLY) {
        for (uint256 i = 0; i < accessConfigData.mudMsgSender.length; i++) {
          if (AccessControlLib.hasRole(_msgSender(), accessConfigData.mudMsgSender[i])) {
            access = true;
            break;
          }
        }
        if (!access) {
          mudReport = IAccessRulesError.AccessReport(
            _msgSender(),
            accessConfigData.mudMsgSender
          );

          revert IAccessRulesErrors.AccessRulesUnauthorizedAccount(
            configuredEnforcement,
            transientReport,
            mudReport,
            originReport
          );
        }
      } else if (configuredEnforcement == EnforcementLevel.ORIGIN_ONLY) {
        for (uint256 i = 0; i < accessConfigData.txOrigin.length; i++) {
          if (AccessControlLib.hasRole(tx.origin, accessConfigData.txOrigin[i])) {
            access = true;
            break;
          }
        }
        if (!access) {
          originReport = IAccessRulesError.AccessReport(
            tx.origin,
            accessConfigData.txOrigin
          );

          revert IAccessRulesErrors.AccessRulesUnauthorizedAccount(
            configuredEnforcement,
            transientReport,
            mudReport,
            originReport
          );
        }
      } else if (configuredEnforcement == EnforcementLevel.TRANSIENT_AND_MUD) {
        for (uint256 i = 0; i < accessConfigData.initialMsgSender.length; i++) {
          if (
            AccessControlLib.hasRole(world().initialMsgSender(), accessConfigData.initialMsgSender[i]) ||
            AccessControlLib.hasRole(_msgSender(), accessConfigData.mudMsgSender[i])) {
            access = true;
            break;
          }
        }
        if (!access) {
          transientReport = IAccessRulesError.AccessReport(
            world().initialMsgSender(),
            accessConfigData.initialMsgSender
          );

          mudReport = IAccessRulesError.AccessReport(
            _msgSender(),
            accessConfigData.mudMsgSender
          );

          revert IAccessRulesErrors.AccessRulesUnauthorizedAccount(
            configuredEnforcement,
            transientReport,
            mudReport,
            originReport
          );
        }
      } else if (configuredEnforcement == EnforcementLevel.TRANSIENT_AND_ORIGIN) {
        for (uint256 i = 0; i < accessConfigData.initialMsgSender.length; i++) {
          if (
            AccessControlLib.hasRole(world().initialMsgSender(), accessConfigData.initialMsgSender[i]) ||
            AccessControlLib.hasRole(tx.origin, accessConfigData.txOrigin[i])) {
            access = true;
            break;
          }
        }
        if (!access) {
          transientReport = IAccessRulesError.AccessReport(
            world().initialMsgSender(),
            accessConfigData.initialMsgSender
          );
          
          originReport = IAccessRulesError.AccessReport(
            tx.origin,
            accessConfigData.txOrigin
          );

          revert IAccessRulesErrors.AccessRulesUnauthorizedAccount(
            configuredEnforcement,
            transientReport,
            mudReport,
            originReport
          );
        }
      } else if (configuredEnforcement == EnforcementLevel.MUD_AND_ORIGIN) {
        for (uint256 i = 0; i < accessConfigData.mudMsgSender.length; i++) {
          if (
            AccessControlLib.hasRole(_msgSender(), accessConfigData.mudMsgSender[i]) ||
            AccessControlLib.hasRole(tx.origin, accessConfigData.txOrigin[i])) {
            access = true;
            break;
          }
        }
        if (!access) {
          mudReport = IAccessRulesError.AccessReport(
            _msgSender(),
            accessConfigData.mudMsgSender
          );
          
          originReport = IAccessRulesError.AccessReport(
            tx.origin,
            accessConfigData.txOrigin
          );

          revert IAccessRulesErrors.AccessRulesUnauthorizedAccount(
            configuredEnforcement,
            transientReport,
            mudReport,
            originReport
          );
        }
      } else { // TRANSIENT_AND_MUD_AND_ORIGIN
        for (uint256 i = 0; i < accessConfigData.mudMsgSender.length; i++) {
          if (
            AccessControlLib.hasRole(_msgSender(), accessConfigData.mudMsgSender[i]) ||
            AccessControlLib.hasRole(tx.origin, accessConfigData.txOrigin[i])) {
            access = true;
            break;
          }
        }
        if (!access) {
          transientReport = IAccessRulesError.AccessReport(
            world().initialMsgSender(),
            accessConfigData.initialMsgSender
          );

          mudReport = IAccessRulesError.AccessReport(
            _msgSender(),
            accessConfigData.mudMsgSender
          );
          
          originReport = IAccessRulesError.AccessReport(
            tx.origin,
            accessConfigData.txOrigin
          );

          revert IAccessRulesErrors.AccessRulesUnauthorizedAccount(
            configuredEnforcement,
            transientReport,
            mudReport,
            originReport
          );
        }
      }
    } else { // EnforcementLevel NULL
      return;
    }
  }
