pragma solidity ^0.5.0;

contract Journal {
    uint public paperIndex;
    uint public researcherIndex;
    uint public reviewIndex;
    
    struct Researcher {
        uint id;
        string name;
        string organization;
        address payable addr;
        uint numPaperPublished;
        uint numPaperReviewed;
        uint numRefusal;
    }

    struct Review {
        bool accept;
        string comment;
        uint reviewerId;
    }

    struct Paper {
        uint id;
        string title;
        uint year;
        uint authorId;
        string abstracts;
        uint numCitations;
        bool passReviewed;
        uint numReview;
        uint[] reviewHistory;   
    }
    

    mapping(uint => Researcher) researcherDict;
    mapping(uint => Paper) paperDict;
    mapping(uint => Review) reviewDict;
   
    event PaperDownload (
        uint paperId
    ); 

    constructor() public {
        paperIndex = 0;
        researcherIndex = 0;
        reviewIndex = 0;
    }

    function registrateResearcher(string memory _name, string memory _organization) public returns(uint){
        researcherIndex++;
        address payable owner = msg.sender;
        Researcher memory researcher = Researcher(researcherIndex, _name, _organization, owner, uint(0), uint(0), uint(0));
        researcherDict[researcherIndex] = researcher;
        return(researcherIndex);
    }

    function uploadPaper(string memory _title, uint _year, uint _authorId, string memory _abstract) public {
        paperIndex++;
        uint[] memory review;
        review[0] = 0;
        Paper memory paper = Paper(paperIndex, _title, _year, _authorId, _abstract, uint(0), false, 0, review);
        paperDict[paperIndex] = paper;
    }
    
    function purchasePaper(uint _paperId) public payable{
        Paper memory paper = paperDict[_paperId];
        Researcher memory author = researcherDict[paper.authorId];
        uint price = paper.numCitations * (author.numPaperPublished + author.numPaperReviewed - author.numRefusal);

        require(paper.passReviewed == true);
        require(msg.value >= price);
        author.addr.transfer(price);
        emit PaperDownload(_paperId);
    }  

    function reviewPaper(uint _reviewerId, uint _paperId, bool _accept, string memory _comment) public {
        Paper memory paper = paperDict[_paperId];

        require(paper.passReviewed == false);
        
        reviewIndex++;
        paper.numReview++;
        reviewDict[reviewIndex] = Review(_accept, _comment, _reviewerId);
        paper.reviewHistory[paper.numReview] = reviewIndex;
        
    }


    // Author only 
    function readWrittenPaper(uint _paperId) public {
        Paper memory paper = paperDict[_paperId];
        Researcher memory author = researcherDict[paper.authorId];
        require(msg.sender == author.addr);

        emit PaperDownload(_paperId);
    }
    
    // Author only 
    function acceptReview(uint _paperId, bool _acceptReview) payable public{
        Paper memory paper = paperDict[_paperId];
        Researcher memory author = researcherDict[paper.authorId];
        require(msg.sender == author.addr);

        Review memory review = reviewDict[paper.reviewHistory[paper.numReview-1]];
        Researcher memory reviewer = researcherDict[review.reviewerId];
        uint reviewFee = author.numPaperPublished + author.numPaperReviewed - author.numRefusal;
        if (_acceptReview){
            reviewer.addr.transfer(reviewFee);
            if (review.accept == true){
                paper.passReviewed = true;
            }
        } else {
            author.numRefusal++;
        }
    }
}
