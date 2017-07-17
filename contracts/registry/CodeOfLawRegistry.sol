pragma solidity ^0.4.4;

contract CodeOfLawRegistry {
  mapping (bytes32 => CodeOfLaw) public allCodesOfLaw;

  struct CodeOfLaw {
    bytes32 parent; // In case of a fork

    address maintainer;
    mapping (address => bool) isEditor;

    string name;
    uint timestamp;

    Law[] allLaws;

    Vote[] allVotes;
    mapping (address => bool) didVote;
  }

  struct Law {
    string summary;
    string reference; // url to a document further explaining the law (should be on IPFS)
    bool isValid;

    uint createdAt;
    uint repealedAt;
  }

  struct Vote {
    address voter;
    bool inSupport;

    uint timestamp;
  }

  modifier onlyEditor(bytes32 hash) {
    require(allCodesOfLaw[hash].isEditor[msg.sender]);
    _;
  }

  modifier onlyMaintainer(bytes32 hash) {
    require(allCodesOfLaw[hash].maintainer == msg.sender);
    _;
  }

  event CodeOfLawCreated(bytes32 codeOfLaw, address maintainer, string name, bytes32 parent);

  event MaintainershipTransfered(bytes32 codeOfLaw, address oldMaintainer, address newMaintainer);
  event EditorshipChanged(bytes32 codeOfLaw, address editor, bool canEdit);

  event LawChanged(bytes32 codeOfLaw, address editor, uint lawId, bool isValid);

  event NewVote(bytes32 codeOfLaw, address voter, bool inSupport, uint voteId);

  function createCodeOfLaw(string name) returns (bytes32 hash) {
    hash = sha3(msg.sender, name);

    // Check if it already exist
    require(allCodesOfLaw[hash].maintainer == address(0x0));

    // Create the codeOfLaw
    CodeOfLaw c = allCodesOfLaw[hash];
    c.maintainer = msg.sender;
    c.isEditor[msg.sender] = true;
    c.name = name;
    c.timestamp = now;

    CodeOfLawCreated(hash, msg.sender, name, 0x0);
  }

  // That function is a bit redundant with the one above
  function forkCodeOfLaw(string newName, bytes32 parent) returns (bytes32 hash) {
    // Parent must exist
    require(allCodesOfLaw[parent].maintainer != address(0x0));

    // Check that the new one doesn't exist
    hash = sha3(msg.sender, newName);
    require(allCodesOfLaw[hash].maintainer == address(0x0));

    // Make the new one
    CodeOfLaw c = allCodesOfLaw[hash];
    c.maintainer = msg.sender;
    c.isEditor[msg.sender] = true;
    c.name = newName;
    c.timestamp = now;
    c.parent = parent;

    // We could try to copy all the laws from parent to the new codeOfLaw
    // But it would consume so much gas

    CodeOfLawCreated(hash, msg.sender, newName, parent);
  }

  function changeMaintainership(bytes32 codeOfLaw, address newMaintainer) onlyMaintainer(codeOfLaw) {
    // Avoid some subefficient code
    require(allCodesOfLaw[codeOfLaw].maintainer != newMaintainer);

    // Do not transfer to 0x0
    require(newMaintainer != address(0x0));

    allCodesOfLaw[codeOfLaw].maintainer = newMaintainer;
    // The old maintainer stay an editor
    allCodesOfLaw[codeOfLaw].isEditor[newMaintainer] = true;

    MaintainershipTransfered(codeOfLaw, msg.sender, newMaintainer);
  }

  function changeEditorship(bytes32 codeOfLaw, address editor, bool canEdit) onlyMaintainer(codeOfLaw) {
    allCodesOfLaw[codeOfLaw].isEditor[editor] = canEdit;

    EditorshipChanged(codeOfLaw, editor, canEdit);
  }

  function addLaw(bytes32 codeOfLaw, string summary, string reference) onlyEditor(codeOfLaw) returns (uint lawId) {
    lawId = allCodesOfLaw[codeOfLaw].allLaws.length++;

    Law l = allCodesOfLaw[codeOfLaw].allLaws[lawId];
    l.summary = summary;
    l.reference = reference;
    l.createdAt = now;
    l.isValid = true;

    LawChanged(codeOfLaw, msg.sender, lawId, true);
  }

  function repealLaw(bytes32 codeOfLaw, uint lawId) onlyEditor(codeOfLaw) {
    Law l = allCodesOfLaw[codeOfLaw].allLaws[lawId];

    require(l.isValid);

    l.repealedAt = now;
    l.isValid = false;

    LawChanged(codeOfLaw, msg.sender, lawId, false);
  }

  function getLaw(bytes32 codeOfLaw, uint lawId) constant returns (string summary, string reference, bool isValid, uint createdAt, uint repealedAt) {
    Law l = allCodesOfLaw[codeOfLaw].allLaws[lawId];
    summary = l.summary;
    reference = l.reference;
    isValid = l.isValid;
    createdAt = l.createdAt;
    repealedAt = l.repealedAt;
  }

  function vote(bytes32 codeOfLaw, bool inSupport) returns (uint voteId) {
    require(allCodesOfLaw[codeOfLaw].maintainer != address(0x0));
    require(!allCodesOfLaw[codeOfLaw].didVote[msg.sender]);

    allCodesOfLaw[codeOfLaw].didVote[msg.sender] = true;

    voteId = allCodesOfLaw[codeOfLaw].allVotes.length++;

    Vote v = allCodesOfLaw[codeOfLaw].allVotes[voteId];
    v.voter = msg.sender;
    v.inSupport = inSupport;
    v.timestamp = now;

    NewVote(codeOfLaw, msg.sender, inSupport, voteId);
  }

  function getVote(bytes32 codeOfLaw, uint voteId) constant returns (address voter, bool inSupport, uint timestamp) {
    Vote v = allCodesOfLaw[codeOfLaw].allVotes[voteId];
    voter = v.voter;
    inSupport = v.inSupport;
    timestamp = v.timestamp;
  }
}
