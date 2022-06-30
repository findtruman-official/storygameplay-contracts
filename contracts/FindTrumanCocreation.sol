// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "./FindTrumanAchievement.sol";
import "./FindTrumanToken.sol";

contract FindTrumanCocreation is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter public _tokenIdCounter;

    bytes32 public merkleRoot;

    mapping(bytes32 => bool) public usedMerkleLeaf;

    FindTrumanAchievement public fta;
    FindTrumanToken public ftt;

    mapping(address => mapping(uint256 => uint256)) public claimedSceneTokens;

    function initialize(address _fta, address _ftt)
        public
        initializer
    {
        __Ownable_init();
        __UUPSUpgradeable_init();

        fta = FindTrumanAchievement(_fta);
        ftt = FindTrumanToken(_ftt);
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    
    function formatAchievementRewardTokensLeaf(
        address _addr,
        uint256 _sceneId,
        uint256 _tokens
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("aw", _addr, _sceneId, _tokens));
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

        // After the scene reward points are changed, it should be able to make up for the increased points.
        uint256 alreadyClaimed = claimedSceneTokens[msg.sender][_sceneId];
        if (alreadyClaimed < _tokens) {
            ftt.mint(msg.sender,  _tokens - alreadyClaimed);
        }
        
        usedMerkleLeaf[leaf] = true;
        claimedSceneTokens[msg.sender][_sceneId] = _tokens;
    }

    function claimAchievement(uint256 _sceneId, bytes32[] memory _proofs) public {
        bytes32 leaf = formatClaimableAchievementLeaf(msg.sender, _sceneId);
        require(
            MerkleProofUpgradeable.verify(_proofs, merkleRoot, leaf),
            "invalid proof"
        );
        require(!usedMerkleLeaf[leaf], "already claimed");
        
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();        
        
        fta.safeMint(msg.sender, tokenId, _sceneId);

        usedMerkleLeaf[leaf] = true;
    }
    
    // utils
    function formatClaimableAchievementLeaf(address _addr, uint256 _sceneId)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked("ach", _addr, _sceneId));
    }
    
}
