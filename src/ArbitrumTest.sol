// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {TestBase} from "forge-std/Base.sol";

import {Bridge} from "@arbitrum/nitro-contracts/src/bridge/Bridge.sol";
import {IOwnable} from "@arbitrum/nitro-contracts/src/bridge/IOwnable.sol";

import {ArbSysMock} from "../src/ArbSysMock.sol";
import {ArbitrumInboxMock} from "../src/ArbitrumInboxMock.sol";
import {MAINNET_INBOX, MAINNET_BRIDGE, MAINNET_OUTBOX, ARBSYS_PRECOMPILE, MAX_DATA_SIZE} from "../src/constants.sol";

contract ArbitrumTest is TestBase {
    ArbSysMock arbsys;
    ArbitrumInboxMock inbox;
    Bridge bridge;

    constructor() {
        setUpArbSysMock();
        setUpInboxMock();
        setUpBridge();
    }

    function setUpArbSysMock() internal {
        // L2 contracts explicitly reference 0x64 for the ArbSys precompile
        // We'll replace it with the mock contract where L2-to-L1 messages are executed immediately
        ArbSysMock _arbsys = new ArbSysMock();
        vm.etch(ARBSYS_PRECOMPILE, address(_arbsys).code);

        arbsys = ArbSysMock(ARBSYS_PRECOMPILE);
        vm.makePersistent(ARBSYS_PRECOMPILE);
        vm.allowCheatcodes(ARBSYS_PRECOMPILE);
    }

    function setUpInboxMock() internal {
        // use the mocked Arbitrum inbox where L1-to-L2 messages are executed immediately
        ArbitrumInboxMock _inbox = new ArbitrumInboxMock(MAX_DATA_SIZE);
        vm.etch(MAINNET_INBOX, address(_inbox).code);

        inbox = ArbitrumInboxMock(MAINNET_INBOX);
        vm.makePersistent(MAINNET_INBOX);
        vm.allowCheatcodes(MAINNET_INBOX);
    }

    function setUpBridge() internal {
        Bridge _bridge = new Bridge();
        vm.etch(MAINNET_BRIDGE, address(_bridge).code);

        bridge = Bridge(MAINNET_BRIDGE);
        // Hacky, but properly initializing the bridge is a hassle and we just
        // want to fool the bridge into thinking we can make this call.
        // See AbsBridge.onlyRollupOrOwner from
        // @arbitrum/nitro-contracts/src/bridge/AbsBridge.sol
        vm.mockCall(address(0), abi.encodeWithSelector(IOwnable.owner.selector), abi.encode(address(this)));
        bridge.setOutbox(MAINNET_OUTBOX, true);
    }
}
