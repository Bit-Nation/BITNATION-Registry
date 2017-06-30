pragma solidity ^0.4.4;

contract Constitution {
	uint public nbArticles;
	Article[] public articlesOfConstitution;

	struct Article {
		string summary;
		bool valid;
		uint createdAt;
	}

	event ArticleChanged(uint id);

	function addArticle(string summary) returns (uint ArticleID);
	function repealArticle(uint id);
}
