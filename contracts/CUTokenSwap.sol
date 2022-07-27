// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CUTokenSwap {
    ERC20 public eth;
    address private system;
    uint public rate;

    constructor(address _eth, address _system, uint _rate) {
        eth = ERC20(_eth);
        system = _system;
        rate = _rate;
    }

    function swap(address _user, address _token, uint _amount, bool _ETHtoCU) public {
        ERC20 token;
        require(_amount >= 10**14, "minimum amount: 0.0001");

        token = ERC20(_token);
        uint _ethAmount = _amount / rate;

        require(msg.sender == _user, "Not authorized");
        
        if (_ETHtoCU == true) {
            require(eth.allowance(_user, address(this)) >= _ethAmount, "eth allowance too low");
            require(token.allowance(system, address(this)) >= _amount, "CU allowance too low");

            _safeTransferFrom(eth, _user, system, _ethAmount);
            _safeTransferFrom(token, system, _user, _amount);
        } else {
            require(token.allowance(_user, address(this)) >= _amount, "CU allowance too low");
            require(eth.allowance(system, address(this)) >= _ethAmount, "eth allowance too low");

            _safeTransferFrom(token, _user, system, _amount);
            _safeTransferFrom(eth, system, _user, _ethAmount);
        }
    }

    function _safeTransferFrom(ERC20 whichToken, address sender, address recipient, uint amount) private {
        bool sent = whichToken.transferFrom(sender, recipient, amount);
        require(sent, "Token transfer failed");
    }
}