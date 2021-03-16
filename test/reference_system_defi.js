const ReferenceSystemDeFi = artifacts.require("ReferenceSystemDeFi");
const BigNumber = require("bignumber.js");
const DummyERC20 = artifacts.require("DummyERC20");
/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("ReferenceSystemDeFi", function (accounts) {

  const TOTAL_SUPPLY = (new BigNumber(1459240*10**18));

  before(async () => {
    rsd = await ReferenceSystemDeFi.deployed();
    erc20 = await DummyERC20.deployed();
  });

  it("should deploy contract", () => {
    assert(rsd.contract.address != undefined || rsd.contract.address != '', "Not have an address");
  });

  it("should have an initial total supply equals to TOTAL_SUPPLY", async () => {
    const totalSupply = new BigNumber(await rsd.totalSupply());
    assert(totalSupply.isEqualTo(TOTAL_SUPPLY));
  });

  it("should mint amount correctly", async () => {
    let amount = new BigNumber(10*10**18);
    await web3.eth.sendTransaction({from: accounts[0], to: rsd.address, gas: 150000, value: amount});
    let balanceAccount = await rsd.balanceOf(accounts[0]);
    assert(balanceAccount > 0);
  });  

  it("should not allow anyone to mint", async () => {
    let amount = new BigNumber(10*10**21);
    try {
      await rsd.mint(accounts[1], amount, {from: accounts[1]});
      assert(false);
    } catch(error) {
      assert(error);
    }
  });

  it("must obtain two different random numbers", async () => {
    let seed = 10;
    await rsd.updateSeedNumber(seed, {from: accounts[0]});
    let number_01 = await rsd.obtainRandomNumber(1000);
    seed++;
    await rsd.generateRandomMoreThanOnce({from: accounts[0]});
    let number_02 = await rsd.obtainRandomNumber(1000);
    assert(number_01.logs[0].args[1] != number_02.logs[0].args[1]);
  });

  it("should withdraw crowdsale amount correctly", async () => {
    let balanceAccount = new BigNumber(await web3.eth.getBalance(accounts[0]));
    let amount = new BigNumber(10*10**18);
    await web3.eth.sendTransaction({from: accounts[1], to: rsd.address, gas: 150000, value: amount});
    await rsd.withdrawSales(accounts[0], {from: accounts[0]});
    let newBalanceAccount = new BigNumber(await web3.eth.getBalance(accounts[0]));
    assert(newBalanceAccount.toNumber() > balanceAccount.toNumber());
  });

  it("should not perform crowdsale if the requested amount is greater than the maximum allowed", async () => {
    try {
      let amount = new BigNumber(201*10**18); // SALE_RATE = 250 | MAX_AMOUNT = 50000e18;
      await web3.eth.sendTransaction({from: accounts[1], to: rsd.address, gas: 150000, value: amount});
      await rsd.withdrawSales(accounts[0], {from: accounts[0]});
      assert(false);      
    } catch(error) {
      assert(error);
    }    
  });

  it("should burn requested amount correctly", async () => {
    let balance = await rsd.balanceOf(accounts[0]);
    if (balance > 0) {
      await rsd.burn(balance, {from: accounts[0]});
      let newBalance = await rsd.balanceOf(accounts[0]);
      assert(newBalance == 0);
    } else {
      assert(false);
    }
  });

  it("must update total supply after each transfer", async () => {
    let amount = new BigNumber(10*10**18);
    await web3.eth.sendTransaction({from: accounts[0], to: rsd.address, gas: 150000, value: amount});
    let totalSupply = await rsd.totalSupply();
    await rsd.transfer(accounts[1], amount, {from: accounts[0]});
    let newTotalSupply = await rsd.totalSupply();
    assert(newTotalSupply != totalSupply);
  });

  it("must update target total supply after each transfer", async () => {
    let amount = new BigNumber(10*10**18);
    await web3.eth.sendTransaction({from: accounts[0], to: rsd.address, gas: 150000, value: amount});
    let targetTotalSupply = await rsd.getTargetTotalSupply();
    await rsd.transfer(accounts[1], amount, {from: accounts[0]});
    let newTargetTotalSupply = await rsd.getTargetTotalSupply();
    assert(newTargetTotalSupply != targetTotalSupply);
  });  

  it("should calculate ceil(log2(value)) correctly", async () => {
    let l = await rsd.log_2(1500000);
    let ll = Math.ceil(Math.log2(1500000));
    assert(l == ll);
  });

  it("should not allow any address to get access at some contract properties, only owner", async () => {
    try {
      await rsd.getQ({from: accounts[1]});
      assert(false);
    } catch(error) {
      assert(error);
    }
  });

  it("should update Q value after a transfer", async () => {
    let amount = new BigNumber(10*10**18);
    await web3.eth.sendTransaction({from: accounts[0], to: rsd.address, gas: 150000, value: amount});
    await rsd.transfer(accounts[1], amount, {from: accounts[0]});
    let Q = await rsd.getQ({from: accounts[0]});
    Q = BigNumber(Q);
    assert(!Q.isEqualTo(0));
  });

  it("should update seed number correctly", async () => {
    let firstSeed = await rsd.getSeedNumber({from: accounts[0]});
    await rsd.updateSeedNumber(33);
    let secondSeed = await rsd.getSeedNumber({from: accounts[0]});
    assert(firstSeed != secondSeed);
  });

  it("should transfer amount between two parties successfully", async () => {
    let amount = new BigNumber(10*10**18);
    await web3.eth.sendTransaction({from: accounts[0], to: rsd.address, gas: 150000, value: amount});
    await rsd.transfer(accounts[1], amount, {from: accounts[0]});
    let balance = await rsd.balanceOf(accounts[1]);
    let amount_01 = BigNumber(balance + amount);
    let amount_02 = BigNumber(balance + amount.minus(amount.times(0.015)));
    assert(amount_01.isGreaterThan(amount_02));
  });

  it("should not allow crowdsale after deadline", async () => {
    await rsd.updateCrowdsaleDuration(1, {from: accounts[0]});
    try {
      let amount = new BigNumber(10*10**18);
      await web3.eth.sendTransaction({from: accounts[1], to: rsd.address, gas: 150000, value: amount});
      await rsd.withdrawSales(accounts[0], {from: accounts[0]});
      assert(false);      
    } catch(error) {
      assert(error);
    }
    await rsd.updateCrowdsaleDuration(15778458, {from: accounts[0]});
  });  

  it("should not allow another address to mint for stakeholders", async () => {
    let amount = new BigNumber(10*10**21);
    try {
      await rsd.mintForStakeHolder(accounts[1], amount, {from: accounts[0]});
      assert(false);
    } catch(error) {
      assert(error);
    }    
  });

  it("should withdraw sent ERC-20 / BEP-20 tokens correctly", async () => {
    const amount = new BigNumber(10*10**21);
    await erc20.mint(amount, {from: accounts[1]});
    await erc20.transfer(rsd.address, amount, {from: accounts[1]});
    await rsd.withdrawTokensSent(erc20.address, {from: accounts[0]});
    const amount2 = new BigNumber(await erc20.balanceOf(accounts[0]));
    assert(amount2.isEqualTo(amount));
  });

  it("should generate 'more than once' number correctly", async () => {
    let m1 = await rsd.getMoreThanOnceNumber({from: accounts[0]});
    await rsd.generateRandomMoreThanOnce();
    let m2 = await rsd.getMoreThanOnceNumber({from: accounts[0]});
    assert(m1 != m2);
  });
});
