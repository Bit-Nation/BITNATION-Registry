pragma solidity ^0.4.13;

import "zeppelin/contracts/token/PausableToken.sol";
import "zeppelin/contracts/token/MintableToken.sol";
import "zeppelin/contracts/ownership/Ownable.sol";

// That token is controlled by the DBVN
// It represents the stake/shares of each members

// DBVN can choose to mint (allocate) new tokens for someone
// as well as freezing (pausing) all transfers, or unfreezing them

contract StakeToken is Ownable, PausableToken, MintableToken {
  string public name = "Stake Token";
  string public symbol = "STK";
  uint public decimals = 18;

  // If someone start behaving in an "evil" way, the DBVN can empty its account
  // Thus reducing its stake to 0
  event AccountEmptied(address account);

  function empty(address _from) onlyOwner {
    balances[_from] = 0;
    balances[owner] = balances[owner].add(balances[_from]);
    AccountEmptied(_from);
  }
}
