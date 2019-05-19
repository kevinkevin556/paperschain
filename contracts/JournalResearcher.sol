pragma solidity ^0.5.0;

contract JournalResearcher{
    uint public totalResearcherNum;

    struct Researcher {
        string name;
        string status;
        string organization;
        string email;
        uint published;
        mapping (uint => uint) papersId;
    }

    mapping (string => uint) emailId; 
    mapping (address => uint) public addressId;
    mapping (uint => Researcher) public idMember;

    constructor() public{
        totalResearcherNum = 0;
    }

    function register(string memory _name, string memory _status, string memory _org, string memory _email) public {
        require(addressId[msg.sender] == 0, "Current user has registered");
        require(emailId[_email] == 0, "Current email has registered");
        totalResearcherNum++;
        uint _id = totalResearcherNum;  
        addressId[msg.sender] = _id;
        emailId[_email] = _id;
        idMember[_id] = Researcher({
            name: _name,
            status: _status,
            organization: _org,
            email: _email,
            published: 0
        });
    }
    
    function getPublishedNum(address _addr) public returns(uint){
        return idMember[addressId[_addr]].published;
    }

    function getPublishedId(address _addr, uint i) public returns(uint){
        return idMember[addressId[_addr]].papersId[i];
    }

    function setPublishedID(address _addr, uint id) public {
        idMember[addressId[_addr]].published++;
        uint paperId = idMember[addressId[_addr]].published;
        idMember[addressId[_addr]].papersId[paperId] = id;
    }
}
