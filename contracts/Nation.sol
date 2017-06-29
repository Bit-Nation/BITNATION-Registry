pragma solidity ^0.4.4;

import "zeppelin/contracts/ownership/Ownable.sol";

import "./dbvn/CitizenRegistry.sol";
import "./dbvn/Metadata.sol";
import "./dbvn/ServicesRegistry.sol";

contract Nation is Ownable, CitizenRegistry, Metadata, ServicesRegistry {
	address registry;
	address backup;

	modifier onlyRegistry {
		if (msg.sender != registry) {
			throw;
		}
		_;
	}

	function setBackup(address new_backup) onlyOwner {
		backup = new_backup;
	}

	function setRegistry(address _registry) onlyOwner {
		registry = _registry;
	}

	// This is sad...
	// Typically: move funds (if some) and self-destruct
	function onCollapse() onlyRegistry {
		selfdestruct(backup);
	}
}

