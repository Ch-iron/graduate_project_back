// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

contract UserParticipationList{
    mapping(address => address[]) public getJoinUnion;
    constructor() {}

    function add(address user, address union) external {
        getJoinUnion[user].push(union);
    }

    function get(address user) public view returns(address[] memory union) {
        return getJoinUnion[user];
    }

    function exit(address user, address union) external {
        uint stopPoint;
        for (uint i = 0; i < getJoinUnion[user].length; i++) {
            if (getJoinUnion[user][i] == union) {
                stopPoint = i;
                break;
            }
        }
        for (uint i = stopPoint; i < getJoinUnion[user].length - 1; i++) {
            getJoinUnion[user][i] = getJoinUnion[user][i + 1];
        }
        getJoinUnion[user].pop();
    }
}