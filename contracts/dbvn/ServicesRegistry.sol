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

	function ServicesRegistry() {
		allServices.push(Service("", "", 0x0, "", false, now));
	}

	function addService(string _name, string _description, address _addr, string _abi) return (uint ServiceID);
	function removeService(uint id);
}
