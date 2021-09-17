// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

contract stakingArena is AccessControlUpgradeable {
    using SafeMathUpgradeable for uint256;

    // keccak256("DEFAULT_ADMIN_ROLE");
    bytes32 internal constant ADMIN_ROLE =
        0x1effbbff9c66c5e59634f24fe842750c60d18891155c32dd155fc2d661a4c86d;

    uint8 public counter;

    enum TokenTypes {
        ERC1155,
        ERC721
    }

    struct Pool {
        uint256 tokenId;
        address tokenAddress;
        TokenTypes tokenType;
        uint256 allocPoint;
        uint256 lastRewardBlock;
    }

    mapping(uint8 => Pool) public poolInfo;
    mapping(address => mapping(uint256 => uint8)) public poolIdByAddress;

    IERC1155Upgradeable tazos;

    function initialize(IERC1155Upgradeable _tazos) public initializer {
        tazos = _tazos;
        _setupRole(ADMIN_ROLE, _msgSender());
    }

    function createPool(
        uint256 _tokenId,
        address _tokenAddress,
        string calldata _tokenType,
        uint256 _allocPoint
    ) external onlyRole(ADMIN_ROLE) {
        require(
            poolIdByAddress[_tokenAddress][_tokenId] == 0,
            "StakingArena: Pool already exists"
        );
        counter++;

        TokenTypes tokenType = keccak256(abi.encodePacked(_tokenType)) ==
            keccak256(abi.encodePacked("ERC721"))
            ? TokenTypes.ERC721
            : TokenTypes.ERC1155;

        Pool memory pool = Pool({
            tokenId: _tokenId,
            tokenAddress: _tokenAddress,
            tokenType: tokenType,
            allocPoint: _allocPoint,
            lastRewardBlock: block.number
        });

        poolInfo[counter] = pool;
        poolIdByAddress[_tokenAddress][_tokenId] = counter;
    }

    function deposit(uint256 _pid, uint256 _amount) public {}

    function withdraw(uint256 _pid, uint256 _amount) public {}
}
