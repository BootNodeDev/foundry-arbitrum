// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ExampleTest} from "./Example.t.sol";

contract ExampleForkingTest is ExampleTest {
    function setUp() public override {
        vm.createSelectFork("mainnet", 19_069_420);
        super.setUp();
    }
}
