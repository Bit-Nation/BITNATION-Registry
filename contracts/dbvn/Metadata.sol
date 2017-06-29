pragma solidity ^0.4.4;

import "zeppelin/contracts/ownership/Ownable.sol";

contract Metadata is Ownable {
	string public name;
	string public nation_type;

	string public website;

	function setWebsite(string url) onlyOwner {
		website = url;
	}
}
