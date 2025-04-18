// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {DAO} from "../src/dao.sol";
import {RevoNft} from "../src/nft.sol";
import {P2PLending} from "../src/lending.sol";
import {Treasury} from "../src/treasury.sol";
import {Revo} from "../src/token.sol";
import {StakERC20} from "../src/stake.sol";
import {Swapper} from "../src/swap.sol";

contract Deployscript is Script {
    Treasury treasury;
    StakERC20 stakErc20;  
    RevoNft revoNft;
    Swapper swap;
    DAO dao;
    address erc20;
    address dai = 0xe8B0c8A6ED34Cffd85a324DA1D139432F3511c17;
    address usdt = 0xB049D6eA5629ce822DF63491cA6d999A8CB541a8;
    P2PLending lending;

    function run() public {
        uint256 key = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(key);

        // Step 1: Deploy Token Contract
        erc20 = 0x9A4555D5dE09DADf009eC25cbB04DF173747C8Dd;
        
        console.log("ERC20 Deployed at:", address(erc20));

        // Step 2: Deploy Treasury
        treasury = new Treasury(msg.sender, address(erc20));
        console.log("Treasury Deployed at:", address(treasury));

        // Step 3: Deploy Staking Contract
        stakErc20 = new StakERC20(msg.sender, address(erc20));
        console.log("Staking Contract at:", address(stakErc20));

        // Step 4: Deploy NFT Contract
        revoNft = new RevoNft(msg.sender);
        console.log("NFT Contract at:", address(revoNft));

        // Step 5: Deploy Swapper
        swap = new Swapper(msg.sender);
        console.log("Swapper Contract at:", address(swap));

        // Step 6: Deploy P2P Lending Contract
        lending = new P2PLending(
            msg.sender,
            address(treasury),
            address(erc20),
            address(usdt),
            address(dai)
        );
        console.log("P2P Lending Contract at:", address(lending));

        // Step 7: Deploy DAO Contract
        dao = new DAO(
            3,
            address(treasury),
            address(revoNft),
            address(erc20),
            address(stakErc20),
            address(swap),
            address(lending)
        );
        console.log("DAO Contract at:", address(dao));

        vm.stopBroadcast();
    }
}