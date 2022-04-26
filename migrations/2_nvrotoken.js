const NVROToken = artifacts.require("NVROToken");

module.exports = function(deployer) {
  deployer.deploy(NVROToken);
};
