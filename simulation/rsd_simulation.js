const BigNumber = require("bignumber.js");
const TRACE_TRANSACTIONS            = true;
const TRACE_PRICE_ESTIMATION        = true;
const MULTIPLIER                    = Math.ceil(Math.random() * 100000000000000000000);
const BLOCKS                        = 5000000;
const INTERVAL_COUNT                = 144;
const NUMBER_OF_ACCOUNTS            = 10;
let PERCENTAGE_OF_BALANCE           = 0.25;
const PERCENTAGE_OF_CONTRACTS				= 0.4;
const REWARD_MINERS                 = true;
const ALPHA                         = 0.12;
const EPSILON 											= 0.12;
let EXPANSION_RATE                  = 1000;
let MIN_PERCENTAGE_FACTOR           = 85;
let initialSupply = new BigNumber(0);
let totalSupply = new BigNumber(0);
let marketCapTotalSupply = new BigNumber(0);
let targetTotalSupply = 0;
let percentageFactor = 0.01;
let maxPercentageFactor = -Infinity;
let avgPercentageFactor = 0;
let reduceSupply = true;
let metric = 0;
let Q = 0;
let qtyBefore = 0;
let qtyAfter = 0;
let deltaPriceBefore = 0;
let deltaPriceAfter = 0;
let numberTx = 0;
let marketPrice = new BigNumber(1);

function updatePolicy() {
  if (Math.random() > EPSILON)
    policy = adjustPolicyOptimal();
  else
    policy = adjustPolicyRandom();

  percentageFactor = policy["percentage"];
  reduceSupply = policy["reduceSupply"];  

  if (percentageFactor > maxPercentageFactor)
    maxPercentageFactor = percentageFactor;

  avgPercentageFactor = avgPercentageFactor * 0.9 + percentageFactor * 0.1;
}

function adjustPolicyOptimal() {
  let _percentageFactor;
  Q = Q * (1 - ALPHA) + metric * ALPHA;
  _reduceSupplyFlag = (targetTotalSupply < totalSupply);
  _percentageFactor = 100 / (Q + MIN_PERCENTAGE_FACTOR);
  return {"percentage": _percentageFactor / 100, "reduceSupply": _reduceSupplyFlag};
}

function adjustPolicyRandom() {
    let _percentageFactor;
    let _reduceSupplyFlag = (Math.random() > 0.5) ? true : false;
    _percentageFactor = 100 / (Math.abs(Math.ceil(Math.random() * 100)) + MIN_PERCENTAGE_FACTOR);
    return {"percentage": _percentageFactor / 100, "reduceSupply": _reduceSupplyFlag};
}

class Account {
    constructor() {
        this.balance = 500;
				this.txProbability = Math.random();
				this.type = 0;
    }

    set setBalance(newBalance) {
        this.balance = newBalance;
    }
}

// Initializing accounts
accounts = new Array();
for (let i = 0; i < NUMBER_OF_ACCOUNTS; i++) {
    let account = new Account();
    if (i == (NUMBER_OF_ACCOUNTS - 1))
			account.balance = 0;
		if (Math.random() < PERCENTAGE_OF_CONTRACTS)
			account.type = 1;	
    marketCapTotalSupply = marketCapTotalSupply.plus(account.balance);
    totalSupply = totalSupply.plus(account.balance);
		targetTotalSupply = totalSupply;
		initialSupply = marketCapTotalSupply;
    accounts.push(account);
}

// Run simulation
let avgBalanceAccounts = 0;
for (let i = 0; i < BLOCKS; i++) {
    for (let j = 0; j < accounts.length; j++) {
        avgBalanceAccounts = avgBalanceAccounts * 0.9 + accounts[j].balance * 0.1;
        let probability = accounts[j].txProbability;

        if (probability > Math.random() && accounts[j].balance > 0) {
            // CHOOSING ACOOUNT TO TRANSFER
            let accountToTransfer = 0;
            do {
                accountToTransfer = Math.ceil((MULTIPLIER * Math.random()) % (NUMBER_OF_ACCOUNTS - 1));
            } while (accountToTransfer == j);

            let amountToTransfer = 0;
            let oldBalanceSender = accounts[j].balance;
            let oldBalanceReceiver = accounts[accountToTransfer].balance;
            let amount = accounts[j].balance * (Math.random() * PERCENTAGE_OF_BALANCE);

            if (amount < 0.01)
                continue;
					
            let amountToReduce = 0;
            let amountToIncrease = 0;
            let amountToReward = 0;
            if (REWARD_MINERS) {
                amountToReward = amount * (percentageFactor / 2);
                if (EXPANSION_RATE > 0)
                  marketCapTotalSupply = marketCapTotalSupply.plus(amountToReward / EXPANSION_RATE);
            }

            if (reduceSupply) {
                amountToReduce = amount * percentageFactor;
                amountToTransfer = amount - amountToReduce - amountToReward;
                totalSupply = totalSupply.minus(amountToReduce);
            } else {
								amountToIncrease = amount * percentageFactor;
                amountToTransfer = amount + (amountToIncrease / 2);
                totalSupply = totalSupply.plus(amountToIncrease + amountToReward);
            }
            
            accounts[j].setBalance = accounts[j].balance - amount + (amountToIncrease / 2);
            accounts[accountToTransfer].setBalance = accounts[accountToTransfer].balance + amountToTransfer;
            accounts[NUMBER_OF_ACCOUNTS - 1].setBalance = accounts[NUMBER_OF_ACCOUNTS - 1].balance + amountToReward; // MINER ACCOUNT

            if (TRACE_TRANSACTIONS) {
                console.log('------------------------------------------------------------------------------------------');
                console.log(`BLOCK #${i} -- Account #${j} transfering ${amount.toFixed(2)} [${amountToTransfer.toFixed(2)}] RSD to Account #${accountToTransfer}`);
                console.log(`Balance account #${j} - OLD: ${oldBalanceSender.toFixed(2)} NEW: ${accounts[j].balance.toFixed(2)} RSD`);
                console.log(`Balance account #${accountToTransfer} - OLD: ${oldBalanceReceiver.toFixed(2)} NEW: ${accounts[accountToTransfer].balance.toFixed(2)} RSD`);
                console.log(`Reducing: ${amountToReduce.toFixed(2)} RSD | Increasing: ${amountToIncrease.toFixed(2)} RSD | MINER: ${amountToReward.toFixed(2)} RSD`);
                console.log(`TARGET TOTAL SUPPLY: ${targetTotalSupply.toNumber().toFixed(2)} RSD | CURRENT TOTAL SUPPLY: ${totalSupply.toNumber().toFixed(2)} RSD`);
                console.log(`PERCENTAGE: ${(percentageFactor * 100).toFixed(2)}% | MAX PERCENTAGE: ${(maxPercentageFactor * 100).toFixed(2)}% | AVG PERCENTAGE: ${(avgPercentageFactor * 100).toFixed(2)}%`);
                console.log(`AVG DISTRIBUTION (SUPPLY / HOLDERS): ${totalSupply.div(NUMBER_OF_ACCOUNTS).toNumber().toFixed(2)} RSD | AVG BALANCE ACCOUNTS: ${avgBalanceAccounts.toFixed(2)} RSD`);
                console.log(`Q: ${Q} | METRIC: ${metric}`);
            }
            metric = Math.log2(Math.abs(targetTotalSupply - totalSupply) + 1);
            metric = metric > 100 ? 0 : 100 - metric;
            updatePolicy();

            numberTx++;
						qtyAfter += amount;
            if (numberTx > 12 && numberTx % Math.round(Math.random() * INTERVAL_COUNT) == 0) 
							estimatePrice();
        }
    }
}

function estimatePrice() {
	qtyAfter /= numberTx;
	deltaPriceAfter = ((qtyAfter - qtyBefore) / ((qtyAfter + qtyBefore) / 2)) / 100;
  
  marketPrice = marketPrice <= 0 ? BigNumber(1) : marketPrice;

  if (qtyAfter >= qtyBefore)
    targetTotalSupply = marketCapTotalSupply.minus(totalSupply.times(Math.abs(deltaPriceAfter)));
  else
    targetTotalSupply = marketCapTotalSupply.plus(totalSupply.times(Math.abs(deltaPriceAfter)));

  EXPANSION_RATE = 1000 + (1000 * deltaPriceAfter);
  
  if (TRACE_PRICE_ESTIMATION) {
    console.log('------------------------------------------------------------------------------------------');
    console.log(`QTY BEFORE: ${qtyBefore.toFixed(0)} RSD | QTY AFTER: ${qtyAfter.toFixed(0)} RSD`);
    console.log(`DELTA PRICE BEFORE: ${(deltaPriceBefore * 100).toFixed(5)} % | DELTA PRICE AFTER: ${(deltaPriceAfter * 100).toFixed(5)} %`);
    console.log(`AVG DISTRIBUTION (SUPPLY / HOLDERS): ${totalSupply.div(NUMBER_OF_ACCOUNTS).toNumber().toFixed(2)} RSD | AVG BALANCE ACCOUNTS: ${avgBalanceAccounts.toFixed(2)} RSD`);
    console.log(`TOTAL SUPPLY: ${totalSupply.toNumber().toFixed(2)} RSD | TARGET TOTAL SUPPLY: ${targetTotalSupply.toNumber().toFixed(2)} RSD | INITIAL SUPPLY: ${initialSupply.toNumber().toFixed(2)} RSD`);
		console.log(`ABS. GROW RATE: ${((totalSupply.minus(initialSupply)).div(totalSupply).times(100)).toNumber().toFixed(4)} % | EXPANSION RATE: ${EXPANSION_RATE.toFixed(2)}`);
	}

  numberTx = 0;
  deltaPriceBefore = deltaPriceAfter;
  qtyBefore = qtyAfter;
  qtyAfter = 0;  
}

console.log(`INITIAL SUPPLY: ${initialSupply.toNumber().toFixed(2)} RSD`);
console.log(`FINAL SUPPLY: ${totalSupply.toNumber().toFixed(2)} RSD`);
console.log(`GROW RATE: ${((totalSupply.minus(initialSupply)).div(totalSupply).times(100)).toNumber().toFixed(4)} %`);