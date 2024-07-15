//SPDX-License-Identifier:MIT

pragma solidity ^0.8.24;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.4/interfaces/AggregatorV3Interface.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

/**
 * @title BasedCoffee
 * @author
 * @notice This smart contract lets you tip an address with any desired value of USD worth of ETH
 */
contract BasedCoffee is ConfirmedOwner {
    error BC__CoffeePurchaseFailed();
    error BC__InvalidFunctionParams();

    AggregatorV3Interface ethPriceFeed;
    AggregatorV3Interface erc20PriceFeed;
    address public immutable i_ethFeedAddress;
    uint256 public constant ADDITIONAL_PRECISION = 1e8;

    mapping(address => mapping(address => uint256))
        public supporterToSUppportedAddress;

    constructor(address ethFeedAddress) ConfirmedOwner(msg.sender) {
        i_ethFeedAddress = ethFeedAddress;
    }

    /**
     * @notice This function lets owner to tip ETH to desired address
     * @param _supportedAddress address we wanna tip the ETH
     * @param _usdValue USD value we wanna tip
     */
    function buyACoffeeWithEth(
        address _supportedAddress,
        uint256 _usdValue
    ) public onlyOwner {
        if (_supportedAddress == address(0) || _usdValue == 0)
            revert BC__InvalidFunctionParams();
        uint256 ethInWeiWorthUsd = getEthWorthUsdValue(_usdValue);
        (bool succ, bytes memory data) = _supportedAddress.call{
            value: ethInWeiWorthUsd * 1 ether
        }("");
        if (!succ) revert BC__CoffeePurchaseFailed();
    }

    /**
     * @notice Returns the ETH value worth the USD we need to tip
     * @param _usdValue USD value  you need to tip
     */
    function getEthWorthUsdValue(uint256 _usdValue) internal returns (uint256) {
        ethPriceFeed = AggregatorV3Interface(i_ethFeedAddress);

        (, int256 _price, , , ) = ethPriceFeed.latestRoundData();
        uint256 ethPrice = uint256(_price);

        return (_usdValue * ADDITIONAL_PRECISION) / ethPrice;
    }
}
