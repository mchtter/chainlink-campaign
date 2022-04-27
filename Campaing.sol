// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Campaing {
    address public owner;
    string public name;
    string public description;
    uint public minContribution;
    uint public contribitorCount;

    Request[] public requests;

    mapping(address => bool) public contributor;

    struct Request {
        string description;
        uint value;
        address recipient;
        bool completed;
        uint approversCount;
        mapping(address => bool) approvers;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor(string memory _name, string memory _description, uint _minContribution) {
        name = _name;
        description = _description;
        minContribution = _minContribution;
        owner = msg.sender;
    }

    function contribute() public payable {
        require(msg.value >= minContribution, "Cok az yolladin daha cok para gonder.");
        require(contributor[msg.sender] == false, "Zaten yolladiginiz para var.");
        contributor[msg.sender] = true;
        contribitorCount++;
    }

    function createRequest(string calldata _description, uint _value, address _recipient) public onlyOwner {
        Request storage newRequest = requests.push();
        newRequest.description = _description;
        newRequest.value = _value;
        newRequest.recipient = _recipient;
        newRequest.completed = false;
        newRequest.approversCount = 0;
    }

    function approveRequest (uint _index) public {
        require(contributor[msg.sender], "Not funder");
        Request storage request = requests[_index];
        require(request.approvers[msg.sender] == false && request.completed == false, "Already approved");
        request.approvers[msg.sender] = true;
        request.approversCount++;
    }

    function finalizeRequest (uint _index) public onlyOwner {
        Request storage completedRequest = requests[_index];
        require(completedRequest.completed == false, "Already completed");
        require(completedRequest.approversCount > contribitorCount / 2, "Not enough approvers");
        completedRequest.completed = true;

        payable(completedRequest.recipient).transfer(completedRequest.value);
    }
}