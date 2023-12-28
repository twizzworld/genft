// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title FractionalOwnershipManager
 * @dev Contract to manage fractional ownership of NFTs.
 */
contract FractionalOwnershipManager {
    struct OwnershipShare {
        address owner;
        uint256 share; // Represented as a percentage (0-100)
    }

    // Mapping from tokenId to an array of OwnershipShares
    mapping(uint256 => OwnershipShare[]) public ownershipShares;

    // Event emitted when ownership is initialized or updated
    event OwnershipUpdated(uint256 indexed tokenId, address indexed owner, uint256 share);

    /**
     * @dev Initializes fractional ownership for a given tokenId.
     * @param tokenId The NFT token ID.
     * @param owners Array of addresses representing owners.
     * @param shares Array of shares corresponding to each owner.
     */
    function initializeOwnership(uint256 tokenId, address[] memory owners, uint256[] memory shares) external {
        require(owners.length == shares.length, "Owners and shares length mismatch");
        delete ownershipShares[tokenId]; // Clear existing ownership data

        uint256 totalShares = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            require(shares[i] > 0 && shares[i] <= 100, "Invalid share value");
            ownershipShares[tokenId].push(OwnershipShare(owners[i], shares[i]));
            totalShares += shares[i];
            emit OwnershipUpdated(tokenId, owners[i], shares[i]);
        }

        require(totalShares == 100, "Total shares must equal 100%");
    }

    /**
     * @dev Transfers a fractional share of an NFT to another address.
     * @param tokenId The NFT token ID.
     * @param from Address transferring the share.
     * @param to Address receiving the share.
     * @param shareAmount The amount of share to transfer.
     */
    function transferShare(uint256 tokenId, address from, address to, uint256 shareAmount) external {
        require(shareAmount > 0 && shareAmount <= 100, "Invalid share amount");
        require(from != to, "Transfer to same address");

        uint256 totalSharesTransferred = 0;
        for (uint256 i = 0; i < ownershipShares[tokenId].length; i++) {
            if (ownershipShares[tokenId][i].owner == from) {
                require(ownershipShares[tokenId][i].share >= shareAmount, "Insufficient share");
                ownershipShares[tokenId][i].share -= shareAmount;
                totalSharesTransferred += shareAmount;
                emit OwnershipUpdated(tokenId, from, ownershipShares[tokenId][i].share);

                if (ownershipShares[tokenId][i].share == 0) {
                    // Remove the owner if their share is now zero
                    removeOwner(tokenId, i);
                }
                
                break; // Assuming each address only appears once in the array
            }
        }

        require(totalSharesTransferred == shareAmount, "Share transfer failed");

        bool recipientExists = false;
        for (uint256 j = 0; j < ownershipShares[tokenId].length; j++) {
            if (ownershipShares[tokenId][j].owner == to) {
                ownershipShares[tokenId][j].share += shareAmount;
                recipientExists = true;
                emit OwnershipUpdated(tokenId, to, ownershipShares[tokenId][j].share);
                break;
            }
        }

        if (!recipientExists) {
            ownershipShares[tokenId].push(OwnershipShare(to, shareAmount));
            emit OwnershipUpdated(tokenId, to, shareAmount);
        }
    }

    /**
     * @dev Removes an owner from the ownership array.
     * @param tokenId The NFT token ID.
     * @param index The index of the owner to remove.
     */
    function removeOwner(uint256 tokenId, uint256 index) private {
        require(index < ownershipShares[tokenId].length, "Invalid index");
        ownershipShares[tokenId][index] = ownershipShares[tokenId][ownershipShares[tokenId].length - 1];
        ownershipShares[tokenId].pop();
    }

}
