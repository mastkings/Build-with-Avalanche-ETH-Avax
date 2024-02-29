// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DegenToken is ERC20, Ownable {
    mapping(uint256 => uint256) private _redemptionRates;
    mapping(address => mapping(uint256 => uint256)) private _userRedemptions; // Tracks user redemptions per item
    uint256 public constant MAX_REDEMPTION_PER_ITEM = 100; // Maximum number of items a user can redeem

    // Stores redemption rates for various items
    event ItemRedeemed(address indexed user, uint256 itemId, uint256 amount);
    event RedemptionRateChanged(uint256 itemId, uint256 newRate);

     // Initializes the token with a name and symbol.
    constructor() ERC20("Degen Token", "DGN") {}

    // Mints tokens to a specified address. Restricted to contract owner.
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // Redeems tokens for items, burning tokens in the process.
    function redeem(uint256 itemId, uint256 amount) public {
        require(_userRedemptions[msg.sender][itemId] + amount <= MAX_REDEMPTION_PER_ITEM, "Exceeds maximum redemption per item");

        uint256 requiredTokens = _getRequiredTokensForRedemption(itemId, amount);
        _burn(msg.sender, requiredTokens);

        _userRedemptions[msg.sender][itemId] += amount; // Update user's redemption count for the item

        emit ItemRedeemed(msg.sender, itemId, amount);
    }

    // Burns a specified amount of tokens from the sender's account.
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    // Sets the redemption rate for a specific item. Restricted to contract owner.
    function setRedemptionRate(uint256 itemId, uint256 rate) public onlyOwner {
        _redemptionRates[itemId] = rate;
        emit RedemptionRateChanged(itemId, rate); // Emit an event when the rate changes
    }

    // Retrieves the redemption rate for a specific item.
    function getRedemptionRate(uint256 itemId) public view returns (uint256) {
        return _redemptionRates[itemId];
    }

    // Private helper function to calculate the required tokens for redemption.
    function _getRequiredTokensForRedemption(uint256 itemId, uint256 amount) private view returns (uint256) {
        require(_redemptionRates[itemId] > 0, "Invalid item ID");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        return _redemptionRates[itemId] * amount;
    }

}

