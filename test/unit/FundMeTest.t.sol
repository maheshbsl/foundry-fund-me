// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from  "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; //100000000000000000
    uint256 constant STARTING_VALUE = 10 ether;
    uint256 constant GAS_PRICE = 100;
    
    //setUp() function is executed before each test case to initialize
    //any necessry state, In this case, it create a new instane of 
    //`FundMe` contract named `fundMe`.

    function setUp() external {
        //creating a new instance of the contract DeployFundMe named deployFundMe
        DeployFundMe deployFundMe = new DeployFundMe();
        //deploying the fundME using the new instance `deployFundMe`
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_VALUE);
    }

    function testMinimumDollarIsFive() public view {
        //assertEq is a helper function provided by `forge-std` that
        //asserts the equality of two values, if `fundMe.MINIMUM_USD()` 
        //is not equal to `5e18` the test will fail

        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public  view {
        console.log(fundMe.i_owner());
        console.log(msg.sender);
        assertEq(fundMe.i_owner(), msg.sender);
    }

    /**
    The four common types of tests in smart contract development are:
    **1..Unit Test
    --------------
    ==> These are small, focused tests that check individual functions or components of 
        your smart contract in isolation
    ==> Goal : Ensure specific functionality works as expected without considering 
        external dependencies or interactions.

    **2..Integration Test
    -----------------------
    ==> These test focus on how multiple components or contracts interact with each other.
    ==> Goal: Validate that the integration between different contracts or modules
    behaves as expected in conjuction.

    **3..Forked Test
    ----------------
    ==> Forked tests simulate the blockchain state from a live network(like Ethereum mainnet) by
    forking its state.
    ==> Goal: Test smart contracts in a simulated real-world blockchain environment,
    allowing you to use real data without needing to deploy contracts.

    **4..Staging Tests
    ------------------
    ==> Staging tests are performed in a test environment that mimics the production environment
    as closely as possible.
    ==> Goal: Ensure the contract works as expected before it is deployed to mainnet by testing
    it in an environment that mirrors real-world conditions.
        
     */

    function testPriceFeedVersionIsAccurate() public  view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public  {
        //asserts that nextcall will revert, regardless of the message
        //if next call reverts pass the test, otherwise fail
        vm.expectRevert();
        fundMe.fund(); //funding with value / this wll pass
    }

    function testFundUpdatesFundedDataStructure() public {

        vm.prank(USER); // The next TX will be sent by user.
        //we have to give this user some money with `vm.deal(USER, STARTING_VALUE)` cheat code

        //Make a fund
        fundMe.fund{value: SEND_VALUE}();
        //amount funded
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        //assert that value
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders () public {
        vm.prank(USER);
        //make a fund
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        //arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //act
        vm.prank(fundMe.getOwner()); // next tx are going to be by owner
        //now withdraw as owner
        fundMe.withdraw();

        //assert
        //since we have withdrawed all money , the fundMe balance will be 0
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);    
    }

    function testWithdrawFromMultipleFunders() public {
        //Arrange

        uint160 numbersOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i < numbersOfFunders; i++) {
            //vm.prank(address)
            //vm.deal(address)
            //address()

            hoax(address(i), STARTING_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        //now withdraw the money as owner
        vm.startPrank(fundMe.getOwner()); 
        vm.txGasPrice(GAS_PRICE);
        fundMe.withdraw();
        vm.stopPrank();
        //assert
        
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }
}