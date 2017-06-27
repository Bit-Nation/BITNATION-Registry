pragma solidity ^0.4.4;

contract Nation {
	uint public nbApplications;
	address[] public pendingApplications;
	mapping (address => bool) hasPendingApplication;

        uint public nbCitizens;
        address[] public citizens;
        mapping (address => bool) isCitizen;

	modifier mustHaveApplication(address addr) {
		if (!hasPendingApplication[addr]) throw;
		_;
	}

	modifier mustHaveNoApplication(address addr) {
		if (hasPendingApplication[addr]) throw;
		_;
	}

	modifier mustBeCitizen(address addr) {
		if (!isCitizen[addr]) throw;
		_;
	}

	modifier mustNotBeCitizen(address addr) {
		if (isCitizen[addr]) throw;
		_;
	}

	// An applicant must not be a citizen
	function applyForCitizenship() mustHaveNoApplication(msg.sender) mustNotBeCitizen(msg.sender);
	function cancelApplication() mustHaveApplication(msg.sender) mustNotBeCitizen(msg.sender);

	// A citizen must not have any application
	function cancelCitizenship() mustHaveNoApplication(msg.sender) mustBeCitizen(msg.sender);

	// This is sad...
	// Typically: move funds (if some) and self-destruct
	function onCollapse();
}

