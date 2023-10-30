// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract KlerosInheritance {
    /**
     * STORAGE
     */

    uint256 public lastActivity;
    uint256 public constant timeLock = 30 days;
    address public owner;
    address public heir;

    /**
     * EVENTS
     */

    event OwnerUpdated(address indexed oldOwner, address indexed newOwner);
    event HeirUpdated(address indexed oldHeir, address indexed newHeir);
    event Withdrawn(uint256 amount);
    event LastActivityUpdated(uint256 newLastActivity);

    /**
     * CONSTRUCTOR
     */

    constructor(address _owner, address _heir) {
        if (_owner == address(0)) _setOwner(msg.sender);
        else _setOwner(_owner);

        _setHeir(_heir);

        lastActivity = block.timestamp;
        emit LastActivityUpdated(block.timestamp);
    }

    /**
     * MODIFIER
     */

    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner can call this function.");
        _;
    }

    /**
     * PUBLIC
     */

    // @notice Function for only owner to withdraw ETH from the contract.
    // @param amount The amount of ETH in wei to withdraw from the account.
    // @dev As only owner can call this function, there is no further checks required.
    function withdraw(uint256 amount) public onlyOwner returns (bool status) {
        require(amount != 0 && amount <= address(this).balance, "Invalid Amount");

        (status,) = msg.sender.call{value: amount}("");
        emit Withdrawn(amount);

        _ownerActive();
    }

    // @notice Function for owner to mark activity.
    function ownerActive() public onlyOwner {
        _ownerActive();
    }

    function takeControl(address _newHeir) public {
        require(heir == msg.sender, "Only heir can call this function");
        require(lastActivity + timeLock < block.timestamp, "Timelock not passed yet.");

        _setOwner(msg.sender);
        _setHeir(_newHeir);
        _ownerActive();
    }

    /**
     * INTERNAL
     */

    // @dev Calling function should check for zero address.
    function _setOwner(address _owner) internal {
        emit OwnerUpdated(owner, _owner);
        owner = _owner;
    }

    function _setHeir(address _heir) internal {
        require(_heir != address(0), "Heir can't be zero address.");
        emit HeirUpdated(heir, _heir);
        heir = _heir;
    }

    function _ownerActive() internal {
        lastActivity = block.timestamp;
        emit LastActivityUpdated(block.timestamp);
    }

    fallback() external payable {}
    receive() external payable {}
}
