// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";


contract FindTrumanAchievement is Initializable, ERC721Upgradeable, AccessControlUpgradeable, UUPSUpgradeable {


    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    mapping(uint256 => uint256) public ftaSceneId;

    function initialize() initializer public {
        __ERC721_init("FindTrumanTestAchievement", "FTA");
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://findtruman.io/co-creation/nft/fta/";
    }

    function safeMint(address to, uint256 tokenId, uint256 sceneId) public onlyRole(MINTER_ROLE) {
        ftaSceneId[tokenId] = sceneId;
        _safeMint(to, tokenId);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}