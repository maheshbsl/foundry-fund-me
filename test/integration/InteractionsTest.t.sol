// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from  "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract FundMeTestIntegration is Test {
    FundMe fundMe;
    HelperConfig helperConfig;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_VALUE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // creating a new instance of DeployFundMe 
        DeployFundMe deployFundMe = new DeployFundMe();
        (fundMe, helperConfig) = deployFundMe.run();
        vm.deal(USER, STARTING_VALUE);
   }

    function testUserCanFundInteractions() public {
        //creating a new instance of the FundFundMe contract
        FundFundMe fundFundMe = new FundFundMe();
        //funding using `fundFundMe` contract withourt directlly interacting with
        //fund() function from FundMe contract.
        fundFundMe.fundFundMe(address(fundMe));

        
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}