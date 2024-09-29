//SPDX-License-Identifier: MIT

//1.Deploy mocks when we are on a local anvil chain and return the address
//2.Keep track of contract address accross different chain

/**
This `HelperConfig` contract is desingned to provide different configurations for various
networks base on the chainID. The goal is to setup a price feed for the contract
depending on which network it is deployed on(eg sepolia, ethereum mainnet, or a local anvil)
 */


pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
    // If we are on a local anvil, we deploy mocks
    // Otherwise, grab the existing address from the network
   
   //A variable of the struct type and it holds the active configuration 
   //based on the blockchain on which the contract is deployed.
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMAL = 8;
    int256 public constant INITIAL_PRICE = 2000e8;
    
    //this hold the address of the priceFeed
    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if(block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        }else if (block.chainid == 1) {
            activeNetworkConfig = ethMainConfig();
        }else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public  pure returns (NetworkConfig memory) {
        //price feed address 
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;   
    }

    function ethMainConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return ethConfig;
    }
   
    
    //Deploys a mock priceFeed using `MockV3Aggregator` and returns the local network config using the mock priceFeed address.
    //This is used for local development on an Anvil chain or test environment.
    function getAnvilEthConfig() public  returns (NetworkConfig memory) {
        // If priceFeed is already set, return the existing config
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        //deploy the mock priceFeed contract
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMAL, INITIAL_PRICE);
        vm.stopBroadcast();
        
        //return the config with the mockPriceFeed address
        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;

    }
}