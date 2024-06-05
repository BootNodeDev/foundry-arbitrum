// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {TestBase} from "forge-std/Base.sol";

import {ArbSysMock} from "../src/ArbSysMock.sol";
import {ArbitrumInboxMock} from "../src/ArbitrumInboxMock.sol";

import {Bridge} from "@arbitrum/nitro-contracts/src/bridge/Bridge.sol";

contract ArbitrumTest is TestBase {
    ArbSysMock arbsys;
    ArbitrumInboxMock inbox;
    Bridge bridge;

    address public constant ARBSYS_PRECOMPILE = 0x0000000000000000000000000000000000000064;

    constructor() {
        setUpArbSysMock();
        setUpInboxMock();
        setUpBridge();
    }

    function setUpArbSysMock() internal {
        // L2 contracts explicitly reference 0x64 for the ArbSys precompile
        // We'll replace it with the mock contract where L2-to-L1 messages are executed immediately
        arbsys = new ArbSysMock();
        vm.etch(ARBSYS_PRECOMPILE, address(arbsys).code);
    }

    function setUpInboxMock() internal {
        // use the mocked Arbitrum inbox where L1-to-L2 messages are executed immediately
        uint256 MAX_DATA_SIZE = 117_964;
        inbox = new ArbitrumInboxMock(MAX_DATA_SIZE);
    }

    function setUpBridge() internal {
        bridge = Bridge(arbsys.MAINNET_BRIDGE());
    }
}
