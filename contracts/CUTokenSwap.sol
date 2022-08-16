// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./CUToken.sol";

contract CUTokenSwap {
    ERC20 public token;
    uint _balance = address(this).balance;

    event Bought(uint256 amount);
    event Sold(uint256 amount);

    constructor(address _token) {
        token = ERC20(_token);
    }

    receive() external payable {}

    function balanceOf() public view returns(uint) {
        return address(this).balance;
    }

    // 0.00000001ETH = 0.0001CU
    function buy() payable public {
        uint256 amountTobuy = msg.value;
        uint256 dexBalance = token.balanceOf(address(this));
        require(amountTobuy >= 10**10, "minimum amount: 0.00000001 ETH");
        require(amountTobuy <= dexBalance, "Not enough tokens in the reserve");
        token.transfer(msg.sender, amountTobuy * 10**4);
        emit Bought(amountTobuy);
    }

    function sell(uint256 amount) public {
        require(amount >= 10**14, "minimum amount: 0.0001 CU");
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        token.transferFrom(msg.sender, address(this), amount);
        payable(msg.sender).transfer(amount / 10**4);
        emit Sold(amount);
    }
}