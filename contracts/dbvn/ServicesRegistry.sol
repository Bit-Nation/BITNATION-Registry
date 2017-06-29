pragma solidity ^0.4.4;

contract ServicesRegistry {
	uint public nbServices;
	Service[] public allServices;

	struct Service {
		string name;
		string description;

		address addr;
		string abi;
	}

	function ServicesRegistry() {
		allServices.push(Service("", "", 0x0, ""));
	}

	function addService(string _name, string _description, address _addr, string _abi);

	function removeService(uint id);
}
