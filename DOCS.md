# RSD Smart Contract API Documentation

## Table of Contents
- [Contract Overview](#contract-overview)
- [ERC20 Functions](#erc20-functions)
- [Crowdsale Functions](#crowdsale-functions)
- [Administrative Functions](#administrative-functions)
- [Utility Functions](#utility-functions)
- [View Functions](#view-functions)
- [Events](#events)
- [Error Codes](#error-codes)
- [Gas Estimates](#gas-estimates)
- [Usage Examples](#usage-examples)

## Contract Overview

**Contract Name:** `ReferenceSystemDeFi`  
**Symbol:** `RSD`  
**Decimals:** `18`  
**Standard:** `ERC20` + Custom Extensions  
**Solidity Version:** `>=0.6.0`

## ERC20 Functions

### `transfer(address recipient, uint256 amount) → bool`

Transfers tokens from the caller's account to `recipient`.

**Parameters:**
- `recipient` (address): The address to receive tokens
- `amount` (uint256): The amount of tokens to transfer

**Returns:**
- `bool`: `true` if the transfer succeeded

**Effects:**
- Updates balances
- Triggers supply adjustment mechanism
- Distributes rewards to miners and pools
- May trigger PoBet mechanism

**Events Emitted:**
- `Transfer(address from, address to, uint256 value)`
- `SupplyAdjustment(bool reduction, uint256 amount)`
- `Reward(address miner, uint256 amount)`
- `Pool(uint256 amount)`

**Gas Cost:** ~150,000 - 300,000 gas (depending on supply adjustments)

**Example:**
```javascript
// Transfer 100 RSD tokens
await rsdContract.transfer("0x742d35Cc6084F81170839f78E5EbE9dB1eD4e3c8", web3.utils.toWei("100", "ether"));
```

### `approve(address spender, uint256 amount) → bool`

Allows `spender` to withdraw from the caller's account multiple times, up to the `amount`.

**Parameters:**
- `spender` (address): The address authorized to spend tokens
- `amount` (uint256): The maximum amount authorized

**Returns:**
- `bool`: `true` if the approval succeeded

**Events Emitted:**
- `Approval(address owner, address spender, uint256 value)`

**Gas Cost:** ~45,000 gas

### `transferFrom(address sender, address recipient, uint256 amount) → bool`

Transfers tokens from `sender` to `recipient` using the allowance mechanism.

**Parameters:**
- `sender` (address): The address to send tokens from
- `recipient` (address): The address to receive tokens
- `amount` (uint256): The amount of tokens to transfer

**Returns:**
- `bool`: `true` if the transfer succeeded

**Requirements:**
- Caller must have allowance for `sender`'s tokens of at least `amount`

**Gas Cost:** ~200,000 - 350,000 gas

### `increaseAllowance(address spender, uint256 addedValue) → bool`

Atomically increases the allowance granted to `spender` by the caller.

**Parameters:**
- `spender` (address): The address to increase allowance for
- `addedValue` (uint256): The amount to increase the allowance by

**Gas Cost:** ~50,000 gas

### `decreaseAllowance(address spender, uint256 subtractedValue) → bool`

Atomically decreases the allowance granted to `spender` by the caller.

**Parameters:**
- `spender` (address): The address to decrease allowance for
- `subtractedValue` (uint256): The amount to decrease the allowance by

**Requirements:**
- Current allowance must be >= `subtractedValue`

**Gas Cost:** ~50,000 gas

## Crowdsale Functions

### `crowdsale(address beneficiary) payable`

Allows users to purchase RSD tokens by sending ETH.

**Parameters:**
- `beneficiary` (address): The address to receive the purchased tokens

**Payment:**
- Must send ETH with the transaction
- Conversion rate: `1 ETH = SALE_RATE * 1.5 RSD`
- Maximum purchase: 50,000 RSD per transaction

**Requirements:**
- Crowdsale must be active (within duration)
- Purchase amount must not exceed maximum

**Events Emitted:**
- `Transfer(address(0), beneficiary, amount)`

**Gas Cost:** ~200,000 gas

**Example:**
```javascript
// Purchase RSD tokens with 1 ETH
await rsdContract.crowdsale(userAddress, {
    value: web3.utils.toWei("1", "ether"),
    gas: 200000
});
```

### `receive() payable`

Fallback function that automatically calls `crowdsale(msg.sender)` when ETH is sent to the contract.

**Example:**
```javascript
// Send ETH directly to contract
await web3.eth.sendTransaction({
    from: userAddress,
    to: rsdContractAddress,
    value: web3.utils.toWei("1", "ether"),
    gas: 200000
});
```

## Administrative Functions

All administrative functions require `onlyOwner` modifier.

### `updateSaleRate(uint16 rate)`

Updates the crowdsale conversion rate.

**Parameters:**
- `rate` (uint16): New sale rate (tokens per ETH)

**Example:**
```javascript
// Set rate to 3000 RSD per ETH
await rsdContract.updateSaleRate(3000, {from: ownerAddress});
```

### `updateCrowdsaleDuration(uint128 timestampDuration)`

Updates the crowdsale duration.

**Parameters:**
- `timestampDuration` (uint128): Duration in seconds from contract deployment

### `updateExpansionRate(uint16 expansionRate)`

Updates the market cap expansion rate.

**Parameters:**
- `expansionRate` (uint16): New expansion rate (affects reward pool growth)

### `updateMaxTxInterval(uint16 maxTxInterval)`

Updates the maximum transaction interval for target supply adjustments.

**Parameters:**
- `maxTxInterval` (uint16): Maximum number of transactions before adjustment

### `updateMinTxInterval(uint16 minTxInterval)`

Updates the minimum transaction interval.

**Parameters:**
- `minTxInterval` (uint16): Minimum number of transactions before adjustment

### `updateSeedNumber(uint16 newSeedNumber)`

Updates the seed number for random number generation.

**Parameters:**
- `newSeedNumber` (uint16): New seed for randomization

### `shouldRewardOwner(bool should)`

Enables or disables owner rewards.

**Parameters:**
- `should` (bool): Whether to reward the owner

### `withdrawSales(address payable account, uint256 amount)`

Withdraws specific amount of crowdsale proceeds.

**Parameters:**
- `account` (address payable): Address to receive the ETH
- `amount` (uint256): Amount of ETH to withdraw (in wei)

### `withdrawSales(address payable account)`

Withdraws all crowdsale proceeds.

**Parameters:**
- `account` (address payable): Address to receive the ETH

### `withdrawTokensSent(address tokenAddress)`

Withdraws accidentally sent ERC20/BEP20 tokens.

**Parameters:**
- `tokenAddress` (address): Address of the token contract to withdraw

## Utility Functions

### `burn(uint256 amount)`

Burns tokens from the caller's balance.

**Parameters:**
- `amount` (uint256): Amount of tokens to burn

**Effects:**
- Reduces total supply
- Updates market cap total supply

**Example:**
```javascript
// Burn 50 RSD tokens
await rsdContract.burn(web3.utils.toWei("50", "ether"), {from: userAddress});
```

### `generateRandomMoreThanOnce()`

Generates a new random number and updates the internal randomness state.

**Gas Cost:** ~50,000 gas

### `obtainRandomNumber(uint256 modulus)`

Generates and emits a random number for testing purposes.

**Parameters:**
- `modulus` (uint256): The upper bound for the random number

**Events Emitted:**
- `RandomNumber(uint256 modulus, uint256 randomNumber)`

### `mintForStakeHolder(address stakeholder, uint256 amount)`

Mints tokens for stakeholders (only callable by stake helper contract).

**Parameters:**
- `stakeholder` (address): Address to receive minted tokens
- `amount` (uint256): Amount of tokens to mint

**Requirements:**
- Caller must be the designated stake helper contract

## View Functions

### `name() → string`
Returns the token name: "Reference System for DeFi"

### `symbol() → string`
Returns the token symbol: "RSD"

### `decimals() → uint8`
Returns the number of decimals: 18

### `totalSupply() → uint256`
Returns the current total supply of tokens

### `balanceOf(address account) → uint256`
Returns the token balance of `account`

### `allowance(address owner, address spender) → uint256`
Returns remaining tokens that `spender` can spend on behalf of `owner`

### Owner-Only View Functions

### `getMarketCapTotalSupply() → uint256`
Returns the market cap total supply (for price calculations)

### `getTargetTotalSupply() → uint256`
Returns the target total supply used in adjustment mechanisms

### `getMoreThanOnceNumber() → uint256`
Returns the current "more than once" random number

### `getQ() → uint16`
Returns the current Q value used in optimal policy calculations

### `getSeedNumber() → uint16`
Returns the current seed number for randomization

### Public View Functions

### `getCrowdsaleDuration() → uint128`
Returns the crowdsale duration in seconds

### `getExpansionRate() → uint16`
Returns the current expansion rate

### `getSaleRate() → uint16`
Returns the current crowdsale rate

### `log_2(uint256 x) → uint256`
Returns the ceiling of log base 2 of `x` (utility function)

## Events

### `Transfer(address indexed from, address indexed to, uint256 value)`
Emitted when tokens are transferred, including minting and burning.

### `Approval(address indexed owner, address indexed spender, uint256 value)`
Emitted when allowance is set by `approve` or `increaseAllowance`/`decreaseAllowance`.

### `SupplyAdjustment(bool reduction, uint256 amount)`
Emitted when token supply is adjusted (minted or burned).

### `PolicyAdjustment(bool reduction, uint16 percentageFactor)`
Emitted when the adjustment policy is updated.

### `PoBet(address winner, uint256 amount)`
Emitted when someone wins the Proof of Bet mechanism.

### `Reward(address miner, uint256 amount)`
Emitted when rewards are distributed to miners or owner.

### `Pool(uint256 amount)`
Emitted when tokens are added to the reward pool.

### `RandomNumber(uint256 modulus, uint256 randomNumber)`
Emitted by `obtainRandomNumber` for testing purposes.

## Error Codes

### Standard ERC20 Errors
- `"ERC20: transfer from the zero address"`
- `"ERC20: transfer to the zero address"`
- `"ERC20: transfer amount exceeds balance"`
- `"ERC20: transfer amount exceeds allowance"`
- `"ERC20: approve from the zero address"`
- `"ERC20: approve to the zero address"`
- `"ERC20: mint to the zero address"`
- `"ERC20: burn from the zero address"`
- `"ERC20: burn amount exceeds balance"`
- `"ERC20: decreased allowance below zero"`

### Custom RSD Errors
- `"RSD: crowdsale is over"`
- `"RSD: required amount exceeds the maximum allowed"`
- `"RSD: required amount exceeds the balance"`
- `"RSD: does not have any balance"`
- `"RSD: only stake helper can call this function"`

### Ownable Errors
- `"Ownable: caller is not the owner"`

## Gas Estimates

| Function | Estimated Gas | Notes |
|----------|---------------|-------|
| `transfer` | 150,000 - 300,000 | Varies with supply adjustments |
| `approve` | 45,000 | Standard approval |
| `transferFrom` | 200,000 - 350,000 | Includes transfer mechanics |
| `crowdsale` (receive/fallback) | 200,000 | Token purchase |
| `burn` | 100,000 | Token burning |
| Administrative functions | 50,000 - 100,000 | Parameter updates |
| View functions | < 30,000 | Read-only operations |

## Usage Examples

### Complete Crowdsale Example
```javascript
const Web3 = require('web3');
const web3 = new Web3('http://localhost:8545');

// Purchase tokens
const purchaseAmount = web3.utils.toWei('1', 'ether'); // 1 ETH
const tx = await rsdContract.crowdsale(buyerAddress, {
    from: buyerAddress,
    value: purchaseAmount,
    gas: 200000
});

console.log('Tokens purchased:', tx.logs[0].args.value.toString());
```

### Transfer with Supply Adjustment
```javascript
// Transfer tokens (triggers supply adjustment)
const transferAmount = web3.utils.toWei('100', 'ether');
const tx = await rsdContract.transfer(recipientAddress, transferAmount, {
    from: senderAddress,
    gas: 300000
});

// Check events for supply adjustments
tx.logs.forEach(log => {
    if (log.event === 'SupplyAdjustment') {
        console.log('Supply adjusted:', log.args);
    }
});
```

### Admin Operations
```javascript
// Update sale rate (owner only)
await rsdContract.updateSaleRate(2500, {from: ownerAddress});

// Withdraw crowdsale proceeds
await rsdContract.withdrawSales(ownerAddress, {from: ownerAddress});

// Update system parameters
await rsdContract.updateExpansionRate(1200, {from: ownerAddress});
await rsdContract.shouldRewardOwner(false, {from: ownerAddress});
```

### Monitoring Events
```javascript
// Listen for all RSD events
rsdContract.events.allEvents({
    fromBlock: 'latest'
}, (error, event) => {
    if (error) {
        console.error('Error:', error);
    } else {
        console.log('Event:', event.event, event.returnValues);
    }
});

// Listen for specific events
rsdContract.events.PoBet({
    fromBlock: 'latest'
}, (error, event) => {
    if (!error) {
        console.log('PoBet winner:', event.returnValues.winner);
        console.log('Amount won:', event.returnValues.amount);
    }
});
```

---

**Note:** All gas estimates are approximate and may vary based on network conditions and actual transaction complexity. Always test transactions on testnets before mainnet deployment.