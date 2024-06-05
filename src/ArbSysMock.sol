// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// So that we can prank the call to the L1 target
import {CommonBase} from "forge-std/Base.sol";

/// @title ArbSysMock
/// @notice a mocked version of the Arbitrum system contract, add additional methods as needed

contract ArbSysMock is CommonBase {
    uint256 ticketId;

    address public constant MAINNET_BRIDGE = 0x8315177aB297bA92A06054cE80a67Ed4DBd7ed3a;

    function sendTxToL1(address _l1Target, bytes memory _data) external payable returns (uint256) {
        vm.prank(MAINNET_BRIDGE);
        (bool success,) = _l1Target.call(_data);
        require(success, "Arbsys: sendTxToL1 failed");
        return ++ticketId;
    }
}
