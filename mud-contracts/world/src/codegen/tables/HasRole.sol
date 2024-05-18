// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

// Import schema type
import { SchemaType } from "@latticexyz/schema-type/src/solidity/SchemaType.sol";

// Import store internals
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { StoreCore } from "@latticexyz/store/src/StoreCore.sol";
import { Bytes } from "@latticexyz/store/src/Bytes.sol";
import { Memory } from "@latticexyz/store/src/Memory.sol";
import { SliceLib } from "@latticexyz/store/src/Slice.sol";
import { EncodeArray } from "@latticexyz/store/src/tightcoder/EncodeArray.sol";
import { FieldLayout, FieldLayoutLib } from "@latticexyz/store/src/FieldLayout.sol";
import { Schema, SchemaLib } from "@latticexyz/store/src/Schema.sol";
import { PackedCounter, PackedCounterLib } from "@latticexyz/store/src/PackedCounter.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

FieldLayout constant _fieldLayout = FieldLayout.wrap(
  0x0001010001000000000000000000000000000000000000000000000000000000
);

library HasRole {
  /**
   * @notice Get the table values' field layout.
   * @return _fieldLayout The field layout for the table.
   */
  function getFieldLayout() internal pure returns (FieldLayout) {
    return _fieldLayout;
  }

  /**
   * @notice Get the table's key schema.
   * @return _keySchema The key schema for the table.
   */
  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _keySchema = new SchemaType[](2);
    _keySchema[0] = SchemaType.BYTES32;
    _keySchema[1] = SchemaType.ADDRESS;

    return SchemaLib.encode(_keySchema);
  }

  /**
   * @notice Get the table's value schema.
   * @return _valueSchema The value schema for the table.
   */
  function getValueSchema() internal pure returns (Schema) {
    SchemaType[] memory _valueSchema = new SchemaType[](1);
    _valueSchema[0] = SchemaType.BOOL;

    return SchemaLib.encode(_valueSchema);
  }

  /**
   * @notice Get the table's key field names.
   * @return keyNames An array of strings with the names of key fields.
   */
  function getKeyNames() internal pure returns (string[] memory keyNames) {
    keyNames = new string[](2);
    keyNames[0] = "roleId";
    keyNames[1] = "account";
  }

  /**
   * @notice Get the table's value field names.
   * @return fieldNames An array of strings with the names of value fields.
   */
  function getFieldNames() internal pure returns (string[] memory fieldNames) {
    fieldNames = new string[](1);
    fieldNames[0] = "hasRole";
  }

  /**
   * @notice Register the table with its config.
   */
  function register(ResourceId _tableId) internal {
    StoreSwitch.registerTable(_tableId, _fieldLayout, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /**
   * @notice Register the table with its config.
   */
  function _register(ResourceId _tableId) internal {
    StoreCore.registerTable(_tableId, _fieldLayout, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /**
   * @notice Get hasRole.
   */
  function getHasRole(ResourceId _tableId, bytes32 roleId, address account) internal view returns (bool hasRole) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = roleId;
    _keyTuple[1] = bytes32(uint256(uint160(account)));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (_toBool(uint8(bytes1(_blob))));
  }

  /**
   * @notice Get hasRole.
   */
  function _getHasRole(ResourceId _tableId, bytes32 roleId, address account) internal view returns (bool hasRole) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = roleId;
    _keyTuple[1] = bytes32(uint256(uint160(account)));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (_toBool(uint8(bytes1(_blob))));
  }

  /**
   * @notice Get hasRole.
   */
  function get(ResourceId _tableId, bytes32 roleId, address account) internal view returns (bool hasRole) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = roleId;
    _keyTuple[1] = bytes32(uint256(uint160(account)));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (_toBool(uint8(bytes1(_blob))));
  }

  /**
   * @notice Get hasRole.
   */
  function _get(ResourceId _tableId, bytes32 roleId, address account) internal view returns (bool hasRole) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = roleId;
    _keyTuple[1] = bytes32(uint256(uint160(account)));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (_toBool(uint8(bytes1(_blob))));
  }

  /**
   * @notice Set hasRole.
   */
  function setHasRole(ResourceId _tableId, bytes32 roleId, address account, bool hasRole) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = roleId;
    _keyTuple[1] = bytes32(uint256(uint160(account)));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((hasRole)), _fieldLayout);
  }

  /**
   * @notice Set hasRole.
   */
  function _setHasRole(ResourceId _tableId, bytes32 roleId, address account, bool hasRole) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = roleId;
    _keyTuple[1] = bytes32(uint256(uint160(account)));

    StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((hasRole)), _fieldLayout);
  }

  /**
   * @notice Set hasRole.
   */
  function set(ResourceId _tableId, bytes32 roleId, address account, bool hasRole) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = roleId;
    _keyTuple[1] = bytes32(uint256(uint160(account)));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((hasRole)), _fieldLayout);
  }

  /**
   * @notice Set hasRole.
   */
  function _set(ResourceId _tableId, bytes32 roleId, address account, bool hasRole) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = roleId;
    _keyTuple[1] = bytes32(uint256(uint160(account)));

    StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((hasRole)), _fieldLayout);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function deleteRecord(ResourceId _tableId, bytes32 roleId, address account) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = roleId;
    _keyTuple[1] = bytes32(uint256(uint160(account)));

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function _deleteRecord(ResourceId _tableId, bytes32 roleId, address account) internal {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = roleId;
    _keyTuple[1] = bytes32(uint256(uint160(account)));

    StoreCore.deleteRecord(_tableId, _keyTuple, _fieldLayout);
  }

  /**
   * @notice Tightly pack static (fixed length) data using this table's schema.
   * @return The static data, encoded into a sequence of bytes.
   */
  function encodeStatic(bool hasRole) internal pure returns (bytes memory) {
    return abi.encodePacked(hasRole);
  }

  /**
   * @notice Encode all of a record's fields.
   * @return The static (fixed length) data, encoded into a sequence of bytes.
   * @return The lengths of the dynamic fields (packed into a single bytes32 value).
   * @return The dynamic (variable length) data, encoded into a sequence of bytes.
   */
  function encode(bool hasRole) internal pure returns (bytes memory, PackedCounter, bytes memory) {
    bytes memory _staticData = encodeStatic(hasRole);

    PackedCounter _encodedLengths;
    bytes memory _dynamicData;

    return (_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Encode keys as a bytes32 array using this table's field layout.
   */
  function encodeKeyTuple(bytes32 roleId, address account) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](2);
    _keyTuple[0] = roleId;
    _keyTuple[1] = bytes32(uint256(uint160(account)));

    return _keyTuple;
  }
}

/**
 * @notice Cast a value to a bool.
 * @dev Boolean values are encoded as uint8 (1 = true, 0 = false), but Solidity doesn't allow casting between uint8 and bool.
 * @param value The uint8 value to convert.
 * @return result The boolean value.
 */
function _toBool(uint8 value) pure returns (bool result) {
  assembly {
    result := value
  }
}
