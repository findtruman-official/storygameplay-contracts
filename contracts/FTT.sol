// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";

contract FTT is
    Initializable,
    ERC20Upgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    // merkle tree root
    bytes32 public merkleRoot;

    mapping(bytes32 => bool) public usedMerkleLeaf;

    mapping(address => mapping(uint32 => bool)) public claimableTokens;

    function initialize(string memory name, string memory symbol)
        public
        initializer
    {
        __ERC20_init(name, symbol);
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function formatAchievementRewardTokensLeaf(
        address _addr,
        uint256 _sceneId,
        uint256 _tokens
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("sw", _addr, _sceneId, _tokens));
    }

    function claimAchievementRewardTokens(
        uint256 _sceneId,
        uint256 _tokens,
        bytes32[] memory _proofs
    ) public {
        bytes32 leaf = formatAchievementRewardTokensLeaf(
            msg.sender,
            _sceneId,
            _tokens
        );
        require(
            MerkleProofUpgradeable.verify(_proofs, merkleRoot, leaf),
            "invalid proof"
        );
        require(!usedMerkleLeaf[leaf], "already claimed");
        _mint(msg.sender, _tokens);
        usedMerkleLeaf[leaf] = true;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}
}
