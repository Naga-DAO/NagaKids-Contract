// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract testSend {

    function sendTo(address payable _to) public payable {
        (bool status,) = _to.call{value: msg.value }("");
        require(status);
    }

}