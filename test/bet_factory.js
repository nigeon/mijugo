var BetFactory = artifacts.require("./BetFactory.sol");

contract('BetFactory', async (accounts) => {
  
  it("should create a bet", async () => {
    let instance = await BetFactory.deployed();
    let receipt = await instance.createBet('test title', web3.toWei(0.0023, "ether"));

    let created_bet = await instance.bets.call(0);

    assert.equal(created_bet[0], accounts[0], "Created Bet owner should be the same");
    assert.equal(created_bet[1], "test title", "Created Bet title should be 'test title'");
    assert.equal(created_bet[2], web3.toWei(0.0023, "ether"), "Created Bet entry price should be 23");
  });

  it("should be able to enter a bet", async () => {
    let instance = await BetFactory.deployed();
    let receipt = await instance.createBet('Bet title', web3.toWei(0.001, "ether"));
    let entry_receipt = await instance.enter(1,"entry text",{from:accounts[1], value: web3.toWei(0.001, "ether")});

    let created_entry = await instance.entries.call(0);

    assert.equal(created_entry[0], 1, "Entered to Bet 1");
    assert.equal(created_entry[1], accounts[1], "Created Entry owner should be the same");
    assert.equal(created_entry[2], "entry text", "Created Bet title should be 'test title'");
    assert.equal(created_entry[3], web3.toWei(0.001, "ether"), "Created Bet entry price should be 0.001");
  });

});