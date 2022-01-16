// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

interface ITazos is IERC1155Upgradeable {
    /**
     * @notice burns tokens
     * @param account the address of the user
     * @param id the id of the token
     * @param value the amount to be burned
     */
    function burnFrom(
        address account,
        uint256 id,
        uint256 value
    ) external;

    /**
     * @notice mints tokens
     * @param to the address of the user
     * @param id the current period value
     * @param amount units of token to mint
     */
    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;
}
