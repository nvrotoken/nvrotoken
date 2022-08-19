const NVROToken = artifacts.require("NVROToken");

module.exports = function(deployer) {
  //0xac97898e00dd1b0A32CbaC6d7CB4FC6b1FD43ecb local uniswapv2router2
   deployer.deploy(NVROToken,"Enviro Token","NVRO", "0xac97898e00dd1b0A32CbaC6d7CB4FC6b1FD43ecb");
   //deployer.deploy(NVROToken);
};
