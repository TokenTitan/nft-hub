// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";

import "./interfaces/ITazos.sol";

contract StakingArena is ERC1155HolderUpgradeable, AccessControlUpgradeable {
    using SafeMathUpgradeable for uint256;

    // keccak256("DEFAULT_ADMIN_ROLE");
    bytes32 internal constant ADMIN_ROLE =
        0x1effbbff9c66c5e59634f24fe842750c60d18891155c32dd155fc2d661a4c86d;
    uint256 constant public UNIT = 10**18;
    uint256 constant public PERIOD_DURATION = 30 days;
    uint256 constant public REWARD_PER_PERIOD = 1;

    uint8 public counter;
    uint256 public totalAllocPoint;
    uint256 public startTime;
    uint256 public currentPeriod;

    ITazos tazos;

    enum TokenTypes {
        ERC1155,
        ERC721
    }

    struct Pool {
        uint256 tokenId;
        address tokenAddress;
        TokenTypes tokenType;
        uint256 allocPoint;
        uint256 lastRewardPeriod;
    }

    mapping(uint8 => Pool) public poolInfo;
    mapping(address => mapping(uint256 => uint8)) public poolIdByAddress;

    function initialize(ITazos _tazos) public initializer {
        tazos = _tazos;
        startTime = block.timestamp;
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
            lastRewardPeriod: currentPeriod
        });

        poolInfo[counter] = pool;
        poolIdByAddress[_tokenAddress][_tokenId] = counter;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
    }

    function depositERC1155(uint8 _pid) external {
        Pool memory pool = poolInfo[_pid];
        ITazos _tokenContract = ITazos(pool.tokenAddress);
        uint256 _tokenId = pool.tokenId;

        _tokenContract.safeTransferFrom(
            _msgSender(),
            address(this),
            _tokenId,
            1,
            bytes("")
        );

        tazos.mint(_msgSender(), _pid, 1, bytes(""));
    }

    function withdrawERC1155(uint8 _pid) external {
        Pool memory pool = poolInfo[_pid];
        ITazos _tokenContract = ITazos(pool.tokenAddress);
        uint256 _tokenId = pool.tokenId;
        uint256 _currentPeriod = getCurrentPeriod();
        uint256 _noOfPeriods = _currentPeriod - pool.lastRewardPeriod;
        pool.lastRewardPeriod = _currentPeriod;
        poolInfo[_pid] = pool;

        tazos.burnFrom(_msgSender(), _pid, 1);

        _tokenContract.safeTransferFrom(
            address(this),
            _msgSender(),
            _tokenId,
            1,
            bytes("")
        );

        _issueReward(_noOfPeriods, _pid);
    }

    function getCurrentPeriod() public view returns (uint256) {
        return (block.timestamp - startTime) / PERIOD_DURATION;
    }

    function _issueReward(uint256 _noOfPeriods, uint8 _pid) internal {
        uint256 rewardAmount = (_noOfPeriods * REWARD_PER_PERIOD);
        tazos.mint(_msgSender(), _pid, rewardAmount, bytes(""));
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155ReceiverUpgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
