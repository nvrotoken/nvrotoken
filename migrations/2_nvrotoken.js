const NVROToken = artifacts.require("NVROToken");

module.exports = function(deployer) {
  //0xac97898e00dd1b0A32CbaC6d7CB4FC6b1FD43ecb local uniswapv2router2
  //testnet
  //https://testnet.bscscan.com/address/0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
   deployer.deploy(NVROToken,"NVRO Token","NVRO", "0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3");
   //deployer.deploy(NVROToken);
};
