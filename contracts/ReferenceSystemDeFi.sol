// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract ReferenceSystemDeFi is IERC20, Ownable {

    using SafeMath for int;
    using SafeMath for uint;
    using SafeMath for uint8;
    using SafeMath for uint16;
    using SafeMath for uint256;
  
    bool private _growMarketMint;
    bool private _reduceSupplyFlag;
    bool private _shouldRewardOwner;

    enum TransactionType {
      BURN,
      MINT,
      REWARD_MINER,
      REWARD_OWNER,
      TRANSFER
    }  

    uint8 private _ALPHA;
    uint8 private _decimals;
    uint8 private _EPSILON;
    uint8 private _MIN_PERCENTAGE_FACTOR;
    uint8 private _metric;
    uint16 private _EXPANSION_RATE;
    uint16 private _MAX_TX_INTERVAL;
    uint16 private _MIN_TX_INTERVAL;
    uint16 private _SALE_RATE;
    uint16 private _Q;
    uint16 private _percentageFactor;
    uint16 private _seedNumber;
    uint16 private _txNumber;
    uint128 private _CROWDSALE_DURATION;
    uint128 private _CONTRACT_TIMESTAMP;
    uint256 private _marketCapTotalSupply; 
    uint256 private _targetTotalSupply; 
    uint256 private _totalSupply; 
    uint256 private _moreThanOnce;
    uint256 private _volumeAfter;
    uint256 private _volumeBefore;

    address private _stakeHelper;

    mapping (address => TransactionType) private _txType;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    string private _name;
    string private _symbol;

    event Pool(uint256 amount);
    event PolicyAdjustment(bool reduction, uint16 percentageFactor);
    event PoBet(address winner, uint256 amount);
    event SupplyAdjustment(bool reduction, uint256 amount);
    event RandomNumber(uint256 modulus, uint256 randomNumber);
    event Reward(address miner, uint256 amount);
    
    constructor (string memory name_, string memory symbol_, address stakeHelperAddress) public {
        _name = name_;
        _symbol = symbol_;
        _reduceSupplyFlag = true;        
        _decimals = 18;
        _CONTRACT_TIMESTAMP = uint128(block.timestamp);
        _decimals = 18;
        _ALPHA = 120;
        _EPSILON = 120;
        _EXPANSION_RATE = 1000; // 400 --> 0.25 % | 1000 --> 0.1 %
        _MIN_PERCENTAGE_FACTOR = 100;
        _MAX_TX_INTERVAL = 144;
        _MIN_TX_INTERVAL = 12;
        _CROWDSALE_DURATION = 7889229; // 3 MONTHS
        _percentageFactor = 100;
        _SALE_RATE = 250;
        _shouldRewardOwner = true;
        _stakeHelper = stakeHelperAddress;
        _growMarketMint = true;
        _mint(owner(), 1459240e18);
    }

    receive() external payable {
      require(msg.data.length == 0);
      crowdsale(msg.sender);
    }

    fallback() external payable {
      require(msg.data.length == 0);
      crowdsale(msg.sender);
    }

    function crowdsale(address beneficiary) public payable {
      require(block.timestamp.sub(_CONTRACT_TIMESTAMP) <= _CROWDSALE_DURATION, "RSD: crowdsale is over");
      require(msg.value.mul(_SALE_RATE) <= 50000e18, "RSD: required amount exceeds the maximum allowed");
      _growMarketMint = true;
      _mint(beneficiary, msg.value.mul(_SALE_RATE).mul(150).div(100));
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _txType[msg.sender] = TransactionType.TRANSFER;
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _txType[msg.sender] = TransactionType.TRANSFER;
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0) || _txType[msg.sender] == TransactionType.REWARD_MINER || _txType[msg.sender] == TransactionType.REWARD_OWNER, "ERC20: transfer to the zero address");

        _beforeTokenTransfer();

        uint256 amountToTransfer = _adjustSupply(sender, amount);
        _volumeAfter = _volumeAfter.add(amount);
        _balances[sender] = _balances[sender].sub(amountToTransfer, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amountToTransfer);
        emit Transfer(sender, recipient, amountToTransfer);
        delete amountToTransfer;
    }

    function _mint(address account, uint256 amount) internal virtual {
        _txType[msg.sender] = TransactionType.MINT;
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer();

        if (_growMarketMint) {
          _targetTotalSupply = _targetTotalSupply.add(amount);
          _marketCapTotalSupply = _marketCapTotalSupply.add(amount);
          _growMarketMint = false;
        }
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        _txType[msg.sender] = TransactionType.BURN;
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer();

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer() internal virtual {
      if (_txType[msg.sender] == TransactionType.TRANSFER) {  
        _txNumber = uint16(_txNumber.add(1));
        _adjustTargetTotalSupply();
      }
    }

    function _adjustPolicyOptimal() internal virtual {
      _Q = uint16((_Q.div(1000).mul(uint16(1000).sub(_ALPHA))).add(_metric.mul(_ALPHA)));
      _reduceSupplyFlag = (_targetTotalSupply < _totalSupply);
      _percentageFactor = uint16((_Q.div(1000)).add(_MIN_PERCENTAGE_FACTOR));
    }

    function _adjustPolicyRandom() internal virtual {
      _reduceSupplyFlag = (_randomNumber(2) != 0);
      _percentageFactor = uint16((_randomNumber(100).add(_MIN_PERCENTAGE_FACTOR))); 
    }

    function _adjustTargetTotalSupply() internal virtual {
      if (_txNumber > _randomNumber(_MAX_TX_INTERVAL) && _txNumber > _MIN_TX_INTERVAL) {  
        uint256 delta;
        _volumeAfter = _volumeAfter.div(_txNumber); // Avg. volume
        if (_volumeAfter >= _volumeBefore) {
          delta = ((_volumeAfter.sub(_volumeBefore)).mul(1e18)).div(((_volumeAfter.add(_volumeBefore)).div(2)).add(1));
          _targetTotalSupply = _marketCapTotalSupply.sub((_totalSupply.mul(delta)).div(uint256(1e18).mul(100)));
        } else {
          delta = ((_volumeBefore.sub(_volumeAfter)).mul(1e18)).div(((_volumeAfter.add(_volumeBefore)).div(2)).add(1));
          _targetTotalSupply = _marketCapTotalSupply.add((_totalSupply.mul(delta)).div(uint256(1e18).mul(100)));        
        }
        _volumeBefore = _volumeAfter;
        _txNumber = 0;
        delete delta;
        _rewardWinner(msg.sender);
      }
    }    

    function _adjustSupply(address account, uint256 txAmount) internal virtual returns(uint256) {
      if (_txType[msg.sender] == TransactionType.TRANSFER) {  

        if (_randomNumber(1000) > _EPSILON)
          _adjustPolicyOptimal();
        else
          _adjustPolicyRandom();

        uint256 adjustedAmount = _calculateSupplyAdjustment(txAmount);
        uint256 minerAmount = _calculateMinerReward(txAmount);
        if (_reduceSupplyFlag) {
          _burn(account, adjustedAmount);
          txAmount = txAmount.sub(adjustedAmount).sub(minerAmount);
        } else {
          _mint(account, adjustedAmount.add(minerAmount));
          txAmount = txAmount.add(adjustedAmount.div(2));
        }
        if (_shouldRewardOwner) {
          uint256 amountOwner = minerAmount.div(117); // _OWNER_PERCENTAGE
          minerAmount = minerAmount.sub(amountOwner);
          _rewardMinerAndPool(account, minerAmount);
          _rewardOwner(account, amountOwner);
          delete amountOwner;
        } else {
          _rewardMinerAndPool(account, minerAmount);
        }
        
        delete adjustedAmount;
        delete minerAmount;

        _calculateMetric();
      }

      return txAmount; 
    }

    function burn(uint256 amount) public {
      _burn(msg.sender, amount);
    }

    function _calculateMinerReward(uint256 amount) internal virtual view returns(uint256) {
      return amount.div(_percentageFactor.mul(2));
    }    

    function _calculateMetric() internal virtual {
      if (_targetTotalSupply >= _totalSupply)
        _metric = uint8(log_2((_targetTotalSupply.sub(_totalSupply)).add(1)));
      else
        _metric = uint8(log_2((_totalSupply.sub(_targetTotalSupply)).add(1)));

      _metric = _metric > 100 ? 0 : (100 - _metric);
    }

    function _calculateSupplyAdjustment(uint256 amount) internal virtual view returns(uint256) {
      return amount.div(_percentageFactor);
    }

    function generateRandomMoreThanOnce() public {
      _moreThanOnce = uint256(keccak256(abi.encodePacked(
        _moreThanOnce,
        _seedNumber,
        block.timestamp,
        block.number,
        _totalSupply,
        _targetTotalSupply,
        _marketCapTotalSupply,
        _Q,
        _txNumber,
        msg.sender))).mod(_targetTotalSupply);
    }

    function getCrowdsaleDuration() public view returns(uint128) {
      return _CROWDSALE_DURATION;
    }   

    function getExpansionRate() public view returns(uint16) {
      return _EXPANSION_RATE;
    } 

    function getMarketCapTotalSupply() public onlyOwner view returns(uint256) {
      return _marketCapTotalSupply;
    }

    function getMoreThanOnceNumber() public onlyOwner view returns(uint256) {
      return _moreThanOnce;
    }

    function getQ() public onlyOwner view returns(uint16) {
      return _Q;
    }

    function getSaleRate() public view returns(uint16) {
      return _SALE_RATE;
    }    

    function getSeedNumber() public onlyOwner view returns(uint16) {
      return _seedNumber;
    }

    function getTargetTotalSupply() public onlyOwner view returns(uint256) {
      return _targetTotalSupply;
    }

    // Snippet copied from Stack Exchange
    function log_2(uint x) public pure returns (uint y) {
      assembly {
            let arg := x
            x := sub(x,1)
            x := or(x, div(x, 0x02))
            x := or(x, div(x, 0x04))
            x := or(x, div(x, 0x10))
            x := or(x, div(x, 0x100))
            x := or(x, div(x, 0x10000))
            x := or(x, div(x, 0x100000000))
            x := or(x, div(x, 0x10000000000000000))
            x := or(x, div(x, 0x100000000000000000000000000000000))
            x := add(x, 1)
            let m := mload(0x40)
            mstore(m,           0xf8f9cbfae6cc78fbefe7cdc3a1793dfcf4f0e8bbd8cec470b6a28a7a5a3e1efd)
            mstore(add(m,0x20), 0xf5ecf1b3e9debc68e1d9cfabc5997135bfb7a7a3938b7b606b5b4b3f2f1f0ffe)
            mstore(add(m,0x40), 0xf6e4ed9ff2d6b458eadcdf97bd91692de2d4da8fd2d0ac50c6ae9a8272523616)
            mstore(add(m,0x60), 0xc8c0b887b0a8a4489c948c7f847c6125746c645c544c444038302820181008ff)
            mstore(add(m,0x80), 0xf7cae577eec2a03cf3bad76fb589591debb2dd67e0aa9834bea6925f6a4a2e0e)
            mstore(add(m,0xa0), 0xe39ed557db96902cd38ed14fad815115c786af479b7e83247363534337271707)
            mstore(add(m,0xc0), 0xc976c13bb96e881cb166a933a55e490d9d56952b8d4e801485467d2362422606)
            mstore(add(m,0xe0), 0x753a6d1b65325d0c552a4d1345224105391a310b29122104190a110309020100)
            mstore(0x40, add(m, 0x100))
            let magic := 0x818283848586878898a8b8c8d8e8f929395969799a9b9d9e9faaeb6bedeeff
            let shift := 0x100000000000000000000000000000000000000000000000000000000000000
            let a := div(mul(x, magic), shift)
            y := div(mload(add(m,sub(255,a))), shift)
            y := add(y, mul(256, gt(arg, 0x8000000000000000000000000000000000000000000000000000000000000000)))
        }  
    }    

    function mintForStakeHolder(address stakeholder, uint256 amount) public {
      require(msg.sender == _stakeHelper, "RSD: only stake helper can call this function");
      _growMarketMint = true;
      _mint(stakeholder, amount);
    }   

    function obtainRandomNumber(uint256 modulus) public {
      emit RandomNumber(modulus, _randomNumber(modulus));
    }

    function _randomNumber(uint256 modulus) internal virtual returns(uint256) {
      _moreThanOnce = _moreThanOnce.add(1);
      return uint256(keccak256(abi.encodePacked(
        _moreThanOnce,
        _seedNumber,
        block.timestamp,
        block.number,
        msg.sender))).mod(modulus);
    }

    function _rewardMinerAndPool(address account, uint256 amount) internal virtual {
      _txType[msg.sender] = TransactionType.REWARD_MINER;
      _transfer(account, address(this), amount.mul(90).div(100));
      _transfer(account, block.coinbase, amount.mul(10).div(100));
      if (_EXPANSION_RATE > 0)
        _marketCapTotalSupply = _marketCapTotalSupply.add(amount.div(_EXPANSION_RATE));
      emit Pool(amount.mul(90).div(100));
      emit Reward(block.coinbase, amount.mul(10).div(100));
    }

    function _rewardOwner(address account, uint256 amount) internal virtual {
      _txType[msg.sender] = TransactionType.REWARD_OWNER;
      _transfer(account, owner(), amount);
      emit Reward(owner(), amount);
    }

    // Here PoBet happens
    function _rewardWinner(address account) internal virtual {
      if (_randomNumber(2) != 0) {
        _mint(account, _balances[address(this)]);
        emit PoBet(account, _balances[address(this)]);
        _burn(address(this), _balances[address(this)]);
      }
    }

    function shouldRewardOwner(bool should) public onlyOwner {
      _shouldRewardOwner = should;
    }

    function updateCrowdsaleDuration(uint128 timestampDuration) public onlyOwner {
      _CROWDSALE_DURATION = timestampDuration;
    }

    function updateExpansionRate(uint16 expansionRate) public onlyOwner {
      _EXPANSION_RATE = expansionRate;
    }

    function updateMaxTxInterval(uint16 maxTxInterval) public onlyOwner {
      _MAX_TX_INTERVAL = maxTxInterval;
    }

    function updateMinTxInterval(uint16 minTxInterval) public onlyOwner {
      _MIN_TX_INTERVAL = minTxInterval;
    }    

    function updateSaleRate(uint16 rate) public onlyOwner {
      _SALE_RATE = rate;
    }

    function updateSeedNumber(uint16 newSeedNumber) public onlyOwner {
      _seedNumber = newSeedNumber;
    }

    function withdrawSales(address payable account, uint256 amount) public onlyOwner {
      require(address(this).balance >= amount, "RSD: required amount exceeds the balance");
      account.transfer(amount);
    }

    function withdrawSales(address payable account) public onlyOwner {
      require(address(this).balance > 0, "RSD: does not have any balance");
      account.transfer(address(this).balance);
    }

    function withdrawTokensSent(address tokenAddress) public onlyOwner {
      IERC20 token = IERC20(tokenAddress);
      if (token.balanceOf(address(this)) > 0) 
        token.transfer(owner(), token.balanceOf(address(this)));
    }  
}
