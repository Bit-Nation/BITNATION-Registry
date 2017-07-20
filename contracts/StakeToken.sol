pragma solidity ^0.4.4;

import "zeppelin/contracts/token/PausableToken.sol";
import "zeppelin/contracts/token/MintableToken.sol";

// That token is controlled by the DBVN
// It represents the stake/shares of each members

// DBVN can choose to mint (allocate) new tokens for someone
// as well as freezing (pausing) all transfers, or unfreezing them

contract StakeToken is PausableToken, MintableToken {
  string public name = "Stake Token";
  string public symbol = "STK";
  uint public decimals = 18;
}
