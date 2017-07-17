pragma solidity ^0.4.4;

import "zeppelin/contracts/ownership/Ownable.sol";

import "./registry/ConstitutionRegistry.sol";
import "./registry/CodeOfLawRegistry.sol";

contract NationFactory is Ownable {
  mapping (bytes32 => Nation) public allNations;

  ConstitutionRegistry public constitutionRegistry;
  CodeOfLawRegistry public codeOfLawRegistry;

  struct Nation {
    address at;

    string name;
    uint timestamp;

    bytes32 constitution;
    bytes32 codeOfLaw;

    Vote[] allVotes;
    mapping (address => bool) didVote;
  }

  struct Vote {
    address voter;
    bool inSupport;
    uint timestamp;
  }

  event NewNation(bytes32 nation, address at, string name, address registredBy);
  event NewVote(bytes32 nation, address voter, bool inSupport, uint voteId);

  event ConstitutionRegistryChanged(address newRegistry);
  event CodeOfLawRegistryChanged(address newRegistry);

  function NationFactory(address constitution, address codeOfLaw) {
    constitutionRegistry = ConstitutionRegistry(constitution);
    codeOfLawRegistry = CodeOfLawRegistry(codeOfLaw);
  }

  function setConstitutionRegistry(address newRegistry) onlyOwner {
    require(constitutionRegistry != newRegistry);

    constitutionRegistry = ConstitutionRegistry(newRegistry);

    ConstitutionRegistryChanged(newRegistry);
  }

  function setCodeOfLawRegistry(address newRegistry) onlyOwner {
    require(codeOfLawRegistry != newRegistry);

    codeOfLawRegistry = CodeOfLawRegistry(newRegistry);

    CodeOfLawRegistryChanged(newRegistry);
  }

  function addNationAt(string name, address at, bytes32 constitution, bytes32 codeOfLaw) returns (bytes32 hash) {
    hash = sha3(name, msg.sender);
    require(allNations[hash].at == address(0x0));

    // Check that the constitution & codeOfLaw exists
    require(constitutionRegistry.exist(constitution));
    require(codeOfLawRegistry.exist(codeOfLaw));

    Nation n = allNations[hash];
    n.at = at;
    n.name = name;
    n.timestamp = now;
    n.constitution = constitution;
    n.codeOfLaw = codeOfLaw;

    NewNation(hash, at, name, msg.sender);
  }

  function vote(bytes32 nation, bool inSupport) returns (uint voteId) {
    // Check if nation exist
    require(allNations[nation].at != address(0x0));

    // Check if already voted
    require(!allNations[nation].didVote[msg.sender]);

    allNations[nation].didVote[msg.sender] = true;

    voteId = allNations[nation].allVotes.length++;
    Vote v = allNations[nation].allVotes[voteId];
    v.voter = msg.sender;
    v.inSupport = inSupport;
    v.timestamp = now;

    NewVote(nation, msg.sender, inSupport, voteId);
  }

  function getVote(bytes32 nation, uint voteId) constant returns (address voter, bool inSupport, uint timestamp) {
    Vote v = allNations[nation].allVotes[voteId];
    voter = v.voter;
    inSupport = v.inSupport;
    timestamp = v.timestamp;
  }
}
