// SPDX-License-Identifier: UNLICENSED
/* pragma solidity ^0.8.28; */

/* import {Test, console} from "forge-std/Test.sol"; */
/* import {EscrowSrc} from "../src/EscrowSrc.sol"; */
/* import {TestToken, IERC20} from "./TestToken.sol"; */
/* import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol"; */

/* contract EscrowSrcTest is Test { */
/*     EscrowSrc public escrowSrc; */
/*     IERC20 public token; */

/*     function setUp() public { */
/*         token = new TestToken(1000); */
/*         escrowSrc = new EscrowSrc(100, token); */
/*     } */

/*     function toHex16 (bytes16 data) internal pure returns (bytes32 result) { */
/*         result = bytes32 (data) & 0xFFFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000 | */
/*             (bytes32 (data) & 0x0000000000000000FFFFFFFFFFFFFFFF00000000000000000000000000000000) >> 64; */
/*         result = result & 0xFFFFFFFF000000000000000000000000FFFFFFFF000000000000000000000000 | */
/*             (result & 0x00000000FFFFFFFF000000000000000000000000FFFFFFFF0000000000000000) >> 32; */
/*         result = result & 0xFFFF000000000000FFFF000000000000FFFF000000000000FFFF000000000000 | */
/*             (result & 0x0000FFFF000000000000FFFF000000000000FFFF000000000000FFFF00000000) >> 16; */
/*         result = result & 0xFF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000 | */
/*             (result & 0x00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000) >> 8; */
/*         result = (result & 0xF000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000) >> 4 | */
/*             (result & 0x0F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F00) >> 8; */
/*         result = bytes32 (0x3030303030303030303030303030303030303030303030303030303030303030 + */
/*                           uint256 (result) + */
/*                           (uint256 (result) + 0x0606060606060606060606060606060606060606060606060606060606060606 >> 4 & */
/*                            0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F) * 7); */
/*     } */

/*     function toHex (bytes32 data) public pure returns (string memory) { */
/*         return string (abi.encodePacked ("0x", toHex16 (bytes16 (data)), toHex16 (bytes16 (data << 128)))); */
/*     } */

/*     function test_smoke() public { */
/*         bytes32 secret = 0x0000000000000000000000000000000000000000000000000000000000000000; */
/*         bytes32 hash = escrowSrc.debugKeccakBytes32(secret); */

/*         console.log(toHex(hash)); */
/*     } */
/* } */
