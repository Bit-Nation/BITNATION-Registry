pragma solidity ^0.4.13;

contract ConstitutionRegistry {
  uint public numConstitutions;
  Constitution[] public allConstitutions;

  struct Constitution {
    uint parent; // In case of a fork

    address maintainer;
    mapping (address => bool) isEditor;

    string name;
    uint timestamp;

    Article[] allArticles;
    uint numArticles;

    Vote[] allVotes;
    uint numVotes;
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

  modifier onlyEditor(uint id) {
    require(allConstitutions[id].isEditor[msg.sender]);
    _;
  }

  modifier onlyMaintainer(uint id) {
    require(allConstitutions[id].maintainer == msg.sender);
    _;
  }

  event ConstitutionCreated(uint constitutionId, address maintainer, string name, uint parentId);

  event MaintainershipTransfered(uint constitutionId, address oldMaintainer, address newMaintainer);
  event EditorshipChanged(uint constitutionId, address editor, bool canEdit);

  event ArticleChanged(uint constitutionId, address editor, uint articleId, bool isValid);

  event NewVote(uint constitutionId, address voter, bool inSupport, uint voteId);

  function createConstitution(string constitutionName) returns (uint constitutionId) {
    constitutionId = allConstitutions.length++;

    allConstitutions[constitutionId].maintainer = msg.sender;
    allConstitutions[constitutionId].name = constitutionName;
    allConstitutions[constitutionId].timestamp = now;
    allConstitutions[constitutionId].isEditor[msg.sender] = true;

    numConstitutions++;

    ConstitutionCreated(constitutionId, msg.sender, constitutionName, 0);
  }

  // That function is a bit redundant with the one above
  function forkConstitution(string newName, uint parentId) returns (uint constitutionId) {
    constitutionId = allConstitutions.length++;

    allConstitutions[constitutionId].maintainer = msg.sender;
    allConstitutions[constitutionId].name = newName;
    allConstitutions[constitutionId].timestamp = now;
    allConstitutions[constitutionId].parent = parentId;
    allConstitutions[constitutionId].isEditor[msg.sender] = true;

    numConstitutions++;

    ConstitutionCreated(constitutionId, msg.sender, newName, parentId);
  }

  function changeMaintainership(uint constitution, address newMaintainer) onlyMaintainer(constitution) {
    // Avoid some subefficient code
    require(allConstitutions[constitution].maintainer != newMaintainer);

    // Do not transfer to 0x0
    require(newMaintainer != address(0x0));

    allConstitutions[constitution].maintainer = newMaintainer;
    // The old maintainer stay an editor
    allConstitutions[constitution].isEditor[newMaintainer] = true;

    MaintainershipTransfered(constitution, msg.sender, newMaintainer);
  }

  function changeEditorship(uint constitution, address editor, bool canEdit) onlyMaintainer(constitution) {
    allConstitutions[constitution].isEditor[editor] = canEdit;

    EditorshipChanged(constitution, editor, canEdit);
  }

  function addArticle(uint constitution, string articleSummary, string articleReference) onlyEditor(constitution) returns (uint articleId) {
    articleId = allConstitutions[constitution].allArticles.length++;

    allConstitutions[constitution].allArticles[articleId] = Article({summary: articleSummary, reference: articleReference, createdAt: now, isValid: true, repealedAt: 0});
    allConstitutions[constitution].numArticles++;

    ArticleChanged(constitution, msg.sender, articleId, true);
  }

  function repealArticle(uint constitution, uint articleId) onlyEditor(constitution) {
    require(allConstitutions[constitution].allArticles[articleId].isValid);

    allConstitutions[constitution].allArticles[articleId].repealedAt = now;
    allConstitutions[constitution].allArticles[articleId].isValid = false;

    ArticleChanged(constitution, msg.sender, articleId, false);
  }

  function getArticle(uint constitution, uint articleId) constant returns (string summary, string reference, bool isValid, uint createdAt, uint repealedAt) {
    summary = allConstitutions[constitution].allArticles[articleId].summary;
    reference = allConstitutions[constitution].allArticles[articleId].reference;
    isValid = allConstitutions[constitution].allArticles[articleId].isValid;
    createdAt = allConstitutions[constitution].allArticles[articleId].createdAt;
    repealedAt = allConstitutions[constitution].allArticles[articleId].repealedAt;
  }

  function vote(uint constitution, bool voteInSupport) returns (uint voteId) {
    require(allConstitutions[constitution].maintainer != address(0x0));
    require(!allConstitutions[constitution].didVote[msg.sender]);

    allConstitutions[constitution].didVote[msg.sender] = true;

    voteId = allConstitutions[constitution].allVotes.length++;

    allConstitutions[constitution].allVotes[voteId] = Vote({voter: msg.sender, inSupport: voteInSupport, timestamp: now});
    allConstitutions[constitution].numVotes++;

    NewVote(constitution, msg.sender, voteInSupport, voteId);
  }

  function getVote(uint constitution, uint voteId) constant returns (address voter, bool inSupport, uint timestamp) {
    voter = allConstitutions[constitution].allVotes[voteId].voter;
    inSupport = allConstitutions[constitution].allVotes[voteId].inSupport;
    timestamp = allConstitutions[constitution].allVotes[voteId].timestamp;
  }

    // Used by NationFactory
  function exist(uint constitution) returns (bool) {
    return allConstitutions[constitution].maintainer != address(0x0);
  }
}
