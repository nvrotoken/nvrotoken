// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NVROWhitelist is Ownable {
	using SafeMath for uint256;
	using Address for address;
	bool private _locked = true;
	uint256 private _tokenAmount = 10000;
	mapping (address => bool) private _recievers;
	mapping (address => bool) private _redeemed;
	IERC20 private _tokenContract;

	event TokenDropped(
        address account,
        uint256 amount
    );

    event TokenClaimed(
        address account,
        uint256 amount
    );

    event Whitelisted(
    	address account
    );

    event RemovedFromWhitelist(
    	address account
    );

	function setContract(IERC20 addr) public onlyOwner(){
		_tokenContract = addr;
	}
	function addToWhitelist(address account) public onlyOwner(){
		_recievers[account] = true;
		emit Whitelisted(account);
	}
	function removeFromWhitelist(address account) public onlyOwner(){
		_recievers[account] = false;
		emit RemovedFromWhitelist(account);
	}
	function setClaimable(bool flag) public onlyOwner(){
		_locked = flag;
	}
	function isLocked() private view onlyOwner() returns (bool) {
		return _locked;
	}
	function isWhitelisted(address account) public view returns (bool) {
		require(_recievers[account] == true, 'account is not in the whitelist');
		return _recievers[account];
	}
	function isRedeemed(address account) public view returns (bool) {
		require(_redeemed[account] == true, 'account is not redeemed yet');
		return _redeemed[account];
	}
	//release token
	function release(address account) public  onlyOwner() {
		require(!isLocked(),'cannot release yet');
		require(_redeemed[account] != true , 'account already redeemed'); 
		_redeemed[account] = true;
		_tokenContract.transferFrom(owner(), account, _tokenAmount);
		emit TokenDropped(account, _tokenAmount);
    }
    //claim token
    function claim() public  onlyOwner() {
		require(!isLocked(),'cannot release yet');
		require(_redeemed[_msgSender()] != true , 'account already redeemed'); 
		_redeemed[_msgSender()] = true;
		
		_tokenContract.transferFrom(owner(), _msgSender(), _tokenAmount);
		emit TokenClaimed(_msgSender(), _tokenAmount);
    }
}