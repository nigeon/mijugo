var BetFactory = artifacts.require("./BetFactory.sol");

contract('BetFactory', async (accounts) => {
  
  it("should create a bet", async () => {
    let instance = await BetFactory.deployed();
    await instance.createBet('test title', web3.toWei(0.0023, "ether"));

    let created_bet = await instance.bets.call(0);

    assert.equal(created_bet[0], accounts[0], "Created Bet owner should be the same");
    assert.equal(created_bet[1], "test title", "Created Bet title should be 'test title'");
    assert.equal(created_bet[2], web3.toWei(0.0023, "ether"), "Created Bet entry price should be 23");
  });

  it("should be able to enter a bet", async () => {
    let instance = await BetFactory.deployed();
    let receipt = await instance.createBet('Bet title', web3.toWei(0.001, "ether"));
    await instance.enter(1,"entry text",{from:accounts[1], value: web3.toWei(0.001, "ether")});

    let created_entry = await instance.entries.call(0);

    assert.equal(created_entry[0], 1, "Entered to Bet 1");
    assert.equal(created_entry[1], accounts[1], "Created Entry owner should be the same");
    assert.equal(created_entry[2], "entry text", "Created Bet title should be 'test title'");
    assert.equal(created_entry[3], web3.toWei(0.001, "ether"), "Created Bet entry price should be 0.001");
  });

  it("should not let enter a bet with a wrong price", async () => {
    let instance = await BetFactory.deployed();

    try {
      let entry_receipt = await instance.enter(1,"wrong price",{from:accounts[1], value: web3.toWei(0.000002, "ether")});
      assert.fail('Expected revert not received');
    } catch (error) {
      const revertFound = error.message.search('revert') >= 0;
      assert(revertFound, `Expected "revert", got ${error} instead`);
    }
  });

  it("random accoun't shouldn't be able to stop the bet", async () => {
    let instance = await BetFactory.deployed();

    try {
      await instance.stop(0,{from:accounts[1]});
      assert.fail('Expected revert not received');
    } catch (error) {
      const revertFound = error.message.search('revert') >= 0;
      assert(revertFound, `Expected "revert", got ${error} instead`);
    }
  });

  it("owner should be able to stop the bet", async () => {
    let instance = await BetFactory.deployed();
    await instance.stop(0);

    let created_bet = await instance.bets.call(0);

    //assert.equal(created_bet[4], BetFactory.BetStatus.stopped, "Status is not closed!"); //You can't (for now), as enums are not supported by the ABI.
    assert.equal(created_bet[4], 1, "Status is not stopped!"); 
  });

  it("owner shouldn't be able to end an active bet", async () => {
    let instance = await BetFactory.deployed();

    try {
      await instance.end(1,"winner entry",{from:accounts[1]});
      assert.fail('Expected revert not received');
    } catch (error) {
      const revertFound = error.message.search('revert') >= 0;
      assert(revertFound, `Expected "revert", got ${error} instead`);
    }
  });

  it("random account shouldn't be able to end a bet", async () => {
    let instance = await BetFactory.deployed();

    try {
      await instance.end(0,"winner entry",{from:accounts[1]});
      assert.fail('Expected revert not received');
    } catch (error) {
      const revertFound = error.message.search('revert') >= 0;
      assert(revertFound, `Expected "revert", got ${error} instead`);
    }
  });

  it("owner should be able to end a stopped bet", async () => {
    let instance = await BetFactory.deployed();
    await instance.end(0,"winner entry");

    let created_bet = await instance.bets.call(0);

    //assert.equal(created_bet[4], BetFactory.BetStatus.ended, "Status is not !"); //You can't (for now), as enums are not supported by the ABI.
    assert.equal(created_bet[4], 2, "Status is not ended!"); 
  });

});