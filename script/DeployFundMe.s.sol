// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    //run() is the entry point where the script that Foundry will call when
    //executing the script.
    function run() external returns (FundMe) {

        //Before Broadcast , we will decide the price feed
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();



        /* 
        vm.startBroadcast() is a function provided by Foundry's Script utility
        this means any state-chaning operation (like contract deployment)
        will be broadcasted as a transaction.

        Before calling vm.startBroadcast() no actual transactions are sent to
        the blockcahin.It is typically used to separate non-broadcast logic
        like setup or reading from actual on-chain transactions.

        */
        vm.startBroadcast();
        /*
        new FundMe()
        ------------
        This deploys a new instance of the FundMe contract.
        Since the `new` keyword is used, this will broadcast a transaction that 
        deploys the `FundMe` contract on the blockchain.
        The contract constructor is called at this point.

         */
        FundMe fundMe = new FundMe(ethUsdPriceFeed);

        /*
        vm.stopBroadcast()
        ------------------
        This tells Foundry to stop broadcasting transacions.
        Any operations after this line will not be broadcast to the blockchain.
        It helps to make sure that only the deployment and relavent state changes
        are broadcasted and not any unrelated logic after the deployment.

         */
        vm.stopBroadcast();
        return fundMe;

        /**
        How it works
        ------------
        When this script is executed(via forge), it will broadcast a transaction 
        that deploys the `FundMe` contract on the selected blockchain(testnet or Mainnet)
        or a local environment, depending on your configuration.

        The deployment process is enclosed between `vm.startBroadcast()`
        and `vm.stopBroadcast() to ensure that only deployment transaciton is sent
        to the blockchain.
        */   
    }
}