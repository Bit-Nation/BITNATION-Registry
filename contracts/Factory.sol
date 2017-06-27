pragma solidity ^0.4.4;

import "zeppelin/contracts/ownership/Ownable.sol";
import "zeppelin/contracts/ownership/HasNoContracts.sol";
import "zeppelin/contracts/ownership/HasNoEther.sol";
import "zeppelin/contracts/ownership/HasNoTokens.sol";

import "./Nation.sol";

// The set of Zeppelin's HasNo* contracts let the owner take back its ETH, and (just in case) the tokens or contracts associated
contract Factory is Ownable, HasNoContracts, HasNoEther, HasNoTokens {
	event NationCreated(address at, address creator, string name, string nation_type, string meta);
	event NationCollapsed(address nation);

	event NewRate(address nation, address rater, bool inSupport, string reason);

	uint public minimumBid;

	uint public nbNations;
	address[] public nationsList;
	mapping (address => NationStore) public nations;

	struct NationStore {
		address creator;
		Nation nation;

		bool collapsed;

		string name;
		string nation_type; // Holocracy, meritocracy...
		string meta;        // To store an URL, a description...

		uint nbRaters;
		address[] raters;
		mapping (address => Rate) rates;
		mapping (address => bool) rated;
	}

	struct Rate {
		address rater;
		bool inSupport;
		string reason;
	}

	modifier notCollapsed(address _at) {
		if (nations[_at].collapsed) {
			throw;
		}
		_;
	}

	modifier onlyCreator(address _at) {
		// Side effect: check that the nation exist
		if (nations[_at].creator != msg.sender) {
			throw;
		}
		_;
	}

	modifier shouldNotExist(address _at) {
		if (nations[_at].creator != 0x0) {
			throw;
		}
		_;
	}
	
	modifier mustExist(address _at) {
		if (nations[_at].creator == 0x0) {
			throw;
		}
		_;
	}

	modifier checkBid {
		if (msg.value < minimumBid) {
			throw;
		}
		_;
	}
	
	function Factory() {
	    nationsList.push(0x0); // Nation 0 = 0x0
	}

	function setMinimumBid(uint value) onlyOwner {
		minimumBid = value * 1 ether;
	}

	// We require creators to pay a minimum to fund development
	function registerNation(address _at, string _name, string _type, string _meta) payable shouldNotExist(_at) checkBid {
		nbNations++;
		nationsList.push(_at); // Add it to the list

		NationStore n = nations[_at];
		n.creator = msg.sender;
		n.nation = Nation(_at);
		n.collapsed = false;
		n.name = _name;
		n.nation_type = _type;
		n.meta = _meta;
		n.raters.push(0x0);              // Voter 0
		
		NationCreated(_at, msg.sender, _name, _type, _meta);
	}

	// We ask the creator to provide the ID of its nation: the place of the nation in the list `nationsList`
	function unregisterNation(address _at) onlyCreator(_at) notCollapsed(_at) {
		nations[_at].nation.onCollapse();

		delete nations[_at];

		NationCollapsed(_at);
	}

	// Place a new vote or change your mind
	function rate(address nation, bool support, string _reason) notCollapsed(nation) mustExist(nation) {
		if (!nations[nation].rated[msg.sender]) {
			nations[nation].nbRaters++;
			nations[nation].rated[msg.sender] = true;
			nations[nation].raters.push(msg.sender);
		}

		Rate r = nations[nation].rates[msg.sender];
		r.rater = msg.sender;
		r.inSupport = support;
		r.reason = _reason;

		NewRate(nation, msg.sender, support, _reason);
	}
	
	function getRate(address nation, address rater) returns (address, bool, string) {
	    Rate r = nations[nation].rates[rater];
	    return (r.rater, r.inSupport, r.reason);
	}
	
	function getRater(address nation, uint id) mustExist(nation) returns (address) {
	    return nations[nation].raters[id];
	}
}

