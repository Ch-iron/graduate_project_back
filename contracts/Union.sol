// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

import "./CUToken.sol";

contract Union {
    address public factory;
    ERC20 public token;
    address public swapCont;
    address public listCont;
    address public factoryCont;

    int public people;
    int public amount;
    string public name;
    int public periodicPayment;
    int public round;
    uint public count;
    uint public initDate;
    uint public dueDate;
    bool public isActivate;
    bool public isFull;

    struct Participant {
        address payable joiner;
        bool hasCollateral;
        int interest;
        int order;
        bool isDeposit;
    }

    mapping (int => Participant) public participants;
    mapping (address => bool) public isParticipate;
    
    event Add(bool success, bytes data);
    event Slash(bool success, bytes data);
    event Deposit(address indexed sender, uint amount);
    event Withdrawl(address indexed receiver, uint amount);
    event Finish(bool success, bytes data);

    constructor() {
        factory = msg.sender;
    }

    function balanceOf() public view returns(uint) {
        return address(this).balance;
    }

    function initialize(address _token, int _people, int _amount, string memory _name, address _swapCont, address _listCont, address _factoryCont) external {
        require(msg.sender == factory, "Not Authorized");
        require(_amount >= 10**18, "minimum amount: 1 CU");
        require(_people >= 3 && _people <= 13 && _people%2 == 1, "minimum people: 3 & max people: 13, only odd number");
        token = ERC20(_token);
        swapCont = _swapCont;
        listCont = _listCont;
        factoryCont = _factoryCont;
        people = _people;
        amount = _amount;
        name = _name;
        periodicPayment = _amount / _people;
        round = 1;
        count = 0;
        isActivate = true;
        isFull = false;
    }

    function getOrder(address participant) public view returns (int order) {
        for (int i = 0; i < people; i++) {
            if (participants[i].joiner == participant) {
                return participants[i].order;
            }
        }
        return 0;
    }

    function getUnionOrder() public view returns (uint[] memory){
        uint[] memory unionorder = new uint[](uint(people));
        for (int i = 0; i < people; i++) {
            if (participants[i].joiner != address(0)) {
                unionorder[uint(i)] = 1;
            }
        }
        return unionorder;
    }

    function participate(int order) public payable {
        require(order > 0 &&  order <= people, "Order must bigger than 0 and less than max people");
        require(participants[order - 1].joiner == address(0), "Already exist order");
        require(isParticipate[msg.sender] == false, "Already participate");
        require(isFull == false, "Full Union");
        participants[order - 1] = Participant(
            payable(msg.sender),
            false,
            2 * (order - 1) - (people - 1),
            order,
            false
        );
        isParticipate[msg.sender] = true;
        (bool success, bytes memory data) = address(listCont).call(abi.encodeWithSignature("add(address,address)", address(msg.sender), address(this)));
        emit Add(success, data);
        
        // collateral_Deposit
        require(msg.sender == participants[order - 1].joiner, "participating address must matches with order");
        require(participants[order - 1].hasCollateral == false, "Already submit collateral");
        require(msg.value == uint(amount / 10**4), "ether's value is must equal CU amount");
        participants[order - 1].hasCollateral = true;
    }

    function CUDeposit() public {
        int order = getOrder(msg.sender);
        if (round > 1) {
            if (block.timestamp > dueDate) {
                _collateralSlash();
                participants[order - 1].isDeposit = true;
                count++;
                if (count == uint(people)) {
                    initDate = block.timestamp;
                    // dueDate = initDate + 2592000;
                    dueDate = initDate + 180;
                    _CUWithdrawl();
                }
            }
            else {
                // require(block.timestamp <= dueDate && block.timestamp >= (dueDate - 86400), "You can deposit exact period");
                require(block.timestamp <= dueDate && block.timestamp >= (dueDate - 120), "You can deposit exact period");
                _CUDeposit(order);
            }
        } else if (round == 1) {
            _CUDeposit(order);
        }
    }

    function CUReceive() public {
        require(participants[round - 1].joiner == msg.sender, "Not your turn");
        require(block.timestamp > dueDate, "Yet receive CU");
        for (int i = 0; i < people; i++) {
            if (participants[i].isDeposit == false) {
                _collateralSlash();
                participants[i].isDeposit = true;
                count++;
                if (count == uint(people)) {
                    initDate = block.timestamp;
                    // dueDate = initDate + 2592000;
                    dueDate = initDate + 180;
                    _CUWithdrawl();
                }
            }
        }
    }

    function _CUDeposit(int order) private {
        require(participants[order - 1].hasCollateral == true, "Please deposit collateral first");
        require(participants[order - 1].isDeposit == false, "You already deposit in this round");
        uint allowance = token.allowance(msg.sender, address(this));
        require(allowance >= uint(periodicPayment), "Check the token allowance");
        token.transferFrom(msg.sender, address(this), uint(periodicPayment));
        _collateralWithdrawl();
        participants[order - 1].isDeposit = true;
        count++;
        if (count == uint(people)) {
            isFull = true;
            initDate = block.timestamp;
            // dueDate = initDate + 2592000;
            dueDate = initDate + 180;
            _CUWithdrawl();
        }
    }

    function _collateralWithdrawl() private {
        payable(msg.sender).transfer(uint(periodicPayment) / 10**4);
    }

    function _collateralSlash() private {
        (bool success, bytes memory data) = address(swapCont).call{value: uint(periodicPayment) / 10**4}(abi.encodeWithSignature("buy()"));
        emit Slash(success, data);
    }

    function _CUWithdrawl() private {
        token.transfer(participants[round - 1].joiner, uint(amount * (100 + participants[round - 1].interest) / 100));
        round++;
        count = 0;
        for (int i = 0; i < people; i++) {
            participants[i].isDeposit = false;
        }
        if ((round - 1) == people) {
            isActivate = false;
            (bool success, bytes memory data) = address(factoryCont).call(abi.encodeWithSignature("deleteUnion(string)", name));
            emit Finish(success, data);
            // selfdestruct(payable(0x0e3E900b7ABB2Ccd555E4aDA96A33090dD9b5517));
        }
    }
}