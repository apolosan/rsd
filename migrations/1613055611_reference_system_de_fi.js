const ReferenceSystemDeFi = artifacts.require("ReferenceSystemDeFi");

module.exports = function (deployer, accounts) {
  deployer.deploy(ReferenceSystemDeFi, "Reference System for DeFi", "RSD", accounts[0]);
};