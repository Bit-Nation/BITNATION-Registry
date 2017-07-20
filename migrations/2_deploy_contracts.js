var NationFactory = artifacts.require("./NationFactory.sol")
var BasicDBVN = artifacts.require("./BasicDBVN.sol")

var CodeOfLawRegistry = artifacts.require("./registry/CodeOfLawRegistry.sol")
var ConstitutionRegistry = artifacts.require("./registry/ConstitutionRegistry.sol")
var ContractRegistry = artifacts.require("./registry/ContractRegistry.sol")
var EntityRegistry = artifacts.require("./registry/EntityRegistry.sol")

var DBVN_minimumSharesToPassAVote = 50;
var DBVN_minutesForDebate = 60
var DBVN_initialShares = 100

module.exports = function(deployer) {
  let contractReg = {}
  return deployer.deploy(EntityRegistry)
    .then(() => deployer.deploy(ConstitutionRegistry))
    .then(() => deployer.deploy(ConstitutionRegistry))
    .then(() => deployer.deploy(CodeOfLawRegistry))
    .then(() => deployer.deploy(NationFactory, ConstitutionRegistry.address, CodeOfLawRegistry.address))
    .then(() => deployer.deploy(BasicDBVN, DBVN_minimumSharesToPassAVote, DBVN_minutesForDebate, DBVN_initialShares))
    .then(() => deployer.deploy(ContractRegistry))
    /*
    .then(() => ContractRegistry.deployed())
    .then(c => contractReg = c)
    .then(() => contractReg.claimContract(ContractRegistry.deployed().address))
    .then(() => contractReg.claimContract(CodeOfLawRegistry.deployed().address))
    .then(() => contractReg.claimContract(ConstitutionRegistry.deployed().address))
    .then(() => contractReg.claimContract(EntityRegistry.deployed().address))
    .then(() => contractReg.claimContract(NationFactory.deployed().address))
    .then(() => contractReg.claimContract(BasicDBVN.deployed().address))
    */
};
