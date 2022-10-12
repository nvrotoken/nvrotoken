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
	uint256 private TOKEN_PRICE = 1000; //these means 1BUSD can purchase 1000 NVRO
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
	event TokenAdded(
		address to,
		uint256 amount
	);
	event Commission(
		address to,
		uint256 amount
	);
	constructor(IERC20 busd, IERC20 nvro) {
        setContract(busd);
		setPresaleContract(nvro);
		setTokenPrice(1000);
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
		if(referral == _msgSender()) return 0; //prevent the buyer from cheating for free cashback

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
		_tokenContract.transferFrom(_msgSender(),PRESALE_ADDR, _tAmount);

		if(_comission > 0) _tokenContract.transferFrom(_msgSender(),referral, _comission);
		

		//now we add the token purchased based on it's price rate (TOKEN_PRICE).
		//the token is recieved in full, unaffected by the commission.
		_token = amount.mul(TOKEN_PRICE);
		
		//set how many NVRO token the sender can claim after the purchase.
		addToken(_token);

		emit PreSalePurchase(PRESALE_ADDR, amount, referral);
		emit TokenAdded(_msgSender(), _token);
		if(_comission > 0) emit Commission(referral, _comission);
		return true;

	}
	function addToken(uint256 _token) private {
		uint256 _amount = _balance[_msgSender()];
		_balance[_msgSender()] = _amount.add(_token);
	}

	function getReferrer(address account) public view returns (address) {
		return _referer[account];
	}

	function getTotalReferral(address account) public view returns (uint256) {
		return _affiliate[account];
	}

	function setTokenPrice(uint256 price) public onlyOwner(){
		require(price > 0,"price must > 0");
		TOKEN_PRICE = price;
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
		_presaleContract.transferFrom(owner(), to, _amount);
		_balance[to] = 0;
		emit Redeemed(to, _amount);
	 }
}