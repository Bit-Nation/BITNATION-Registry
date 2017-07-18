pragma solidity ^0.4.4;

// This is a very basic DBVN implementation, a better one should be upcoming

// TODO: stake should be a token
// TODO: upgradeable

import "zeppelin/contracts/ownership/Ownable.sol";

contract BasicDBVN {
  uint waitingWindowInMinute;
  uint minimumStakeSum;
  uint minimumAgreement;

  mapping (address => Member) public allMembers;
  mapping (bytes32 => Proposal) public allProposals;
  mapping (address => string) public allApplications;

  struct Member {
    uint stake;

    bool isMember;
    uint memberSince;
    uint canceledAt;

    string name;

    // Permissions
    bool canEditPermissions;
    bool canEditStake;

    bool canEditSettings;

    bool canRefuseApplications;
    bool canAcceptApplications;

    bool canRevokeMembership;

    bool canAddProposals;
    bool canVoteOnProposals;
    bool canExecuteProposals;
  }

  struct Proposal {
    address submitter;

    address beneficiary;
    uint ethAmount;

    uint waitingWindow;

    bool executed;
    bool passed;
    bool proposalSucceedToExecute;

    int agreement;
    uint stakeSum;

    mapping (address => bool) didVote;
  }

  event NewApplication(address applier);
  event ApplicationCanceled(address applier);
  event ApplicationAccepted(address accepter, address applier);
  event ApplicationRefused(address refuser, address applier);

  event MembershipRevoked(address revoker, address member);

  event StakeChanged(address editor, address member, uint newStake);
  event PermissionsChanged(address editor, address member, bool canEditPermissions, bool canEditStake, bool canEditSettings, bool canRefuseApplications, bool canAcceptApplications, bool canRevokeMembership, bool canAddProposals, bool canVoteOnProposals, bool canExecuteProposals);

  event NewProposal(address by, bytes32 hash, bytes txCode);
  event NewVote(bytes32 proposalHash, address voter, bool inSupport, uint stake);
  event ProposalTallied(bytes32 proposalHash, bool passed, bool executionSuccess);

  event NewSettings(address editor, uint waitingWindowInMinute, uint minimumStakeSum, uint minimumAgreement);

  event Deposit(address sender, uint value);

  function MemberRegistry(uint myStake, string myName) {
    // Make owner a "superuser"
    Member m = allMembers[msg.sender];
    m.stake = myStake;
    m.name = myName;
    m.isMember = true;
    m.memberSince = now;

    m.canEditPermissions = true;
    m.canEditStake = true;
    m.canEditSettings = true;
    m.canRefuseApplications = true;
    m.canAcceptApplications = true;
    m.canRevokeMembership = true;
    m.canAddProposals = true;
    m.canVoteOnProposals = true;
    m.canExecuteProposals = true;
  }

  function applyForMembership(string myName) {
    require(sha3(allApplications[msg.sender]) == 0x0);

    allApplications[msg.sender] = myName;

    NewApplication(msg.sender);
  }

  function cancelApplication() {
    require(sha3(allApplications[msg.sender]) != 0x0);

    allApplications[msg.sender] = "";

    ApplicationCanceled(msg.sender);
  }

  function revokeMyMembership() {
    require(allMembers[msg.sender].isMember); // Check if member

    allMembers[msg.sender].isMember = false;
    allMembers[msg.sender].canceledAt = now;

    allMembers[msg.sender].stake = 0;
    allMembers[msg.sender].canEditPermissions = false;
    allMembers[msg.sender].canEditStake = false;
    allMembers[msg.sender].canEditSettings = false;
    allMembers[msg.sender].canRefuseApplications = false;
    allMembers[msg.sender].canAcceptApplications = false;
    allMembers[msg.sender].canRevokeMembership = false;
    allMembers[msg.sender].canAddProposals = false;
    allMembers[msg.sender].canVoteOnProposals = false;
    allMembers[msg.sender].canExecuteProposals = false;

    MembershipRevoked(msg.sender, msg.sender);
  }

  function refuseApplication(address applier) {
    require(allMembers[msg.sender].canRefuseApplications);
    require(sha3(allApplications[applier]) != 0x0);

    allApplications[applier] = "";

    ApplicationRefused(msg.sender, applier);
  }

  function acceptApplication(address applier) {
    require(allMembers[msg.sender].canAcceptApplications);
    require(sha3(allApplications[applier]) != 0x0);

    Member m = allMembers[applier];
    m.name = allApplications[applier];
    m.isMember = true;
    m.memberSince = now;

    ApplicationAccepted(msg.sender, applier);
  }

  function setStake(address member, uint newStake) {
    require(allMembers[msg.sender].canEditStake);
    require(allMembers[member].isMember);

    allMembers[member].stake = newStake;

    StakeChanged(msg.sender, member, newStake);
  }

  function setPermissions(address member, bool canEditPermissions, bool canEditStake, bool canEditSettings, bool canRefuseApplications, bool canAcceptApplications, bool canRevokeMembership, bool canAddProposals, bool canVoteOnProposals, bool canExecuteProposals) {
    require(allMembers[msg.sender].canEditPermissions);
    require(allMembers[member].isMember);

    allMembers[member].canEditPermissions = canEditPermissions;
    allMembers[member].canEditStake = canEditStake;
    allMembers[member].canEditSettings = canEditSettings;
    allMembers[member].canRefuseApplications = canRefuseApplications;
    allMembers[member].canAcceptApplications = canAcceptApplications;
    allMembers[member].canRevokeMembership = canRevokeMembership;
    allMembers[member].canAddProposals = canAddProposals;
    allMembers[member].canVoteOnProposals = canVoteOnProposals;
    allMembers[member].canExecuteProposals = canExecuteProposals;

    PermissionsChanged(msg.sender, member, canEditPermissions, canEditStake, canEditSettings, canRefuseApplications, canAcceptApplications, canRevokeMembership, canAddProposals, canVoteOnProposals, canExecuteProposals);
  }

  function revokeMembership(address member) {
    require(allMembers[msg.sender].canRevokeMembership);
    require(allMembers[member].isMember);

    allMembers[member].isMember = false;
    allMembers[member].canceledAt = now;

    allMembers[member].stake = 0;
    allMembers[member].canEditPermissions = false;
    allMembers[member].canEditStake = false;
    allMembers[member].canEditStake = false;
    allMembers[member].canRefuseApplications = false;
    allMembers[member].canAcceptApplications = false;
    allMembers[member].canRevokeMembership = false;
    allMembers[member].canAddProposals = false;
    allMembers[member].canVoteOnProposals = false;
    allMembers[member].canExecuteProposals = false;

    MembershipRevoked(msg.sender, member);
  }

  function submitProposal(address beneficiary, uint ethAmount, string description, bytes txCode) returns (bytes32 proposalHash) {
    require(allMembers[msg.sender].canAddProposals);

    proposalHash = sha3(beneficiary, ethAmount, txCode);

    assert(allProposals[proposalHash].waitingWindow != 0);

    Proposal p = allProposals[proposalHash];
    p.submitter = msg.sender;
    p.beneficiary = beneficiary;
    p.ethAmount = ethAmount * 1 ether;
    p.waitingWindow = now + (waitingWindowInMinute * 1 minutes);

    NewProposal(msg.sender, proposalHash, txCode);
  }

  function voteOnProposal(bytes32 proposalHash, bool inSupport) {
    require(allMembers[msg.sender].canVoteOnProposals);
    require(allMembers[msg.sender].stake > 0);
    require(allProposals[proposalHash].waitingWindow > now);
    require(!allProposals[proposalHash].didVote[msg.sender]);

    allProposals[proposalHash].didVote[msg.sender] = true;
    allProposals[proposalHash].stakeSum += allMembers[msg.sender].stake;

    if (inSupport) {
      allProposals[proposalHash].agreement += int(allMembers[msg.sender].stake);
    } else {
      allProposals[proposalHash].agreement -= int(allMembers[msg.sender].stake);
    }

    NewVote(proposalHash, msg.sender, inSupport, allMembers[msg.sender].stake);
  }

  function executeProposal(bytes32 proposalHash, bytes txCode) {
    require(allMembers[msg.sender].canExecuteProposals);
    require(allProposals[proposalHash].submitter != address(0x0));
    require(!allProposals[proposalHash].executed);
    require(allProposals[proposalHash].waitingWindow < now);
    require(allProposals[proposalHash].stakeSum >= minimumStakeSum);

    var testHash = sha3(allProposals[proposalHash].beneficiary, allProposals[proposalHash].ethAmount, txCode);
    assert(proposalHash == testHash);

    allProposals[proposalHash].executed = true;

    var pass = allProposals[proposalHash].agreement > int(minimumAgreement);
    var succeedToExecute = false;

    allProposals[proposalHash].passed = true;

    if (pass) {
      succeedToExecute = allProposals[proposalHash].beneficiary.call.value(allProposals[proposalHash].ethAmount)(txCode);
    }

    allProposals[proposalHash].proposalSucceedToExecute = succeedToExecute;

    ProposalTallied(proposalHash, pass, succeedToExecute);
  }

  function editSettings(uint newWaitingWindowInMinute, uint newMinimumStakeSum, uint newMinimumAgreement) {
    require(allMembers[msg.sender].canEditSettings);

    waitingWindowInMinute = newWaitingWindowInMinute;
    minimumStakeSum = newMinimumStakeSum;
    minimumAgreement = newMinimumAgreement;

    NewSettings(msg.sender, newWaitingWindowInMinute, newMinimumStakeSum, newMinimumAgreement);
  }

  function () payable {
    // Someone is depositing money, be a gentleman and buy him/her a beer
    if (msg.value > 0) {
      Deposit(msg.sender, msg.value);
    }
  }
}
