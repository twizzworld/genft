// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./FractionalOwnershipManager.sol"; 

/**
 * @title GENFTMintingContract
 * @dev Contract for minting GENFT NFTs. Compliant with the ERC-721 standard.
 */
contract GENFTMintingContract is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    // Base URI for NFT metadata
    string private _baseTokenURI;

    /**
     * @dev Constructor for GENFTMintingContract.
     * @param name Name of the NFT collection.
     * @param symbol Symbol of the NFT collection.
     * @param baseTokenURI Base URI for NFT metadata.
     */
    constructor(string memory name, string memory symbol, string memory baseTokenURI) ERC721(name, symbol) {
        _baseTokenURI = baseTokenURI;
    }

   // Reference to the Fractional Ownership Manager contract
    FractionalOwnershipManager private ownershipManager;

    // Modified mint function to handle fractional ownership
    function safeMint(address[] memory owners, uint256[] memory shares) public onlyOwner {
        require(owners.length == shares.length, "Owners and shares length mismatch");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(address(ownershipManager), tokenId); // Mint to the ownership manager contract

        // Delegate the management of fractional ownership to the FractionalOwnershipManager
        ownershipManager.initializeOwnership(tokenId, owners, shares);
    }

    /**
     * @dev Override for base URI.
     */
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev Set the base URI for NFT metadata. Can only be called by the owner.
     * @param baseTokenURI New base URI.
     */
    function setBaseURI(string memory baseTokenURI) public onlyOwner {
        _baseTokenURI = baseTokenURI;
    }

}
