// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

import "./CUToken.sol";

contract Union {
    // 컨트랙 삭제하는 코드도 넣기
    address public factory;
    ERC20 public token;

    int public people;
    int public amount;
    string public name;
    int public periodicPayment;
    int public round;
    uint public count;
    uint public initDate;
    uint public dueDate;
    bool public isActivate;

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

    constructor() {
        factory = msg.sender;
    }

    function balanceOf() public view returns(uint) {
        return address(this).balance;
    }

    function initialize(address _token, int _people, int _amount, string memory _name) external {
        require(msg.sender == factory, "Not Authorized");
        require(_amount >= 10**18, "minimum amount: 1 CU");
        require(_people >= 3 && _people <= 13 && _people%2 == 1, "minimum people: 3 & max people: 13, only odd number");
        token = ERC20(_token);
        people = _people;
        amount = _amount;
        name = _name;
        periodicPayment = _amount / _people;
        round = 1;
        count = 0;
        isActivate = true;
    }

    function getOrder(address participant) public view returns (int order) {
        for (int i = 0; i < people; i++) {
            if (participants[i].joiner == participant) {
                return participants[i].order;
            }
        }
        return 0;
    }

    function participate(int order, address cont) public payable {
        require(order > 0 &&  order <= people, "Full Union");
        require(participants[order - 1].joiner == address(0), "Already exist order");
        require(isParticipate[msg.sender] == false, "Already participate");
        participants[order - 1] = Participant(
            payable(msg.sender),
            false,
            2 * (order - 1) - (people - 1),
            order,
            false
        );
        isParticipate[msg.sender] = true;
        (bool success, bytes memory data) = address(cont).call(abi.encodeWithSignature("add(address,address)", address(msg.sender), address(this)));
        emit Add(success, data);
        
        // collateral_Deposit
        require(msg.sender == participants[order - 1].joiner, "participating address must matches with order");
        require(participants[order - 1].hasCollateral == false, "Already submit collateral");
        require(msg.value == uint(amount / 10**4), "ether's value is must equal CU amount");
        participants[order - 1].hasCollateral = true;
    }

    function CUdeposit(address cont) public {
        int order = getOrder(msg.sender);
        if (round > 1) {
            if (block.timestamp > dueDate) {
                _collateralSlash(cont);
                participants[order - 1].isDeposit = true;
                count++;
                if (count == uint(people)) {
                    initDate = block.timestamp;
                    // dueDate = initDate + 2592000;
                    dueDate = initDate + 180;
                    _CUwithdrawl();
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
            initDate = block.timestamp;
            // dueDate = initDate + 2592000;
            dueDate = initDate + 180;
            _CUwithdrawl();
        }
    }

    function _collateralWithdrawl() private {
        payable(msg.sender).transfer(uint(periodicPayment) / 10**4);
    }

    function _collateralSlash(address cont) private {
        (bool success, bytes memory data) = address(cont).call{value: uint(periodicPayment) / 10**4}(abi.encodeWithSignature("buy()"));
        emit Slash(success, data);
    }

    function _CUwithdrawl() private {
        token.transfer(participants[round - 1].joiner, uint(amount * (100 + participants[round - 1].interest) / 100));
        round++;
        count = 0;
        for (int i = 0; i < people; i++) {
            participants[i].isDeposit = false;
        }
        if ((round - 1) == people) {
            isActivate = false;
            // selfdestruct(payable(0x0e3E900b7ABB2Ccd555E4aDA96A33090dD9b5517));
        }
    }
}