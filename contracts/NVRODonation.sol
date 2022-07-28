// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NVRODonation is Ownable {
	using SafeMath for uint256;
	using Address for address;
	bool private _locked = true;
	IERC20 private _tokenContract;
	address private _donationAddress;

	event SendDonation(
		address from,
		uint256 amount
	);

	function setContract(IERC20 addr) public onlyOwner(){
		_tokenContract = addr;
	}

	function setDonationAddress(address addr) public onlyOwner(){
		_donationAddress = addr;
	}

	function donate(uint256 amount) public {
		uint256 balance = _tokenContract.balanceOf(_msgSender());
		require(balance >= amount, 'your balance is not enough');
		_tokenContract.transferFrom(_msgSender(),_donationAddress, amount);
		emit SendDonation(_msgSender(), amount);
	}
}