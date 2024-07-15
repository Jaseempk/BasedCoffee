//SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

import {Test} from "./../../lib/forge-std/src/Test.sol";
import {BasedCoffee} from "./../../src/BasedCoffee.sol";

contract BasedCoffeeTest is Test {
    BasedCoffee basedCoffee;
    uint256 public usdValue = 5;

    address public ethPriceFeedAddress =
        0x694AA1769357215DE4FAC081bf1f309aDC325306;
    address public supportedAddress =
        0x66aAf3098E1eB1F24348e84F509d8bcfD92D0620;

    function setUp() external {
        basedCoffee = new BasedCoffee(ethPriceFeedAddress);
    }

    function test_buyACoffeeWithEth() public {
        vm.deal(address(this), 10 ether);
        basedCoffee.buyACoffeeWithEth(supportedAddress, usdValue);
    }

    function test__revertsWhen__callerIsNotOwner() public {
        address user1 = makeAddr("user1");
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        vm.expectRevert();
        basedCoffee.buyACoffeeWithEth(supportedAddress, usdValue);
    }

    function testMustRevert_whenInvalid_supportedAddress() public {
        vm.deal(address(this), 3 ether);
        vm.expectRevert(BasedCoffee.BC__InvalidFunctionParams.selector);
        basedCoffee.buyACoffeeWithEth(address(0), usdValue);
    }

    function testMustRevert_whenInvalid_usdValue() public {
        vm.deal(address(this), 3 ether);
        vm.expectRevert(BasedCoffee.BC__InvalidFunctionParams.selector);
        basedCoffee.buyACoffeeWithEth(supportedAddress, 0);
    }
}
