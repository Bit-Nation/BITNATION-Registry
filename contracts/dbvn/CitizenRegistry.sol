pragma solidity ^0.4.4;

contract CitizenRegistry {
	enum UserInfo { UnRegistered, HasApplication, IsCitizen }

	uint public nbApplications;
	address[] public pendingApplications;

        uint public nbCitizens;
        address[] public citizens;

	// Enum converted to uint for safety reasons (and clarity of code)
        mapping (address => uint) users;

	modifier mustBeRegistered(address addr) {
                if (UserInfo(users[addr]) == UserInfo.UnRegistered) {
			throw;
		}
                _;
        }

        modifier mustNotBeRegistered(address addr) {
                if (UserInfo(users[addr]) == UserInfo.UnRegistered) {
			throw;
		}
                _;
        }

	modifier mustHaveApplication(address addr) {
		if (UserInfo(users[addr]) != UserInfo.HasApplication) {
			throw;
		}
		_;
	}

	modifier mustHaveNoApplication(address addr) {
		if (UserInfo(users[addr]) == UserInfo.HasApplication) {
			throw;
		}
		_;
	}

	modifier mustBeCitizen(address addr) {
		if (UserInfo(users[addr]) != UserInfo.IsCitizen) {
			throw;
		}
		_;
	}

	modifier mustNotBeCitizen(address addr) {
		if (UserInfo(users[addr]) == UserInfo.IsCitizen) {
			throw;
		}
		_;
	}

	function applyForCitizenship() mustBeRegistered(msg.sender);
	function cancelApplication() mustHaveApplication(msg.sender);

	// A citizen must not have any application
	function cancelCitizenship() mustBeCitizen(msg.sender);
}

