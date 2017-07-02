pragma solidity ^0.4.4;

contract Constitution {
	uint public nbArticles;
	Article[] public articlesOfConstitution;

	string constitutionReference;

	struct Article {
		string summary;
		bool valid;
		uint createdAt;
	}

	event ArticleChanged(uint id);
	event ConstitutionReferenceChanged(string new_reference);

	function addArticle(string summary) returns (uint ArticleID);
	function repealArticle(uint id);

	function setConstitutionReference(string _new);
}
