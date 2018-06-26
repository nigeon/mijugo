pragma solidity ^0.4.23;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/BetFactory.sol";

contract TestBetFactory {
  uint public initialBalance = 10 ether;

  BetFactory betfactory = BetFactory(DeployedAddresses.BetFactory());

  function testSettingAnOwnerOfDeployedContract() public {
    Assert.equal(betfactory.owner(), msg.sender, "An owner is different than a deployer");
  }

  function testUserCanCreateBet() public {
    uint returnedId = betfactory.createBet('title', 10 wei);
    uint expected = 0;
    Assert.equal(returnedId, expected, "First bet ID '0' should be recorded.");
  }

  function testUserCanCreateAnotherBet() public {
    uint returnedId = betfactory.createBet('second', 25 wei);
    uint expected = 1;
    Assert.equal(returnedId, expected, "Second bet ID '1' should be recorded.");
  }

  function testUserCanEnter() public {
    uint returnedId = betfactory.enter.value(10 wei)(0,"Entering the first entry");
    uint expected = 0;
    Assert.equal(returnedId, expected, "First entry ID '0' should be recorded.");
  }

}