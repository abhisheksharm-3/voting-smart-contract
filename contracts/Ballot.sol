// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

/** 
 * @title Ballot
 * @dev Implements voting process along with vote delegation
 */
contract Ballot {

    struct Voter {
        uint weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        uint vote;   // index of the voted proposal
    }

    struct Candidate {
        string name;   // candidate name 
        uint voteCount; // number of accumulated votes
    }

    address public chairperson;

    mapping(address => Voter) public voters;

    Candidate[] public candidates;
    
    enum State { Created, Voting, Ended } // State of voting period
    
    State public state;

    constructor(string[] memory candidateNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        state = State.Created;
        
        for (uint i = 0; i < candidateNames.length; i++) {
            candidates.push(Candidate({
                name: candidateNames[i],
                voteCount: 0
            }));
        }
    }
    
    // MODIFIERS
    modifier onlyChairperson() {
        require(
            msg.sender == chairperson,
            "Only chairperson can perform this action"
        );
        _;
    }
    
    modifier inState(State _state) {
        require(state == _state, "Invalid state for this action");
        _;
    }
    
    function addCandidates(string[] memory candidateNames) 
        public 
        onlyChairperson
        inState(State.Ended)
    {
        state = State.Created;
        for (uint i = 0; i < candidateNames.length; i++) {
            candidates.push(Candidate({
                name: candidateNames[i],
                voteCount: 0
            }));
        }
    }
    
    function startVote() 
        public
        onlyChairperson
        inState(State.Created)
    {
        state = State.Voting;
    }
    
    function endVote() 
        public 
        onlyChairperson
        inState(State.Voting)
    {
        state = State.Ended;
    }
    
    function giveRightToVote(address voter) 
        public 
        onlyChairperson 
        inState(State.Created)
    {
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        require(voters[voter].weight == 0, "Voter weight must be zero");
        voters[voter].weight = 1;
    }

    function vote(uint candidate) 
        public
        inState(State.Voting)
    {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        require(candidate < candidates.length, "Invalid candidate index");
        sender.voted = true;
        sender.vote = candidate;

        candidates[candidate].voteCount += sender.weight;
    }

    function winningCandidate() 
        public
        inState(State.Ended)
        view
        returns (string memory winnerName_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < candidates.length; p++) {
            if (candidates[p].voteCount > winningVoteCount) {
                winningVoteCount = candidates[p].voteCount;
                winnerName_ = candidates[p].name;
            }
        }
    }
}
