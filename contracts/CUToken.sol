// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CUToken is ERC20 {
    constructor() ERC20("CreditUnion", "CU") {
        _mint(msg.sender, 10000*10**decimals());
    }
}