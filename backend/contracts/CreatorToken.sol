// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract CreatorToken is ERC20Votes {
    constructor(
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) ERC20Permit(name) {}

    function mint(address to, uint256 amount) external {
        // Only campaign contract can mint (add access control in production)
        _mint(to, amount);
    }
}
