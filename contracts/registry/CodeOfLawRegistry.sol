pragma solidity ^0.4.13;

contract CodeOfLawRegistry {
  uint public numCodesOfLaw;
  CodeOfLaw[] public allCodesOfLaw;

  struct CodeOfLaw {
    uint parent; // In case of a fork

    address maintainer;
    mapping (address => bool) isEditor;

    string name;
    uint timestamp;

    Law[] allLaws;
    uint numLaws;

    Vote[] allVotes;
    uint numVotes;
    mapping (address => bool) didVote;
  }

  struct Law {
    string summary;
    string reference; // url to a document further explaining the Law (should be on IPFS)
    bool isValid;

    uint createdAt;
    uint repealedAt;
  }

  struct Vote {
    address voter;
    bool inSupport;

    uint timestamp;
  }

  modifier onlyEditor(uint id) {
    require(allCodesOfLaw[id].isEditor[msg.sender]);
    _;
  }

  modifier onlyMaintainer(uint id) {
    require(allCodesOfLaw[id].maintainer == msg.sender);
    _;
  }

  event CodeOfLawCreated(uint CodeOfLawId, address maintainer, string name, uint parentId);

  event MaintainershipTransfered(uint CodeOfLawId, address oldMaintainer, address newMaintainer);
  event EditorshipChanged(uint CodeOfLawId, address editor, bool canEdit);

  event LawChanged(uint CodeOfLawId, address editor, uint LawId, bool isValid);

  event NewVote(uint CodeOfLawId, address voter, bool inSupport, uint voteId);

  function createCodeOfLaw(string CodeOfLawName) returns (uint CodeOfLawId) {
    CodeOfLawId = allCodesOfLaw.length++;

    allCodesOfLaw[CodeOfLawId].maintainer = msg.sender;
    allCodesOfLaw[CodeOfLawId].name = CodeOfLawName;
    allCodesOfLaw[CodeOfLawId].timestamp = now;
    allCodesOfLaw[CodeOfLawId].isEditor[msg.sender] = true;

    numCodesOfLaw++;

    CodeOfLawCreated(CodeOfLawId, msg.sender, CodeOfLawName, 0);
  }

  // That function is a bit redundant with the one above
  function forkCodeOfLaw(string newName, uint parentId) returns (uint CodeOfLawId) {
    CodeOfLawId = allCodesOfLaw.length++;

    allCodesOfLaw[CodeOfLawId].maintainer = msg.sender;
    allCodesOfLaw[CodeOfLawId].name = newName;
    allCodesOfLaw[CodeOfLawId].timestamp = now;
    allCodesOfLaw[CodeOfLawId].parent = parentId;
    allCodesOfLaw[CodeOfLawId].isEditor[msg.sender] = true;

    numCodesOfLaw++;

    CodeOfLawCreated(CodeOfLawId, msg.sender, newName, parentId);
  }

  function changeMaintainership(uint CodeOfLaw, address newMaintainer) onlyMaintainer(CodeOfLaw) {
    // Avoid some subefficient code
    require(allCodesOfLaw[CodeOfLaw].maintainer != newMaintainer);

    // Do not transfer to 0x0
    require(newMaintainer != address(0x0));

    allCodesOfLaw[CodeOfLaw].maintainer = newMaintainer;
    // The old maintainer stay an editor
    allCodesOfLaw[CodeOfLaw].isEditor[newMaintainer] = true;

    MaintainershipTransfered(CodeOfLaw, msg.sender, newMaintainer);
  }

  function changeEditorship(uint CodeOfLaw, address editor, bool canEdit) onlyMaintainer(CodeOfLaw) {
    allCodesOfLaw[CodeOfLaw].isEditor[editor] = canEdit;

    EditorshipChanged(CodeOfLaw, editor, canEdit);
  }

  function addLaw(uint CodeOfLaw, string LawSummary, string LawReference) onlyEditor(CodeOfLaw) returns (uint LawId) {
    LawId = allCodesOfLaw[CodeOfLaw].allLaws.length++;

    allCodesOfLaw[CodeOfLaw].allLaws[LawId] = Law({summary: LawSummary, reference: LawReference, createdAt: now, isValid: true, repealedAt: 0});
    allCodesOfLaw[CodeOfLaw].numLaws++;

    LawChanged(CodeOfLaw, msg.sender, LawId, true);
  }

  function repealLaw(uint CodeOfLaw, uint LawId) onlyEditor(CodeOfLaw) {
    require(allCodesOfLaw[CodeOfLaw].allLaws[LawId].isValid);

    allCodesOfLaw[CodeOfLaw].allLaws[LawId].repealedAt = now;
    allCodesOfLaw[CodeOfLaw].allLaws[LawId].isValid = false;

    LawChanged(CodeOfLaw, msg.sender, LawId, false);
  }

  function getLaw(uint CodeOfLaw, uint LawId) constant returns (string summary, string reference, bool isValid, uint createdAt, uint repealedAt) {
    summary = allCodesOfLaw[CodeOfLaw].allLaws[LawId].summary;
    reference = allCodesOfLaw[CodeOfLaw].allLaws[LawId].reference;
    isValid = allCodesOfLaw[CodeOfLaw].allLaws[LawId].isValid;
    createdAt = allCodesOfLaw[CodeOfLaw].allLaws[LawId].createdAt;
    repealedAt = allCodesOfLaw[CodeOfLaw].allLaws[LawId].repealedAt;
  }

  function vote(uint CodeOfLaw, bool voteInSupport) returns (uint voteId) {
    require(allCodesOfLaw[CodeOfLaw].maintainer != address(0x0));
    require(!allCodesOfLaw[CodeOfLaw].didVote[msg.sender]);

    allCodesOfLaw[CodeOfLaw].didVote[msg.sender] = true;

    voteId = allCodesOfLaw[CodeOfLaw].allVotes.length++;

    allCodesOfLaw[CodeOfLaw].allVotes[voteId] = Vote({voter: msg.sender, inSupport: voteInSupport, timestamp: now});
    allCodesOfLaw[CodeOfLaw].numVotes++;

    NewVote(CodeOfLaw, msg.sender, voteInSupport, voteId);
  }

  function getVote(uint CodeOfLaw, uint voteId) constant returns (address voter, bool inSupport, uint timestamp) {
    voter = allCodesOfLaw[CodeOfLaw].allVotes[voteId].voter;
    inSupport = allCodesOfLaw[CodeOfLaw].allVotes[voteId].inSupport;
    timestamp = allCodesOfLaw[CodeOfLaw].allVotes[voteId].timestamp;
  }

    // Used by NationFactory
  function exist(uint CodeOfLaw) returns (bool) {
    return allCodesOfLaw[CodeOfLaw].maintainer != address(0x0);
  }
}
