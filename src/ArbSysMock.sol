// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IInboxBase} from "@arbitrum/nitro-contracts/src/bridge/IInboxBase.sol";
import {IBridge} from "@arbitrum/nitro-contracts/src/bridge/IBridge.sol";
import {IOutbox} from "@arbitrum/nitro-contracts/src/bridge/IOutbox.sol";

// So that we can prank the call to the bridge
import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

import {MAINNET_INBOX, MAINNET_BRIDGE, MAINNET_OUTBOX} from "../src/constants.sol";

/// @title ArbSysMock
/// @notice a mocked version of the Arbitrum system contract, add additional methods as needed

contract ArbSysMock is CommonBase, StdCheats {
    uint256 ticketId;

    function sendTxToL1(address _l1Target, bytes memory _data) external payable returns (uint256) {
        // Hacky, but properly initializing the inbox is a hassle and this value
        // is pretty much a constant anyway.
        if (!isFork()) {
            vm.mockCall(
                MAINNET_INBOX, abi.encodeWithSelector(IInboxBase.bridge.selector), abi.encode(IBridge(MAINNET_BRIDGE))
            );
        }
        mockL2ToL1Sender(msg.sender);
        vm.prank(MAINNET_OUTBOX);
        (bool success,) = IBridge(MAINNET_BRIDGE).executeCall(_l1Target, msg.value, _data);
        mockL2ToL1Sender(address(0));
        require(success, "Arbsys: sendTxToL1 failed");
        return ++ticketId;
    }

    function mockL2ToL1Sender(address _sender) internal {
        vm.mockCall(MAINNET_OUTBOX, abi.encodeWithSelector(IOutbox.l2ToL1Sender.selector), abi.encode(_sender));
    }
}
