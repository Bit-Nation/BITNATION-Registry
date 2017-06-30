pragma solidity ^0.4.4;

import "zeppelin/contracts/ownership/Ownable.sol";

import "./dbvn/CitizenRegistry.sol";
import "./dbvn/Metadata.sol";
import "./dbvn/ServicesRegistry.sol";
import "./dbvn/Constitution.sol";
import "./dbvn/DecisionPool.sol";
import "./dbvn/CodeOfLaw.sol";

contract Nation is Ownable, CitizenRegistry, Metadata, ServicesRegistry, Constitution, DecisionPool, CodeOfLaw {
	address public registry;
	address public backup;

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

