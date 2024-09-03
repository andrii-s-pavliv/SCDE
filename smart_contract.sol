// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Smart Contract for Data Expiry (SCDE)
 * @dev Manages data retention and automated secure deletion in compliance with GDPR.
 */
contract SCDE {
    // Mapping from data ID to expiry date and deletion status
    mapping(bytes32 => DataRecord) public dataRegistry;

    struct DataRecord {
        uint256 expiryDate;
        bool isDeleted;
    }

    // Event to log data expiry set
    event DataExpirySet(bytes32 indexed dataId, uint256 expiryDate);

    // Event to log data deletion
    event DataDeleted(bytes32 indexed dataId);

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // Modifier to check if the caller is the owner of the contract
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    /**
     * @dev Sets or updates the expiry date for given data ID.
     * @param dataId Identifier of the data.
     * @param expiryDate Timestamp when the data should expire.
     */
    function setDataExpiry(bytes32 dataId, uint256 expiryDate) public onlyOwner {
        require(expiryDate > block.timestamp, "Expiry date must be in the future");
        dataRegistry[dataId].expiryDate = expiryDate;
        emit DataExpirySet(dataId, expiryDate);
    }

    /**
     * @dev Checks and deletes data if the expiry date has passed.
     * @param dataId Identifier of the data to check.
     */
    function checkAndDeleteData(bytes32 dataId) public {
        require(dataRegistry[dataId].expiryDate > 0, "Data expiry not set");
        require(block.timestamp >= dataRegistry[dataId].expiryDate, "Data expiry date has not passed");
        require(!dataRegistry[dataId].isDeleted, "Data already deleted");

        dataRegistry[dataId].isDeleted = true;
        // Logic to securely erase the data could involve interacting with an external system or key management.
        emit DataDeleted(dataId);
    }

    /**
     * @dev Retrieves the deletion status of the specified data ID.
     * @param dataId Identifier of the data.
     * @return isDeleted Boolean indicating if the data has been deleted.
     */
    function isDataDeleted(bytes32 dataId) public view returns (bool isDeleted) {
        return dataRegistry[dataId].isDeleted;
    }

    /**
     * @dev Transfers contract ownership to a new owner.
     * @param newOwner Address of the new owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        owner = newOwner;
    }
}
