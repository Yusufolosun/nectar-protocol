// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title MockERC20
 * @notice Simple ERC20 token for testing with mint function
 * @dev This is a mock contract for testing purposes only
 */
contract MockERC20 is ERC20 {
    /**
     * @notice Initializes the mock ERC20 token
     * @param name Token name
     * @param symbol Token symbol
     */
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    /**
     * @notice Mints tokens to an address (testing only)
     * @param to Recipient address
     * @param amount Amount to mint
     */
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    /**
     * @notice Returns 6 decimals (like USDC)
     * @return Number of decimals
     */
    function decimals() public pure override returns (uint8) {
        return 6;
    }
}
