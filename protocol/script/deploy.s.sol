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
    address erc20 = 0xbC3AafFBbB0618F3808E626aA5DB96D623161AFc;
    address dai = 0x51099Aa160B7709d9d1B8164abC8668AaB24B242;
    address usdt = 0x8e74Dbce9C5070E92795806D95b690469f685EbF;
    address rvlPriceFeed = 0xB5d3e4080dF612d33E78A523c9F4d3362ee2EC48;
      address _initialOwner = msg.sender;
        address usdtPriceFeed = 0xAE17aC6B7565176B9dDAD32E0dFFdC52A221b351;
        address daiPriceFeed = 0x7a0335B768C855792F225626F18de5291f142Ec9;
         address ethPriceFeed = 0x91f3Ff344623aDC499eC6A34fC6311e8Abbf7880;
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
        swap = new Swapper(    
        );
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