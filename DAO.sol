// SPDX-License-Identifier: GPL-3.0
 pragma solidity >=0.8.2 <0.9.0;

contract DAO {
    address public admin;
   
    address[] public members;
    uint public totalMembers;
    uint public proposalCount;
    address[] public unAppr;
    
    struct Proposal {
        uint id;
        address creator;
        string description;
        uint votesFor;
        uint votesAgainst;
        bool isOpen;
        mapping(address => bool) voters;
    }
     mapping(uint => Proposal) public proposals;
  
    
    event NewProposal(uint proposalId, address creator, string description);
    
    constructor() {
        admin = msg.sender;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function.");
        _;
    }
    modifier onlyMember() {
       
         require(isMember(msg.sender), "Only members can perform this action");
        _;
    }
    
    function applyForMembership() public {
        require(!isMember(msg.sender), "You are already a member");
       
        unAppr.push(msg.sender);
    }
   
    function approveMembership(address _member) public onlyAdmin {
    
        require(!isMember(_member), "User is already a member");
        
        members.push(_member);
        totalMembers++;
    }

    function createProposal(string memory _description) public onlyMember {
        proposalCount++;
        Proposal storage newProposal = proposals[proposalCount];
        newProposal.id = proposalCount;
        newProposal.creator = msg.sender;
        newProposal.description = _description;
        newProposal.isOpen = true;
        emit NewProposal(proposalCount, msg.sender, _description);
    }
    function vote(uint _proposalIndex, bool _support) public onlyMember {
        require(proposals[_proposalIndex].isOpen, "Voting is closed for this proposal.");
        require(!proposals[_proposalIndex].voters[msg.sender], "You have already voted on this proposal.");
        proposals[_proposalIndex].voters[msg.sender] = true;
        if (_support) {
            proposals[_proposalIndex].votesFor++;
        } else {
            proposals[_proposalIndex].votesAgainst++;
        }
    }
    
    function closeVoting(uint _proposalIndex) public onlyAdmin {
        require(proposals[_proposalIndex].isOpen, "Voting is already closed for this proposal.");
        proposals[_proposalIndex].isOpen = false;
    }
    
    function proposalDetail(uint _proposalIndex) public view returns (string memory, uint, uint, bool) {
        return (
            proposals[_proposalIndex].description,
            proposals[_proposalIndex].votesFor,
            proposals[_proposalIndex].votesAgainst,
            proposals[_proposalIndex].isOpen
        );
    }
    function isMember(address user) public view returns(bool) {
        for (uint i = 0; i < members.length; i++) {
            if (members[i] == user) {
                return true;
            }
        }
        return false;
    }
}