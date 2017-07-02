pragma solidity ^0.4.4;

// That contract is pretty similar to the Constitution,
// but you should know that laws "comes" from the constitution.
// The constitution defines which laws can be accepted or not.

contract CodeOfLaw {
	uint public nbLaws;
	Law[] public allLaws;

	string codeOfLawReference;

	struct Law {
		string text;
		bool isValid;
		uint createdAt;
	}

	event LawChanged(uint lawID);
	event CodeOfLawReferenceChanged(string new_reference);

	function addLaw(string text) returns (uint lawID);
	function repealLaw(uint lawID);

	function setCodeOfLawReference(string _new);
}
