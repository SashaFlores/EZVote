pragma solidity ^0.4.21;

contract Election{
    //store candidate info.
    struct Candidate {
        // Candidate name in string
        string name;
        
        //how many votes each candidate received
        uint voteCount;
    }
    
    //store voter info.
    struct Voter {
        // only authorized voters can vote
        bool authorized;
        
        // to prevent voting more than one time
        bool voted;
        
        
        //to keep track of each vote received
        uint vote;
    }
    
    //////START STATE VARIABLES//////
    
    //deployer is the owner of the contract
    address public owner;
    
    // identify election name or purpose
    string public electionName;
    
    //mapping the address to voters
    mapping(address =>  Voter) public voters;
    
    //keep track of candidates in an array.
    Candidate[] public candidates;
    
    //keep track of how many votes are received
    uint public totalVotes;
    
   //////END STATE VARIABLES//////
   
   
    event voteEvent (uint _voteIndex);
    
    //set delpoyer which is the contract owner
    //to be the only one allowed to modify
    //functions in this contract when ownerOnly
    //is added to any function
    
    //_; is a pre-condition check in this contract
    //making sure that require condition is satisfied first
    //before executing the rest of the function.
    
    modifier ownerOnly() {
        require(msg.sender == owner);
        _;
    }
    
    // constructor executed once when the contract is deployed.
    constructor (string memory _name) public {
        
        //create global variable to owner
        // owner here is the delpoyer
        owner = msg.sender;
        
        //pass the parameter given in constructor
        // to set the election name
        electionName = _name;
    }
    
    // create a function to add candidate in the form of string
    //ownerOnly: only owner can add candidates
    //to prevent anyone interferring with candidate list.
    // it was set earlier in modifier line 57.
    
    //push : is to push new candidate in the array of candidates
    //crteating a new Candidate struct, passing all parameters given
    //in the struct which is giving _name, & _uint voteCount 
    //starting with zero votes.
    function addCandidate(string _name) ownerOnly public {
        candidates.push(Candidate(_name,0));
    }
    
    //create a function to keep track of the number of candidates
    //view : is to read only & not changing our varaiables.
    function getNumCandidate() public view returns (uint) {
        return candidates.length;
    }
    
    //create a function to authorize _person to vote
    //authorization is given only by owner
    
    //setting voters in mapping & using the parameter passed
    //in function (_person), to set the authorized bool 
    //in the struct Voter to be true, it is false by default
    function authorize(address _person) ownerOnly public {
        voters[_person].authorized = true;
    }
    
    //create function to vote, _voteIndex is used to index candidates array
    //set require conditions to ensure that voter will vote one time only
    //& that voter is authorized to vote
    //require is true by default in case of bool.
    
    //line 117: to keep track of who the voters voted for & stored in _voteIndex
    //line 118: to ensure that voters wouldn't vote again
    
    //line 120: to link _voteIndex to candidates & incremented by one.
    //line 121: to increase totalVotes by one as well
    function vote (uint _voteIndex) public {
        require(!voters[msg.sender].voted, "You already voted!");
        require(voters[msg.sender].authorized);
        
        voters[msg.sender].vote = _voteIndex;
        voters[msg.sender].voted = true;
        
        candidates[_voteIndex].voteCount += 1;
        totalVotes += 1;
        
        emit voteEvent (_voteIndex);
    }
    
    //create a function accessed by ownerOnly to call out elections
    //selfdestruct to prevent fruther changes to be made to the contract
    //by passing owner as a parameter in self destruct, it will return
    //any remainnig ETH to the owner.
    function end() ownerOnly public {
        selfdestruct(owner);
        
        
    }
    
    
    
}
