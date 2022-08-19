// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

import "./Union.sol";

contract UnionFactory {
    mapping(string => address) public getUnion;
    address[] public allUnions;

    event UnionCreated(int people, int price, string name);

    constructor() {}

    function getAllUnions() public view returns (address[] memory) {
        return allUnions;
    }

    function createUnion(address token, int people, int amount, string memory name, address swap_cont, address list_cont, address factory_cont) external returns (address) {
        require(getUnion[name] == address(0), "UNION_EXISTS");
        Union union = new Union();
        // bytes memory bytecode = type(Union).creationCode;
        // bytes32 salt = keccak256(abi.encodePacked(people, amount, name));
        // assembly {
        //     union := create2(0, add(bytecode, 32), mload(bytecode), salt)
        // }
        union.initialize(token, people, amount, name, swap_cont, list_cont, factory_cont);
        getUnion[name] = address(union);
        allUnions.push(address(union));
        emit UnionCreated(people, amount, name);
        return address(union);
    }

    function deleteAllUnion(string memory name) external {
        uint stopPoint;
        for (uint i = 0; i < allUnions.length; i++) {
            if (address(allUnions[i]) == getUnion[name]) {
                stopPoint = i;
                break;
            }
        }
        for (uint i = stopPoint; i < allUnions.length - 1; i++) {
            allUnions[i] = allUnions[i + 1];
        }
        allUnions.pop();
    }

    function deleteGetUnion(string memory name) external {
        delete getUnion[name];
    }
}