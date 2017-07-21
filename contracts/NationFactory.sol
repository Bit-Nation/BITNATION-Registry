pragma solidity ^0.4.13;

import "/zeppelin/contracts/ownership/Ownable.sol";

import "./registry/ConstitutionRegistry.sol";
import "./registry/CodeOfLawRegistry.sol";

contract NationFactory is Ownable {
  Nation[] public allNations;
  uint public numNations;

  ConstitutionRegistry public constitutionRegistry;
  CodeOfLawRegistry public codeOfLawRegistry;

  struct Nation {
    address at;

    string name;
    uint timestamp;

    uint constitution;
    uint codeOfLaw;

    Vote[] allVotes;
    uint numVotes;
    mapping (address => bool) didVote;
  }

  struct Vote {
    address voter;
    bool inSupport;
    uint timestamp;
  }

  event NewNation(uint nationId, address at, string name, address registredBy);
  event NewVote(uint nationId, address voter, bool inSupport, uint voteId);

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

  function addNationAt(string name, address at, uint constitutionId, uint codeOfLawId) returns (uint nationId) {
    // Check that the constitution & codeOfLaw exists
    require(constitutionRegistry.exist(constitutionId));
    require(codeOfLawRegistry.exist(codeOfLawId));

    nationId = allNations.length++;

    allNations[nationId].at = at;
    allNations[nationId].name = name;
    allNations[nationId].timestamp = now;
    allNations[nationId].constitution = constitutionId;
    allNations[nationId].codeOfLaw = codeOfLawId;

    NewNation(nationId, at, name, msg.sender);
  }

  function vote(uint nationId, bool voteInSupport) returns (uint voteId) {
    // Check if nation exist
    require(allNations[nationId].at != address(0x0));

    // Check if already voted
    require(!allNations[nationId].didVote[msg.sender]);

    allNations[nationId].didVote[msg.sender] = true;

    voteId = allNations[nationId].allVotes.length++;
    allNations[nationId].allVotes[voteId] = Vote({voter: msg.sender, inSupport: voteInSupport, timestamp: now});
    allNations[nationId].numVotes++;

    NewVote(nationId, msg.sender, voteInSupport, voteId);
  }

  function getVote(uint nationId, uint voteId) constant returns (address voter, bool inSupport, uint timestamp) {
    voter = allNations[nationId].allVotes[voteId].voter;
    inSupport = allNations[nationId].allVotes[voteId].inSupport;
    timestamp = allNations[nationId].allVotes[voteId].timestamp;
  }
}
