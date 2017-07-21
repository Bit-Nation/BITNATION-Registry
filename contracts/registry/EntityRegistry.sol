pragma solidity ^0.4.13;

contract EntityRegistry {
  mapping (address => Entity) public allEntities;

  // Required to get a list of all entities
  address[] public allEntitiesAddr;
  uint public numEntities;

  struct Entity {
      string panthalassaId;

      uint timestamp;

      Vote[] allVotes;
      uint numVotes;
      mapping (address => bool) didVote;
  }

  struct Vote {
      address voter;
      bool inSupport;

      uint timestamp;
  }

  event NewEntity(address entityAddr, string panthalassaId);
  event NewVote(address entityAddr, address voter, bool inSupport, uint voteId);

  function register(string panthalassaId) {
    require(sha3(panthalassaId) != sha3(""));
    require(allEntities[msg.sender].timestamp == 0);

    allEntities[msg.sender].panthalassaId = panthalassaId;
    allEntities[msg.sender].timestamp = now;

    allEntitiesAddr.push(msg.sender);
    numEntities++;

    NewEntity(msg.sender, panthalassaId);
  }

  function vote(address entity, bool voteInSupport) returns (uint voteId) {
    require(allEntities[entity].timestamp != 0);
    require(!allEntities[entity].didVote[msg.sender]);

    allEntities[entity].didVote[msg.sender] = true;

    voteId = allEntities[entity].allVotes.length++;

    allEntities[entity].allVotes[voteId] = Vote({voter: msg.sender, inSupport: voteInSupport, timestamp: now});

    NewVote(entity, msg.sender, voteInSupport, voteId);
  }

  function getVote(address entity, uint voteId) constant returns (address voter, bool inSupport, uint timestamp) {
    voter = allEntities[entity].allVotes[voteId].voter;
    inSupport = allEntities[entity].allVotes[voteId].inSupport;
    timestamp = allEntities[entity].allVotes[voteId].timestamp;
  }
}
