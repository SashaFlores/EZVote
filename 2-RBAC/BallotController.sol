pragma solidity ^0.5.0;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/access/Roles.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/drafts/Counters.sol";

/**
 * @title BallotController
 * Implement Voting process with Role-Based Access Controller
 */

contract BallotController{
    /**
     * RBAC liab to determine Roles
     */

    using Roles for Roles.Role;
    Roles.Role private Controller;
    Roles.Role private Admins;
    
    /**
     * using counters to increment CandidateIDs
     */
    using Counters for Counters.Counter;
    Counters.Counter CandidateIDs;
    
    
    string public ballotOfficialName;
    address public ballotControllerAddress;
    
    struct Candidate{
        string Name;
        string Party;
        uint voteCount;
    }
    
    
    struct voter{
        string voterName;
        bool authorized;
        bool voted;
        uint vote; // index of votes per Candidate
    }
    
    mapping(uint=>Candidate) public CandidateRegister;
    mapping(address=>voter) public VotersRegister;
  
    
    uint public totalVoters=0;
    uint public totalVotes=0;

 
    
    event CandidateAdded(uint CandidateID, string Candidate, string party);
    event VoterAdded(address voter);
    event VoteStarted();
    event VoteCounting(uint voteFor);
    event VoteEnded();
    
    
    enum State { Created, Voting, Ended }
	State public state;
	
	
    constructor(string memory  _ballotOfficialName) public {
        ballotOfficialName= _ballotOfficialName;
        ballotControllerAddress = msg.sender;
        Controller.add(ballotControllerAddress);
        state = State.Created;
    }
    
    modifier inState(State _state) {
		require(state == _state);
		_;
	}
    
    modifier onlyController() {
        require(Controller.has(msg.sender) == true, "Must be the Controller");
        _;
    }
    
    modifier onlyAdmins() {
        require(Admins.has(msg.sender) == true, "You aren't an authorized Admin");
        _;
    }
    
 
    function addAdmins(address _newAdmin) public inState(State.Created) onlyController(){
        Admins.add(_newAdmin);
    }
    
    function registerCandidate(string memory _name, string memory _party) public onlyController inState(State.Created) returns(uint){
        CandidateIDs.increment();
        uint CandidateID = CandidateIDs.current();
        CandidateRegister[CandidateID] = Candidate(_name, _party,0);
        emit CandidateAdded(CandidateID, _name, _party);
        return CandidateID;
    }
    
    function registerVoter(address _voterAddress, string memory _voterName) public onlyAdmins inState(State.Created){
        voter memory v;
        v.voterName=_voterName;
        _voterAddress=msg.sender;
        v.authorized=true;
        v.voted=false;
        totalVoters++;
        emit VoterAdded(_voterAddress);
    }
    
    function openBallot() public onlyController inState(State.Created){
        state= State.Voting;
        emit VoteStarted();
    }
    
    function castYourBallot(uint voteFor) public inState(State.Voting){
        require(!VotersRegister[msg.sender].voted, "You alreay voted!");
        require(VotersRegister[msg.sender].authorized, "You are not authorized to use this Platform");
        VotersRegister[msg.sender].vote=voteFor;
        VotersRegister[msg.sender].voted=true;
        CandidateRegister[voteFor].voteCount++;
        totalVotes++;
        emit VoteCounting(voteFor);
    }
    
    function closeVoting() public onlyAdmins inState(State.Voting){
        state= State.Ended;
        emit VoteEnded();
    }
    
}