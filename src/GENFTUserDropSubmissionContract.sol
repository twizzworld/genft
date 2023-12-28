// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title GENFTUserDropSubmissionContract
 * @dev Contract for managing user-submitted NFT drops in the GENFT platform.
 */
contract GENFTUserDropSubmissionContract is Ownable {
    struct DropSubmission {
        address submitter;
        string[] categories;
        string[] characteristics;
        uint256 dropDate;
        bool isApproved;
    }

    DropSubmission[] public submissions;

    event DropSubmissionCreated(uint256 indexed submissionId, address indexed submitter);
    event DropSubmissionApproved(uint256 indexed submissionId);
    event DropSubmissionRejected(uint256 indexed submissionId);

    /**
     * @dev Allows users to submit their NFT drop.
     * @param categories Array of categories for the drop.
     * @param characteristics Array of characteristics for each category.
     * @param dropDate The date when the drop is scheduled.
     */
    function submitDrop(string[] memory categories, string[] memory characteristics, uint256 dropDate) external {
        require(categories.length == characteristics.length, "Categories and characteristics length mismatch");

        DropSubmission memory newSubmission = DropSubmission({
            submitter: msg.sender,
            categories: categories,
            characteristics: characteristics,
            dropDate: dropDate,
            isApproved: false
        });

        submissions.push(newSubmission);
        emit DropSubmissionCreated(submissions.length - 1, msg.sender);
    }

    /**
     * @dev Approve a user-submitted drop.
     * @param submissionId The ID of the submission to approve.
     */
    function approveDropSubmission(uint256 submissionId) external onlyOwner {
        require(submissionId < submissions.length, "Invalid submission ID");
        DropSubmission storage submission = submissions[submissionId];
        submission.isApproved = true;
        emit DropSubmissionApproved(submissionId);
    }

    /**
     * @dev Reject a user-submitted drop.
     * @param submissionId The ID of the submission to reject.
     */
    function rejectDropSubmission(uint256 submissionId) external onlyOwner {
        require(submissionId < submissions.length, "Invalid submission ID");
        emit DropSubmissionRejected(submissionId);
    }

    // Additional functions for managing submissions can be added here
}
