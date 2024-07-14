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

    AggregatorV3Interface ethPriceFeed;
    uint256 public constant ADDITIONAL_PRECISION = 1e8;

    mapping(address => mapping(address => uint256))
        public supporterToSUppportedAddress;

    constructor(address ethFeedAddress) ConfirmedOwner(msg.sender) {
        ethPriceFeed = AggregatorV3Interface(ethFeedAddress);
    }

    /**
     * @notice This function lets owner to tip ETH to desired address
     * @param _supportedAddress address we wanna tip the ETH
     * @param _usdValue USD value we wanna tip
     */
    function buyACoffee(
        address _supportedAddress,
        uint256 _usdValue
    ) public onlyOwner {
        uint256 ethInWeiWorthUsd = getEthInWorth4USD(_usdValue);
        (bool succ, bytes memory data) = _supportedAddress.call{
            value: ethInWeiWorthUsd * 1 ether
        }("");
        if (!succ) revert BC__CoffeePurchaseFailed();
    }

    /**
     * @notice Returns the ETH value worth the USD we need to tip
     * @param _usdValue USD value  you need to tip
     */
    function getEthInWorth4USD(
        uint256 _usdValue
    ) internal view returns (uint256) {
        (, int256 _price, , , ) = ethPriceFeed.latestRoundData();
        uint256 ethPrice = uint256(_price);

        return (_usdValue * ADDITIONAL_PRECISION) / ethPrice;
    }
}
