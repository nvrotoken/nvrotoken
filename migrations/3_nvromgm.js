const NVROMemberGetMember = artifacts.require("NVROMemberGetMember");

module.exports = function(deployer) {
  //0xac97898e00dd1b0A32CbaC6d7CB4FC6b1FD43ecb local uniswapv2router2
  //testnet
  //https://testnet.bscscan.com/address/0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
   deployer.deploy(NVROMemberGetMember,"0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7","0x3753AC3fcA62930824F3A4D051A70B5cAE25B7Ce");
   
};
