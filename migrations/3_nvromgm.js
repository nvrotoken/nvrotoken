const NVROMemberGetMember = artifacts.require("NVROMemberGetMember");

module.exports = function(deployer) {
  //0xac97898e00dd1b0A32CbaC6d7CB4FC6b1FD43ecb local uniswapv2router2
  //testnet
  //https://testnet.bscscan.com/address/0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
   deployer.deploy(NVROMemberGetMember,'0x4c8f192B706CFf4fC9b24Caab20553B41634Fcd4','0xd1A0C2a1881187dDFffa1337B47eD88E0b148FA8');
   
};
