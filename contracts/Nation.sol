pragma solidity ^0.4.4;

import "zeppelin/contracts/ownership/Ownable.sol";

import "./dbvn/CitizenRegistry.sol";

contract Nation is Ownable, CitizenRegistry {
	address registry;

	modifier onlyRegistry {
		if (msg.sender != registry) {
			throw;
		}
		_;
	}

	function setRegistry(address _registry) onlyOwner {
		registry = _registry;
	}

	// This is sad...
	// Typically: move funds (if some) and self-destruct
	function onCollapse() onlyRegistry;
}

