# Reference System for DeFi (RSD)

![RSD Logo](logo/rsd_color.png)

**Author:** Apolo San  
**License:** MIT  
**Version:** 1.0.0

## Overview

Reference System for DeFi (RSD) is an innovative DeFi protocol that implements a dynamic supply adjustment mechanism for an ERC20 token. The system automatically adjusts token supply based on trading volume and market activity, combined with a unique reward system and gambling mechanism.

## 🚀 Key Features

### 🔄 Dynamic Supply Adjustment
- **Elastic Supply**: Token supply automatically adjusts based on trading volume and market metrics
- **Optimal Policy Algorithm**: Uses machine learning-inspired algorithms to determine supply changes
- **Random Policy Fallback**: Implements random adjustments for increased unpredictability

### 💰 Economic Mechanisms
- **Crowdsale Functionality**: Built-in token sale mechanism with configurable duration and rates
- **Miner Rewards**: Automatic rewards for block miners (10% of reward pool)
- **Owner Rewards**: Configurable rewards for contract owner
- **Proof of Bet (PoBet)**: Gambling mechanism where users can win pooled tokens

### 🛡️ Security Features
- **OpenZeppelin Integration**: Built on battle-tested OpenZeppelin contracts
- **Access Control**: Owner-only functions for critical parameters
- **SafeMath**: Protection against integer overflow/underflow
- **Comprehensive Testing**: Extensive test suite covering all functionality

## 📊 Economic Model

### Supply Adjustment Algorithm

The RSD token implements a sophisticated supply adjustment mechanism:

```
1. Volume Tracking: Monitor trading volume over transaction intervals
2. Metric Calculation: Calculate distance between target and current supply
3. Policy Decision: Choose between optimal or random adjustment policy
4. Supply Adjustment: Mint or burn tokens based on policy decision
5. Reward Distribution: Distribute rewards to miners and pools
```

### Key Parameters

| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `ALPHA` | 120 | Learning rate for optimal policy |
| `EPSILON` | 120 | Threshold for policy selection |
| `EXPANSION_RATE` | 1000 | Rate of market cap expansion (0.1%) |
| `SALE_RATE` | 2000 | Crowdsale conversion rate |
| `CROWDSALE_DURATION` | 7889229 | Crowdsale duration (3 months) |

## 🛠️ Installation & Setup

### Prerequisites

- Node.js >= 12.0.0
- npm or yarn
- Truffle Framework
- Ganache CLI (for local development)

### Installation

```bash
# Clone the repository
git clone https://github.com/apolosan/rsd.git
cd rsd

# Install dependencies
npm install

# Install Truffle globally (if not already installed)
npm install -g truffle

# Install Ganache CLI for local blockchain
npm install -g ganache-cli
```

### Environment Setup

1. Create a `.secret` file with your mnemonic phrase:
```bash
echo "your twelve word mnemonic phrase here" > .secret
```

2. Configure network settings in `truffle-config.js` as needed.

## 🚀 Usage

### Local Development

1. **Start Ganache:**
```bash
ganache-cli
```

2. **Compile Contracts:**
```bash
truffle compile
```

3. **Deploy Contracts:**
```bash
truffle migrate --network development
```

4. **Run Tests:**
```bash
truffle test
```

### Running the Simulation

The project includes a comprehensive JavaScript simulation:

```bash
node simulation/rsd_simulation.js
```

This simulation demonstrates:
- Multi-account trading scenarios
- Supply adjustment mechanisms
- Reward distribution
- Price estimation algorithms

### Deployment to Testnet

Deploy to BSC Testnet:
```bash
truffle migrate --network bsc_testnet
```

## 📋 Smart Contract API

### Core Functions

#### ERC20 Standard Functions
```solidity
function transfer(address recipient, uint256 amount) external returns (bool)
function approve(address spender, uint256 amount) external returns (bool)
function transferFrom(address sender, address recipient, uint256 amount) external returns (bool)
```

#### Crowdsale Functions
```solidity
function crowdsale(address beneficiary) public payable
```
- Allows users to purchase RSD tokens by sending ETH
- Rate: 1 ETH = `SALE_RATE * 1.5` RSD tokens
- Maximum purchase: 50,000 RSD per transaction

#### Administrative Functions (Owner Only)
```solidity
function updateSaleRate(uint16 rate) external onlyOwner
function updateCrowdsaleDuration(uint128 timestampDuration) external onlyOwner
function updateExpansionRate(uint16 expansionRate) external onlyOwner
function withdrawSales(address payable account) external onlyOwner
```

#### Utility Functions
```solidity
function burn(uint256 amount) external
function generateRandomMoreThanOnce() external
function obtainRandomNumber(uint256 modulus) external
```

### Events

```solidity
event SupplyAdjustment(bool reduction, uint256 amount)
event PolicyAdjustment(bool reduction, uint16 percentageFactor)
event PoBet(address winner, uint256 amount)
event Reward(address miner, uint256 amount)
event Pool(uint256 amount)
```

## 🧪 Testing

The project includes comprehensive tests covering:

- **Contract Deployment**: Verify proper initialization
- **ERC20 Functionality**: Standard token operations
- **Crowdsale Mechanism**: Token purchase and limits
- **Supply Adjustment**: Dynamic supply changes
- **Reward System**: Miner and owner rewards
- **Random Number Generation**: Cryptographic randomness
- **Access Control**: Owner-only functions

Run specific test categories:
```bash
# Run all tests
truffle test

# Run with gas reporting
truffle test --reporter eth-gas-reporter
```

## 🏗️ Architecture

### Contract Structure

```
ReferenceSystemDeFi.sol
├── ERC20 Implementation
├── Ownable Access Control
├── Crowdsale Functionality
├── Supply Adjustment Engine
├── Reward Distribution System
├── Random Number Generator
└── Betting Mechanism (PoBet)
```

### Key Design Patterns

1. **Factory Pattern**: Used for account and transaction management
2. **Observer Pattern**: Events for external monitoring
3. **Strategy Pattern**: Multiple policy adjustment strategies
4. **Singleton Pattern**: Contract state management

### Dependencies

- `@openzeppelin/contracts`: Security and standard implementations
- `@truffle/hdwallet-provider`: Wallet management for deployment
- `bignumber.js`: Precise decimal arithmetic
- `@metamask/detect-provider`: Web3 provider detection

## 🔒 Security Considerations

### Implemented Protections

1. **Integer Overflow Protection**: SafeMath library usage
2. **Access Control**: Owner-only critical functions
3. **Reentrancy Protection**: Proper state updates before external calls
4. **Input Validation**: Parameter bounds checking
5. **Randomness**: Cryptographically secure random number generation

### Known Limitations

1. **Oracle Dependency**: Price feeds rely on transaction volume
2. **Centralization**: Owner has significant control over parameters
3. **Complexity**: Advanced economic mechanisms may have edge cases

### Security Audit Status

⚠️ **This contract has not undergone a professional security audit.** Use in production environments at your own risk.

## 📊 Economic Simulation Results

The included simulation demonstrates:

- **Supply Elasticity**: Token supply adjusts ±15% based on trading volume
- **Reward Distribution**: ~1-2% of transaction volume goes to rewards
- **Price Stability**: Mechanism helps stabilize token value
- **Network Effects**: Increased usage leads to more rewards

Example simulation output:
```
INITIAL SUPPLY: 4950.00 RSD
FINAL SUPPLY: 5247.83 RSD
GROW RATE: 5.6742 %
```

## 🤝 Contributing

### Development Setup

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes and add tests
4. Ensure all tests pass: `truffle test`
5. Commit your changes: `git commit -m 'Add amazing feature'`
6. Push to the branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

### Coding Standards

- Follow Solidity style guide
- Add comprehensive tests for new features
- Document all public functions
- Use meaningful variable names
- Include gas optimization considerations

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- **Repository**: https://github.com/apolosan/rsd
- **Documentation**: This README
- **Issues**: https://github.com/apolosan/rsd/issues

## 📞 Contact

**Author**: Apolo San  
**Email**: [Contact via GitHub]  
**GitHub**: [@apolosan](https://github.com/apolosan)

---

## 📈 Roadmap

### Current Version (1.0.0)
- ✅ Core ERC20 functionality
- ✅ Dynamic supply adjustment
- ✅ Crowdsale mechanism
- ✅ Reward system
- ✅ Comprehensive testing

### Planned Features
- 🔄 Oracle integration for external price feeds
- 🔄 Governance token mechanics
- 🔄 Liquidity mining programs
- 🔄 Cross-chain compatibility
- 🔄 Advanced staking mechanisms

---

*Built with ❤️ for the DeFi community*