pragma solidity ^0.4.4;

contract ConstitutionRegistry {
  mapping (bytes32 => Constitution) public allConstitutions;

  struct Constitution {
    bytes32 parent; // In case of a fork

    address maintainer;
    mapping (address => bool) isEditor;

    string name;
    uint timestamp;

    Article[] allArticles;

    Vote[] allVotes;
    mapping (address => bool) didVote;
  }

  struct Article {
    string summary;
    string reference; // url to a document further explaining the article (should be on IPFS)
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
    require(allConstitutions[hash].isEditor[msg.sender]);
    _;
  }

  modifier onlyMaintainer(bytes32 hash) {
    require(allConstitutions[hash].maintainer == msg.sender);
    _;
  }

  event ConstitutionCreated(bytes32 constitution, address maintainer, string name, bytes32 parent);

  event MaintainershipTransfered(bytes32 constitution, address oldMaintainer, address newMaintainer);
  event EditorshipChanged(bytes32 constitution, address editor, bool canEdit);

  event ArticleChanged(bytes32 constitution, address editor, uint articleId, bool isValid);

  event NewVote(bytes32 constitution, address voter, bool inSupport, uint voteId);

  function createConstitution(string name) returns (bytes32 hash) {
    hash = sha3(msg.sender, name);

    // Check if it already exist
    require(allConstitutions[hash].maintainer == address(0x0));

    // Create the constitution
    Constitution c = allConstitutions[hash];
    c.maintainer = msg.sender;
    c.isEditor[msg.sender] = true;
    c.name = name;
    c.timestamp = now;

    ConstitutionCreated(hash, msg.sender, name, 0x0);
  }

  // That function is a bit redundant with the one above
  function forkConstitution(string newName, bytes32 parent) returns (bytes32 hash) {
    // Parent must exist
    require(allConstitutions[parent].maintainer != address(0x0));

    // Check that the new one doesn't exist
    hash = sha3(msg.sender, newName);
    require(allConstitutions[hash].maintainer == address(0x0));

    // Make the new one
    Constitution c = allConstitutions[hash];
    c.maintainer = msg.sender;
    c.isEditor[msg.sender] = true;
    c.name = newName;
    c.timestamp = now;
    c.parent = parent;

    // We could try to copy all the articles from parent to the new constitution
    // But it would consume so much gas

    ConstitutionCreated(hash, msg.sender, newName, parent);
  }

  function changeMaintainership(bytes32 constitution, address newMaintainer) onlyMaintainer(constitution) {
    // Avoid some subefficient code
    require(allConstitutions[constitution].maintainer != newMaintainer);

    // Do not transfer to 0x0
    require(newMaintainer != address(0x0));

    allConstitutions[constitution].maintainer = newMaintainer;
    // The old maintainer stay an editor
    allConstitutions[constitution].isEditor[newMaintainer] = true;

    MaintainershipTransfered(constitution, msg.sender, newMaintainer);
  }

  function changeEditorship(bytes32 constitution, address editor, bool canEdit) onlyMaintainer(constitution) {
    allConstitutions[constitution].isEditor[editor] = canEdit;

    EditorshipChanged(constitution, editor, canEdit);
  }

  function addArticle(bytes32 constitution, string summary, string reference) onlyEditor(constitution) returns (uint articleId) {
    articleId = allConstitutions[constitution].allArticles.length++;

    Article a = allConstitutions[constitution].allArticles[articleId];
    a.summary = summary;
    a.reference = reference;
    a.createdAt = now;
    a.isValid = true;

    ArticleChanged(constitution, msg.sender, articleId, true);
  }

  function repealArticle(bytes32 constitution, uint articleId) onlyEditor(constitution) {
    Article a = allConstitutions[constitution].allArticles[articleId];

    require(a.isValid);

    a.repealedAt = now;
    a.isValid = false;

    ArticleChanged(constitution, msg.sender, articleId, false);
  }

  function getArticle(bytes32 constitution, uint articleId) constant returns (string summary, string reference, bool isValid, uint createdAt, uint repealedAt) {
    Article a = allConstitutions[constitution].allArticles[articleId];
    summary = a.summary;
    reference = a.reference;
    isValid = a.isValid;
    createdAt = a.createdAt;
    repealedAt = a.repealedAt;
  }

  function vote(bytes32 constitution, bool inSupport) returns (uint voteId) {
    require(allConstitutions[constitution].maintainer != address(0x0));
    require(!allConstitutions[constitution].didVote[msg.sender]);

    allConstitutions[constitution].didVote[msg.sender] = true;

    voteId = allConstitutions[constitution].allVotes.length++;

    Vote v = allConstitutions[constitution].allVotes[voteId];
    v.voter = msg.sender;
    v.inSupport = inSupport;
    v.timestamp = now;

    NewVote(constitution, msg.sender, inSupport, voteId);
  }

  function getVote(bytes32 constitution, uint voteId) constant returns (address voter, bool inSupport, uint timestamp) {
    Vote v = allConstitutions[constitution].allVotes[voteId];
    voter = v.voter;
    inSupport = v.inSupport;
    timestamp = v.timestamp;
  }
}
