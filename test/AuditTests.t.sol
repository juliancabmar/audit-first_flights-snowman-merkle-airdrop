// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {Snow} from "../src/Snow.sol";
import {Snowman} from "../src/Snowman.sol";
import {SnowmanAirdrop} from "../src/SnowmanAirdrop.sol";
import {MockWETH} from "../src/mock/MockWETH.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract AuditTests is Test {
    function testDeployContracts() public {
        // common setup
        address deployer = makeAddr("deployer");
        address collector = makeAddr("collector");

        // deploying Snow Token
        MockWETH weth = new MockWETH();
        uint256 fee = 5;
        vm.prank(deployer);
        Snow snow = new Snow(address(weth), fee, collector);

        // deploying Snowman
        string memory snowmanSvg = vm.readFile("./img/snowman.svg");
        vm.prank(deployer);
        Snowman snowman = new Snowman(svgToImageURI(snowmanSvg));

        // deploying SnowmanAirdrop
        vm.prank(deployer);
        bytes32 s_MERKLE_ROOT = 0xc0b6787abae0a5066bc2d09eaec944c58119dc18be796e93de5b2bf9f80ea79a; // Gotten from output.json
        SnowmanAirdrop airdrop = new SnowmanAirdrop(s_MERKLE_ROOT, address(snow), address(snowman));

        console2.log("Snow contract: ", address(snow));
        console2.log("Snowman contract: ", address(snowman));
        console2.log("SnowmanAirdrop contract: ", address(airdrop));
    }

    function svgToImageURI(string memory svg) public pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }
}
