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

    /**
     * @notice allows users to transfer from someone their account
     * on each trasaction some amount of tokens are burned
     * 
     * @param to address to which you want to transfer
     * @param amount amount of tokens you want to transfer
     *
     * - `to` cannot be the zero address.
     * - `msg.sender` must have a balance of at least `amount`.
     */
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

    /**
     * @notice allows users to transfer from someone else's account given that they have an approval to do so
     * on each trasaction some amount of tokens are burned
     * 
     * @param from address from which you want to transfer
     * @param to address to which you want to transfer
     * @param amount amount of tokens you want to transfer
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
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
    
    /**
     * @notice calculate the amount that will be burned
     * 
     * @param amount amount of tokens you want to transfer
     */
    function calculateBurnRate(uint256 amount) public view returns(uint256){
        return amount * _burnRate / 100;
    }
    
    /**
     * @notice allows owner to set burnRate
     * 
     * @param burnRate_ percentage of tokens you want to burn on each trasaction
     * 
     * - `burnRate_` must be lower than 50%
     */
    function setBurnRate(uint8 burnRate_) public onlyOwner returns(uint8){
        require(burnRate_ < 50,"Fee cannot be greater than 50 percent");
        _burnRate = burnRate_;
        return _burnRate;
    }

    /**
     * @notice allows owner to view burnRate
     */
    function getBurnRate() public view onlyOwner returns(uint8){
        return _burnRate;
    }
    
}