pragma solidity ^0.4.4;

contract CitizenRegistry {
	uint public nbUsers;
        address[] public AllUsers;

	mapping(address => User) public users;

	struct User {
		address addr;

		bool hasApplication;
		uint applicationDate;

		bool isCitizen;
		uint citizenSince;
	}

	event UserChanged(address user);

	function applyForCitizenship() returns (uint ApplicationID);
	function cancelApplication(uint id);
	function acceptApplication(uint id);

	function cancelCitizenship(uint id);
}
