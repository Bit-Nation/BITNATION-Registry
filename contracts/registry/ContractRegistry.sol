pragma solidity ^0.4.13;

contract ContractRegistry {
  Contract[] public allContracts;
  uint public numContracts;

  struct Contract {
    address owner;
    address at;

    bool isActive;
    uint activeSince;
    uint inactiveSince;

    Vote[] allVotes;
    uint numVotes;
    mapping (address => bool) didVote;
  }

  struct Vote {
    address voter;
    bool inSupport;

    uint timestamp;
  }

  event ContractAdded(address contractAddr, address owner, uint contractId);
  event ContractDeactivated(uint contractId);

  event OwnershipTransfered(uint contractId, address oldOwner, address newOwner);

  event NewVote(uint contractId, address voter, bool inSupport, uint voteId);

  function claimContract(address contractAddr) returns (uint contractId) {
    contractId = allContracts.length++;

    allContracts[contractId].owner = msg.sender;
    allContracts[contractId].at = contractAddr;
    allContracts[contractId].isActive = true;
    allContracts[contractId].activeSince = now;

    numContracts++;

    ContractAdded(contractAddr, msg.sender, contractId);
  }

  function transferOwnership(uint contractId, address newOwner) {
    require(msg.sender != newOwner);
    require(allContracts[contractId].owner == msg.sender);
    require(allContracts[contractId].isActive);

    allContracts[contractId].owner = newOwner;

    OwnershipTransfered(contractId, msg.sender, newOwner);
  }

  function deactivateContract(uint contractId) {
    require(allContracts[contractId].owner == msg.sender);

    allContracts[contractId].isActive = false;
    allContracts[contractId].inactiveSince = now;

    ContractDeactivated(contractId);
  }

  function voteOnContract(uint contractId, bool voteInSupport) returns (uint voteId) {
    require(allContracts[contractId].isActive);
    require(!allContracts[contractId].didVote[msg.sender]);

    allContracts[contractId].didVote[msg.sender] = true;

    voteId = allContracts[contractId].allVotes.length++;

    allContracts[contractId].allVotes[voteId] = Vote({voter: msg.sender, inSupport: voteInSupport, timestamp: now});

    allContracts[contractId].numVotes++;

    NewVote(contractId, msg.sender, voteInSupport, voteId);
  }

  function getVote(uint contractId, uint voteId) constant returns (address voter, bool inSupport, uint timestamp) {
    voter = allContracts[contractId].allVotes[voteId].voter;
    inSupport = allContracts[contractId].allVotes[voteId].inSupport;
    timestamp = allContracts[contractId].allVotes[voteId].timestamp;
  }
}
