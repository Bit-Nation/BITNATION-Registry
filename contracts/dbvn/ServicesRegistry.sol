pragma solidity ^0.4.4;

contract ServicesRegistry {
	uint public nbServices;
	Service[] public allServices;

	struct Service {
		string name;
		string description;

		address addr;
		string abi;

		bool enabled;

		uint addedOn;
	}

	event ServiceChanged(uint id);

	function addService(string _name, string _description, address _addr, string _abi) returns (uint ServiceID);
	function removeService(uint id);
}
