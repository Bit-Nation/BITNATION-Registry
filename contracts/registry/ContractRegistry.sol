pragma solidity ^0.4.4;

contract ContractRegistry {
  mapping (address => Contract) public allContracts;

  struct Contract {
    address owner;

    bool isActive;
    uint activeSince;
    uint inactiveSince;

    Vote[] allVotes;
    mapping (address => bool) didVote;
  }

  struct Vote {
    address voter;
    bool inSupport;

    uint timestamp;
  }

  event ContractAdded(address contractAddr, address owner);
  event ContractDeactivated(address contractAddr);

  event OwnershipTransfered(address contractAddr, address oldOwner, address newOwner);

  event NewVote(address contractAddr, address voter, bool inSupport, uint voteId);

  function claimContract(address contractAddr) {
    require(allContracts[contractAddr].owner == address(0x0));

    Contract c = allContracts[contractAddr];
    c.owner = msg.sender;
    c.isActive = true;
    c.activeSince = now;

    ContractAdded(contractAddr, msg.sender);
  }

  function transferOwnership(address contractAddr, address newOwner) {
    require(msg.sender != newOwner);
    require(allContracts[contractAddr].owner == msg.sender);
    require(allContracts[contractAddr].isActive);

    allContracts[contractAddr].owner = newOwner;

    OwnershipTransfered(contractAddr, msg.sender, newOwner);
  }

  function deactivateContract(address contractAddr) {
    require(allContracts[contractAddr].owner == msg.sender);

    allContracts[contractAddr].isActive = false;
    allContracts[contractAddr].inactiveSince = now;

    ContractDeactivated(contractAddr);
  }

  function voteOnContract(address contractAddr, bool inSupport) returns (uint voteId) {
    require(allContracts[contractAddr].isActive);
    require(!allContracts[contractAddr].didVote[msg.sender]);

    allContracts[contractAddr].didVote[msg.sender] = true;

    voteId = allContracts[contractAddr].allVotes.length++;

    Vote v = allContracts[contractAddr].allVotes[voteId];
    v.voter = msg.sender;
    v.inSupport = inSupport;
    v.timestamp = now;

    NewVote(contractAddr, msg.sender, inSupport, voteId);
  }

  function getVote(address contractAddr, uint voteId) constant returns (address voter, bool inSupport, uint timestamp) {
    Vote v = allContracts[contractAddr].allVotes[voteId];
    voter = v.voter;
    inSupport = v.inSupport;
    timestamp = v.timestamp;
  }
}
