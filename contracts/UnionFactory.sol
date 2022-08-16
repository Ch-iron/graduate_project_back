// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

import "./Union.sol";

contract UnionFactory {
    mapping(string => address) public getUnion;
    address[] public allUnions;

    event UnionCreated(int people, int price, string name);

    constructor() {}

    function createUnion(address token, int people, int amount, string memory name) external returns (address union) {
        require(getUnion[name] == address(0), "UNION_EXISTS");
        // Union union = new Union();
        bytes memory bytecode = type(Union).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(people, amount, name));
        assembly {
            union := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        Union(union).initialize(token, people, amount, name);
        getUnion[name] = address(union);
        allUnions.push(union);
        emit UnionCreated(people, amount, name);
    }
}