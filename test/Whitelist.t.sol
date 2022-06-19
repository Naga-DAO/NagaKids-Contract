// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Whitelist.sol";

contract WhitelistTest is Test {
    Whitelist mt;

    bytes32[] proof;
    address user;
    uint256 amount;

    function setUp() public {
        mt = new Whitelist();

        proof = new bytes32[](3);
        proof[
            0
        ] = 0x887610ccbf6ff730a639c5ec66d671b53ea0e4b57e1d0365ac1312d4da91ee70;
        proof[
            1
        ] = 0x28c35201396aa7d20721d19c75211d50b148761d4325460e0790ee5521738dd9;
        proof[
            2
        ] = 0xa4260b994a24a0fda03b768c5b3ca8f38dd364415bef63a45e99ca07ee151f0d;

        user = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84;
        amount = 3;
    }

    function testIsWhitelistWithEmptyMerkleRoot() public {
        bool actual = mt.isWhitelist(proof, user, amount);
        assertEq(actual, false);
    }

    function testIsWhitelist() public {
        mt.setMerkleRoot(
            0x1c37749cbd036a713e6f548c834de71f959321c778649b896b7397f7b42dc459
        );

        bool actual = mt.isWhitelist(proof, user, amount);
        assertTrue(actual);
    }
}
