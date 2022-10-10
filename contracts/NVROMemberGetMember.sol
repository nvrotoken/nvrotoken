// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//the owner must be the private sale wallet address!
contract NVROMemberGetMember is Ownable {
	using SafeMath for uint256;
	using Address for address; 
	
	mapping (address => uint256) private _affiliate;
	mapping (address => address) private _referer;
	mapping (address => uint256) private _balance;

	IERC20 private _tokenContract;
	IERC20 private _presaleContract;
	address private PRESALE_ADDR;
	uint256 private TOKEN_PRICE = 1; //this is 0.001 BUSD / NVROToken
	uint256 private DECIMALS = 10**3;
	uint256 private UNLOCK_TS = 1670605200;


	event PreSalePurchase(
        address to,
        uint256 amount,
		address referral
    );
	event Redeemed(
        address to,
        uint256 amount
    );
	constructor(IERC20 busd, IERC20 nvro) {
        setContract(busd);
		setPresaleContract(nvro);
		setTokenPrice(1);
    }
	function setContract(IERC20 addr) public onlyOwner(){
		_tokenContract = addr;
	}
	function setPresaleContract(IERC20 addr) public onlyOwner(){
		_presaleContract = addr;
	}
	function setPresaleAddress(address presale) public onlyOwner(){
		PRESALE_ADDR = presale;
	}
	function getPresaleAddress() public view returns(address){
		return PRESALE_ADDR;
	}
	function setupComission(address referral, uint256 amount) private returns (uint256) {
		uint256 _c = 0;
		
		if(referral == address(0)) return 0;

		_referer[_msgSender()] = referral;

		if(_affiliate[referral] > 0){
			_affiliate[referral].add(1);
		}else{
			_affiliate[referral] = 1;
		}
		
		//if referral counts between 1 and 5, the referral recieves 5% of BUSD paid by sender.
		if(_affiliate[referral] > 0 && _affiliate[referral] < 6) {
			_c = amount.mul(5).div(100);
		}
		//if referral counts between 5 and 20, the referral recieves 10% of BUSD paid by sender.
		if(_affiliate[referral] > 5 && _affiliate[referral] < 21) {
			_c = amount.mul(10).div(100);
		}
		//if referral counts more than 20, the referral recieves 15% of BUSD paid by sender.
		if(_affiliate[referral] > 20) {
			_c = amount.mul(15).div(100);
		}

		return _c;
	}

	function purchase(uint256 amount, address referral) public returns (bool) {
		require(_msgSender() != owner(), "sorry owner cannot execute these function");
		require(amount > 0, 'the transfer amount must > 0');
		require(_tokenContract.balanceOf(_msgSender()) > 0, 'insufficient BUSD Balance');
		
		uint256 _comission = 0;
		uint256 _tAmount = 0;
		uint256 _token = 0;

		//check for comission if referral is specified
		_comission = setupComission(referral, amount);
		//adjust the transfer amount to presale account
		_tAmount = _comission > 0 ? amount.sub( _comission ) : amount;
		_tokenContract.transfer(PRESALE_ADDR, _tAmount);

		if(_comission > 0) _tokenContract.transfer(referral, _comission);
		

		//now we add the token purchased based on it's price rate (TOKEN_PRICE).
		//the token is recieved in full, unaffected by the commission.
		_token = amount.mul(TOKEN_PRICE);
		
		//set how many NVRO token the sender can claim after the purchase.
		if(_balance[_msgSender()] > 0){
			_balance[_msgSender()].add(_token);
		}else{
			_balance[_msgSender()] = _token;
		}

		emit PreSalePurchase(PRESALE_ADDR, amount, referral);

		return true;

	}

	function getReferrer(address account) public view returns (address) {
		return _referer[account];
	}

	function getTotalReferral(address account) public view returns (uint256) {
		return _affiliate[account];
	}

	function setTokenPrice(uint256 price) public onlyOwner(){
		TOKEN_PRICE = price.div(DECIMALS);
	}

	function getTokenPrice() public view returns (uint256){
		return TOKEN_PRICE;
	}

	function balanceOf(address account) public view returns (uint256) {
		return _balance[account];
	}

	function setUnlockTime(uint256 ts) public onlyOwner() {
		UNLOCK_TS = ts;
	} 
	function getUnlockTime() public view returns(uint256){
		return UNLOCK_TS;
	}
	function isUnlocked() public view returns(bool) {
		if(getUnlockTime() < block.timestamp) return true;
		return false;
	}
	function redeem(address to) public onlyOwner() {
		//make sure that the recipient indeed have token balance from presale
		require(_balance[to] > 0, "no NVRO token available for you.");
		//make sure that the locking time is already expired.
		require(isUnlocked(), "Sorry the token is still locked!");
		uint256 _amount = _balance[to];
		_presaleContract.transfer(to, _amount);
		_balance[to] = 0;
		emit Redeemed(to, _amount);
	 }
}