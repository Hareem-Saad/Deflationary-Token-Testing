// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Deflationary is ERC20, Ownable {

    event deflation(address from, uint transferAmount, uint burnAmount);

    // % that will be burned everytime on transaction and used for deflation
    uint8 private _burnRate;

    constructor(string memory name_, string memory symbol_, uint8 burnRate, uint256 supply_) ERC20(name_,symbol_) {
        _burnRate = burnRate;
        _mint(msg.sender, supply_*(10**(decimals())));
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        
        //check for enough balance
        require(balanceOf(msg.sender) >= amount, "Not enough tokens to transfer");

        //get burn amount
        uint256 burnAmount = calculateBurnRate(amount);

        //transfer amount - burnAmount
        _transfer(owner, to, amount-burnAmount);

        //burn burnAmount
        _burn(owner, burnAmount);

        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        address spender = _msgSender();

        //check for enough balance
        require(balanceOf(from) >= amount, "Not enough tokens to transfer");

        //get burn amount
        uint256 burnAmount = calculateBurnRate(amount);

        //spend allowance
        _spendAllowance(from, spender, amount - burnAmount);
        
        //transfer amount - burnAmount
        _transfer(from, to, amount - burnAmount);

        //burn burnAmount from from's address
        _burn(from, burnAmount);

        return true;
    }
    
    //calculate the fee that will be burned
    function calculateBurnRate(uint256 amount) public view returns(uint256){
        return amount * _burnRate / 100;
    }
    
    //setting fee percent after contract is deployed
    function setBurnRate(uint8 burnRate_) public onlyOwner returns(uint8){
        require(burnRate_ > 0,"Fee cannot be 0 percent");
        _burnRate = burnRate_;
        return _burnRate;
    }

    //get fee data
    function getBurnRate() public view onlyOwner returns(uint8){
        return _burnRate;
    }
    
}