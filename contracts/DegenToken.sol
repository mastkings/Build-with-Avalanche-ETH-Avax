// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DegenToken is ERC20 {
    mapping(uint256 => uint256) private _redemptionRates;
    mapping(address => mapping(uint256 => uint256)) private _userRedemptions; // Tracks user redemptions per item
    mapping(uint256 => string) private _itemNames; // Maps item IDs to their names
    uint256 public constant MAX_REDEMPTION_PER_ITEM = 100; // Maximum number of items a user can redeem

    // Stores redemption rates for various items
    event ItemRedeemed(address indexed user, uint256 itemId, uint256 amount);
    event RedemptionRateChanged(uint256 itemId, uint256 newRate);
    event ItemNameSet(uint256 itemId, string name);

    // Initializes the token with a name and symbol, and sets initial item names.
    constructor() ERC20("Degen Token", "DGN") {
        _setItemName(1, "Book");
        _setItemName(2, "Car");
        _setItemName(3, "Shirt");
        _setItemName(4, "Shoe");
        _setItemName(5, "Mango");
    }

    // Mints tokens to a specified address. Restricted to contract owner.
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    // Redeems tokens for items, burning tokens in the process.
    function redeem(uint256 itemId, uint256 amount) public {
        require(_userRedemptions[msg.sender][itemId] + amount <= MAX_REDEMPTION_PER_ITEM, "Exceeds maximum redemption per item");
        require(bytes(_itemNames[itemId]).length > 0, "Item ID does not exist");

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
    function setRedemptionRate(uint256 itemId, uint256 rate) public {
        require(bytes(_itemNames[itemId]).length > 0, "Item ID does not exist");
        _redemptionRates[itemId] = rate;
        emit RedemptionRateChanged(itemId, rate); // Emit an event when the rate changes
    }

    // Sets the name for a specific item. Restricted to contract owner.
    function setItemName(uint256 itemId, string memory name) public {
        _setItemName(itemId, name);
    }

    // Retrieves the redemption rate for a specific item.
    function getRedemptionRate(uint256 itemId) public view returns (uint256) {
        return _redemptionRates[itemId];
    }

    // Retrieves the name of a specific item.
    function getItemName(uint256 itemId) public view returns (string memory) {
        require(bytes(_itemNames[itemId]).length > 0, "Item ID does not exist");
        return _itemNames[itemId];
    }

    // Private helper function to calculate the required tokens for redemption.
    function _getRequiredTokensForRedemption(uint256 itemId, uint256 amount) private view returns (uint256) {
        require(_redemptionRates[itemId] > 0, "Invalid item ID");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        return _redemptionRates[itemId] * amount;
    }

    // Private helper function to set the name for a specific item.
    function _setItemName(uint256 itemId, string memory name) private {
        _itemNames[itemId] = name;
        emit ItemNameSet(itemId, name); // Emit an event when the item name is set
    }
}
