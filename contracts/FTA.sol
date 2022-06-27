// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";

contract FindTrumanTestAchievement is
    Initializable,
    ERC721Upgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter public _tokenIdCounter;

    bytes32 public merkleRoot;

    mapping(bytes32 => bool) public usedMerkleLeaf;

    function initialize() public initializer {
        __ERC721_init("FindTruman Test Achievement", "FTA");
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://findtruman.io/co-creation/nft/fta/";
    }

    function claim(uint256 _sceneId, bytes32[] memory _proofs) public {
        bytes32 leaf = formatClaimableAchievementLeaf(msg.sender, _sceneId);
        require(
            MerkleProofUpgradeable.verify(_proofs, merkleRoot, leaf),
            "invalid proof"
        );
        require(!usedMerkleLeaf[leaf], "already claimed");
        
        usedMerkleLeaf[leaf] = true;
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }


    // manage functions
    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    // utils
    function formatClaimableAchievementLeaf(address _addr, uint256 _sceneId)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked("ach", _addr, _sceneId));
    }
}
