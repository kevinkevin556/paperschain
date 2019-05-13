pragma solidity ^0.5.0;

import "./JournalResearcher.sol";

contract Journal {
    uint public totalPaperNum;

    struct Review {
        bool accept;
        string comment;
    }

    struct Paper {
        string title;
        uint year;
        string paperAbstract;
        bool passReviewed;
        uint reviewedTimes;
        mapping(uint => Review) reviewLog;
    }

    mapping(uint => Paper) public paperDict;

    constructor() public {
        totalPaperNum = 0;
    }


    function uploadPaper(string memory _title, uint _year, string memory _paperAbstract) public {
        totalPaperNum++;
        Paper memory newPaper = Paper({
            title: _title,
            year: _year,
            paperAbstract: _paperAbstract,
            passReviewed: false,
            reviewedTimes: 0
        });
        paperDict[totalPaperNum] = newPaper;
    }

    function reviewPaper(uint _paperId, bool _accept, string memory _comment) public {
        require(paperDict[_paperId].passReviewed == false, "The paper has passed review.");

        Paper storage reviewedWork = paperDict[_paperId];
        reviewedWork.reviewedTimes++;
        reviewedWork.passReviewed = _accept;
        reviewedWork.reviewLog[reviewedWork.reviewedTimes] = Review(_accept, _comment);
    }
}
