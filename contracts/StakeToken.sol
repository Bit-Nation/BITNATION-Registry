pragma solidity ^0.4.13;

import "zeppelin/contracts/token/StandardToken.sol";
import "zeppelin/contracts/ownership/Ownable.sol";

// That token is controlled by the DBVN
// It represents the stake/shares of each members

// DBVN can choose to mint (allocate) new tokens for someone
// as well as freezing (pausing) all transfers, or unfreezing them

// I had to reimplement the Pausable and Mintable functions, to avoid
// a linearization of the inheritance graph

contract StakeToken is Ownable, StandardToken {
  string public name = "Stake Token";
  string public symbol = "STK";
  uint public decimals = 18;

  // Pausable (renamed to freezable)

  event Freeze();
  event Unfreeze();

  bool public freezed = false;

  modifier whenNotFreezed() {
    require(!freezed);
    _;
  }

  modifier whenFreezed {
    require(freezed);
    _;
  }

  function freeze() onlyOwner whenNotFreezed returns (bool) {
    freezed = true;
    Freeze();
    return true;
  }

  // called by the owner to unpause, returns to normal state
  function unfreeze() onlyOwner whenFreezed returns (bool) {
    freezed = false;
    Unfreeze();
    return true;
  }

  function transfer(address _to, uint _value) whenNotFreezed returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) whenNotFreezed returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  // Mintable
  event Mint(address indexed to, uint value);
  event MintFinished();

  bool public mintingFinished = false;
  uint public totalSupply = 0;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  function mint(address _to, uint _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }

  // If someone start behaving in an "evil" way, the DBVN can empty its account
  // Thus reducing its stake to 0
  event AccountEmptied(address account);

  function empty(address _from) onlyOwner {
    balances[_from] = 0;
    balances[owner] = balances[owner].add(balances[_from]);
    AccountEmptied(_from);
  }
}
