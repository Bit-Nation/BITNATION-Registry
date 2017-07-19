pragma solidity ^0.4.4;

contract EntityRegistry {
  mapping (address => Entity) public allEntities;

  struct Entity {
      string panthalassaId;

      uint timestamp;

      Vote[] allVotes;
      mapping (address => bool) didVote;
  }

  struct Vote {
      address voter;
      bool inSupport;

      uint timestamp;
  }

  event NewEntity(address entityAddr, string panthalassaId);
  event NewVote(address entity, address voter, bool inSupport, uint voteId);

  function register(string panthalassaId) {
    require(sha3(panthalassaId) != sha3(""));
    require(allEntities[msg.sender].timestamp == 0);

    Entity e = allEntities[msg.sender];
    e.panthalassaId = panthalassaId;
    e.timestamp = now;

    NewEntity(msg.sender, panthalassaId);
  }

  function vote(address entity, bool inSupport) returns (uint voteId) {
    require(allEntities[entity].timestamp != 0);
    require(!allEntities[entity].didVote[msg.sender]);

    allEntities[entity].didVote[msg.sender] = true;

    voteId = allEntities[entity].allVotes.length++;

    Vote v = allEntities[entity].allVotes[voteId];
    v.voter = msg.sender;
    v.inSupport = inSupport;
    v.timestamp = now;

    NewVote(entity, msg.sender, inSupport, voteId);
  }

  function getVote(address entity, uint voteId) constant returns (address voter, bool inSupport, uint timestamp) {
    Vote v = allEntities[entity].allVotes[voteId];
    voter = v.voter;
    inSupport = v.inSupport;
    timestamp = v.timestamp;
  }
}
