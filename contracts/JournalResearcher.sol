pragma solidity ^0.5.0;

contract JournalResearcher{
    uint public totalResearcherNum;

    struct Researcher {
        string name;
        string organization;
        address addr;
    }

    mapping (address => bool) public members;
    mapping (uint => Researcher) public memberDict;

    constructor() public{
        totalResearcherNum = 0;
    }

    function register(string memory _name, string memory _organization) public {
        require(members[msg.sender] != true, "Current user has registered");
        totalResearcherNum++;
        uint _id = totalResearcherNum;
        address _addr = msg.sender;
        members[msg.sender] = true;
        memberDict[_id] = Researcher(_name, _organization, _addr);
    }
}
