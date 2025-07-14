# Contributing to Reference System for DeFi (RSD)

## Welcome Contributors! 🎉

Thank you for your interest in contributing to the RSD project. This guide will help you get started with development, testing, and contributing to the codebase.

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Development Environment Setup](#development-environment-setup)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Deployment Guide](#deployment-guide)
- [Security Considerations](#security-considerations)
- [Submit Changes](#submit-changes)
- [Getting Help](#getting-help)

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** (v12.0.0 or higher)
- **npm** or **yarn**
- **Git**
- **Truffle Framework** (`npm install -g truffle`)
- **Ganache CLI** (`npm install -g ganache-cli`)

### Quick Setup

1. **Fork and Clone the Repository**
```bash
git clone https://github.com/yourusername/rsd.git
cd rsd
```

2. **Install Dependencies**
```bash
npm install
```

3. **Create Environment Files**
```bash
# Create mnemonic file for wallet
echo "your twelve word mnemonic phrase here" > .secret

# Create environment config (optional)
cp .env.example .env
```

4. **Start Local Blockchain**
```bash
ganache-cli
```

5. **Compile and Deploy**
```bash
truffle compile
truffle migrate --network development
```

6. **Run Tests**
```bash
truffle test
```

## 🛠️ Development Environment Setup

### Recommended Tools

- **VSCode** with Solidity extension
- **Remix IDE** for contract testing
- **MetaMask** for transaction testing
- **Hardhat** (alternative to Truffle)

### Network Configuration

The project supports multiple networks:

#### Local Development
```javascript
// truffle-config.js
development: {
  host: "127.0.0.1",
  port: 8545,
  network_id: "*",
  gas: 6721975,
  gasPrice: 20000000000
}
```

#### BSC Testnet
```javascript
bsc_testnet: {
  provider: () => new HDWalletProvider(mnemonic, `https://data-seed-prebsc-1-s3.binance.org:8545`),
  network_id: 97,
  confirmations: 1,
  timeoutBlocks: 2000,
  skipDryRun: true
}
```

### Environment Variables

Create a `.env` file with:
```bash
# Network configurations
INFURA_PROJECT_ID=your_infura_project_id
BSC_TESTNET_URL=https://data-seed-prebsc-1-s3.binance.org:8545
BSC_MAINNET_URL=https://bsc-dataseed1.binance.org:443

# Contract deployment
INITIAL_SUPPLY=1459240000000000000000000
SALE_RATE=2000
CROWDSALE_DURATION=7889229

# Testing
REPORT_GAS=true
COVERAGE=true
```

## 📁 Project Structure

```
rsd/
├── contracts/                 # Smart contracts
│   └── ReferenceSystemDeFi.sol
├── migrations/               # Deployment scripts
│   ├── 1_initial_migration.js
│   └── 1613055611_reference_system_de_fi.js
├── test/                     # Test files
│   └── reference_system_defi.js
├── simulation/               # Economic simulations
│   └── rsd_simulation.js
├── logo/                     # Project assets
│   ├── rsd_color.png
│   └── ... (other logos)
├── truffle-config.js         # Truffle configuration
├── package.json             # Dependencies
├── README.md               # Project documentation
├── DOCS.md                 # API documentation
├── CONTRIBUTING.md         # This file
└── LICENSE                 # MIT License
```

## 🔄 Development Workflow

### 1. Branch Strategy

We follow a simplified Git flow:

- `main` - Production-ready code
- `develop` - Integration branch
- `feature/*` - New features
- `fix/*` - Bug fixes
- `hotfix/*` - Critical fixes

### 2. Feature Development Process

1. **Create Feature Branch**
```bash
git checkout -b feature/your-feature-name
```

2. **Develop Your Feature**
```bash
# Make your changes
# Add tests
# Update documentation
```

3. **Test Thoroughly**
```bash
truffle test
npm run simulation
```

4. **Commit Changes**
```bash
git add .
git commit -m "feat: add your feature description"
```

5. **Push and Create PR**
```bash
git push origin feature/your-feature-name
# Create pull request on GitHub
```

### 3. Commit Message Format

We use conventional commits:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding or fixing tests
- `chore`: Maintenance tasks

Examples:
```bash
feat(contract): add dynamic supply adjustment mechanism
fix(crowdsale): resolve overflow in purchase calculation
docs(readme): update installation instructions
test(rewards): add comprehensive reward distribution tests
```

## 📏 Coding Standards

### Solidity Guidelines

1. **Style Guide**
   - Follow [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html)
   - Use 4 spaces for indentation
   - Line length: 120 characters max
   - Use meaningful variable names

2. **Security Best Practices**
   - Always use SafeMath for arithmetic operations
   - Implement proper access controls
   - Validate all inputs
   - Follow checks-effects-interactions pattern
   - Use OpenZeppelin contracts when possible

3. **Code Organization**
```solidity
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

// Imports
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract YourContract is IERC20, Ownable {
    // State variables
    // Events
    // Modifiers
    // Constructor
    // External functions
    // Public functions
    // Internal functions
    // Private functions
}
```

4. **Documentation**
   - Add NatSpec comments for all public functions
   - Document complex logic
   - Include parameter descriptions

```solidity
/**
 * @notice Updates the crowdsale conversion rate
 * @dev Only callable by contract owner
 * @param rate New sale rate (tokens per ETH)
 * @return bool Success status
 */
function updateSaleRate(uint16 rate) external onlyOwner returns (bool) {
    _SALE_RATE = rate;
    return true;
}
```

### JavaScript Guidelines

1. **ES6+ Syntax**
   - Use `const` and `let` instead of `var`
   - Use arrow functions where appropriate
   - Use async/await for promises

2. **Testing Standards**
```javascript
const ReferenceSystemDeFi = artifacts.require("ReferenceSystemDeFi");
const { expect } = require("chai");

contract("ReferenceSystemDeFi", (accounts) => {
    let rsd;
    
    beforeEach(async () => {
        rsd = await ReferenceSystemDeFi.new("Test RSD", "TRSD", accounts[0]);
    });
    
    describe("Token functionality", () => {
        it("should transfer tokens correctly", async () => {
            const amount = web3.utils.toWei("100", "ether");
            await rsd.transfer(accounts[1], amount, { from: accounts[0] });
            
            const balance = await rsd.balanceOf(accounts[1]);
            expect(balance.toString()).to.equal(amount);
        });
    });
});
```

## 🧪 Testing Guidelines

### Test Structure

1. **Unit Tests** - Test individual functions
2. **Integration Tests** - Test contract interactions
3. **Gas Optimization Tests** - Verify gas efficiency
4. **Security Tests** - Test for vulnerabilities

### Test Categories

#### Contract Deployment Tests
```javascript
it("should deploy contract with correct parameters", async () => {
    const name = await rsd.name();
    const symbol = await rsd.symbol();
    const decimals = await rsd.decimals();
    
    assert.equal(name, "Reference System for DeFi");
    assert.equal(symbol, "RSD");
    assert.equal(decimals, 18);
});
```

#### Functionality Tests
```javascript
describe("Supply Adjustment Mechanism", () => {
    it("should adjust supply based on transaction volume", async () => {
        // Test implementation
    });
    
    it("should distribute rewards correctly", async () => {
        // Test implementation
    });
});
```

#### Security Tests
```javascript
describe("Access Control", () => {
    it("should only allow owner to update parameters", async () => {
        try {
            await rsd.updateSaleRate(3000, { from: accounts[1] });
            assert.fail("Should have thrown");
        } catch (error) {
            assert(error.message.includes("Ownable: caller is not the owner"));
        }
    });
});
```

### Running Tests

```bash
# Run all tests
truffle test

# Run specific test file
truffle test test/reference_system_defi.js

# Run with gas reporting
truffle test --reporter eth-gas-reporter

# Run with coverage
npm run coverage
```

### Test Data

Use consistent test data:
```javascript
const TEST_AMOUNTS = {
    SMALL: web3.utils.toWei("1", "ether"),
    MEDIUM: web3.utils.toWei("100", "ether"), 
    LARGE: web3.utils.toWei("1000", "ether")
};

const TEST_ADDRESSES = {
    ZERO: "0x0000000000000000000000000000000000000000",
    BURN: "0x000000000000000000000000000000000000dEaD"
};
```

## 🚀 Deployment Guide

### Local Deployment

1. **Start Ganache**
```bash
ganache-cli --deterministic --accounts 10 --host 0.0.0.0
```

2. **Deploy Contracts**
```bash
truffle migrate --network development
```

### Testnet Deployment

1. **Configure Network**
```bash
# Update truffle-config.js with testnet settings
# Ensure .secret file contains valid mnemonic
```

2. **Deploy to BSC Testnet**
```bash
truffle migrate --network bsc_testnet
```

3. **Verify Deployment**
```bash
truffle console --network bsc_testnet
> const rsd = await ReferenceSystemDeFi.deployed()
> await rsd.name()
> await rsd.totalSupply()
```

### Mainnet Deployment Checklist

- [ ] All tests passing
- [ ] Security audit completed
- [ ] Gas optimization verified
- [ ] Documentation updated
- [ ] Deployment parameters reviewed
- [ ] Backup deployment procedure tested

### Post-Deployment

1. **Verify Contract on Explorer**
```bash
truffle run verify ReferenceSystemDeFi --network bsc_testnet
```

2. **Initialize Contract**
```bash
# Set initial parameters
# Configure access controls
# Test functionality
```

## 🔒 Security Considerations

### Code Review Checklist

- [ ] No hardcoded private keys or secrets
- [ ] Proper access controls implemented
- [ ] Input validation on all functions
- [ ] SafeMath used for arithmetic
- [ ] Reentrancy protection where needed
- [ ] Gas optimization considered
- [ ] Event emissions for important state changes

### Common Vulnerabilities

1. **Integer Overflow/Underflow**
   - Always use SafeMath
   - Validate input ranges

2. **Reentrancy Attacks**
   - Follow checks-effects-interactions pattern
   - Use OpenZeppelin's ReentrancyGuard

3. **Access Control Issues**
   - Implement proper role-based access
   - Test all permission scenarios

4. **Front-running Protection**
   - Consider MEV implications
   - Implement appropriate delays where needed

### Security Testing

```javascript
describe("Security Tests", () => {
    it("should prevent overflow attacks", async () => {
        const maxUint256 = web3.utils.toBN(2).pow(web3.utils.toBN(256)).sub(web3.utils.toBN(1));
        
        try {
            await rsd.transfer(accounts[1], maxUint256, { from: accounts[0] });
            assert.fail("Should have reverted");
        } catch (error) {
            assert(error.message.includes("SafeMath"));
        }
    });
});
```

## 📤 Submit Changes

### Pull Request Process

1. **Pre-submission Checklist**
   - [ ] All tests pass
   - [ ] Code follows style guidelines
   - [ ] Documentation updated
   - [ ] No merge conflicts
   - [ ] Meaningful commit messages

2. **PR Description Template**
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings introduced
```

3. **Review Process**
   - At least one maintainer review required
   - All CI checks must pass
   - No unresolved discussions

### Release Process

1. **Version Bumping**
```bash
npm version patch|minor|major
git push origin main --tags
```

2. **Release Notes**
   - Document breaking changes
   - List new features
   - Include migration guide if needed

## 🆘 Getting Help

### Resources

- **Documentation**: README.md and DOCS.md
- **Issues**: [GitHub Issues](https://github.com/apolosan/rsd/issues)
- **Discussions**: [GitHub Discussions](https://github.com/apolosan/rsd/discussions)

### Community Guidelines

- Be respectful and constructive
- Search existing issues before creating new ones
- Provide detailed information when reporting bugs
- Follow the code of conduct

### Reporting Bugs

Use this template for bug reports:
```markdown
**Bug Description**
Clear description of the bug

**Steps to Reproduce**
1. Step one
2. Step two
3. Step three

**Expected Behavior**
What should happen

**Actual Behavior**
What actually happens

**Environment**
- OS: [e.g., macOS, Linux, Windows]
- Node.js version: [e.g., 14.17.0]
- Truffle version: [e.g., 5.4.6]
- Network: [e.g., development, BSC testnet]
```

### Feature Requests

```markdown
**Feature Description**
Clear description of the feature

**Use Case**
Why is this feature needed?

**Proposed Solution**
How should this feature work?

**Alternatives Considered**
Other approaches you've considered
```

## 🎉 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- GitHub contributors graph

Thank you for contributing to RSD! 🚀

---

*This contributing guide is a living document. Please suggest improvements via pull requests.*