// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Campaign {
    enum State { Funding, Successful, Expired }
    address public creator;
    uint256 public fundingGoal;
    uint256 public deadline;
    uint256 public amountRaised;
    State public state;

    struct Milestone {
        string description;
        uint256 payoutAmount;
        bool requested;
        bool approved;
        uint256 votes;
        mapping(address => bool) voted;
    }
    Milestone[] public milestones;

    mapping(address => uint256) public contributors;
    IERC20 public stablecoin;
    address public creatorToken;

    event ContributionMade(address indexed contributor, uint256 amount);
    event MilestonePayoutRequested(uint indexed milestoneId);
    event RevenueDistributed(uint256 totalAmount);

    modifier onlyCreator() {
        require(msg.sender == creator, "Not creator");
        _;
    }
    modifier inState(State _state) {
        require(state == _state, "Invalid state");
        _;
    }

    constructor(
        address _creator,
        uint256 _goal,
        uint256 _deadline,
        address _stablecoin,
        string[] memory _milestoneDesc,
        uint256[] memory _milestonePayouts
    ) {
        creator = _creator;
        fundingGoal = _goal;
        deadline = _deadline;
        stablecoin = IERC20(_stablecoin);
        state = State.Funding;
        for (uint i = 0; i < _milestoneDesc.length; i++) {
            milestones.push();
            Milestone storage m = milestones[i];
            m.description = _milestoneDesc[i];
            m.payoutAmount = _milestonePayouts[i];
        }
    }

    function contribute(uint256 amount) external inState(State.Funding) {
        require(block.timestamp < deadline, "Funding ended");
        stablecoin.transferFrom(msg.sender, address(this), amount);
        contributors[msg.sender] += amount;
        amountRaised += amount;
        emit ContributionMade(msg.sender, amount);
        if (amountRaised >= fundingGoal) {
            state = State.Successful;
            // Mint CreatorToken to contributors (call external)
        }
    }

    function requestMilestonePayout(uint milestoneId) external onlyCreator {
        Milestone storage m = milestones[milestoneId];
        require(!m.requested, "Already requested");
        m.requested = true;
        emit MilestonePayoutRequested(milestoneId);
    }

    function voteOnMilestone(uint milestoneId) external {
        // Only CreatorToken holders can vote (pseudo-code)
        // require(balanceOf(msg.sender) > 0, "Not token holder");
        Milestone storage m = milestones[milestoneId];
        require(!m.voted[msg.sender], "Already voted");
        m.voted[msg.sender] = true;
        m.votes += 1;
        // If quorum reached, set approved = true
    }

    function executeMilestonePayout(uint milestoneId) external onlyCreator {
        Milestone storage m = milestones[milestoneId];
        require(m.approved, "Not approved");
        stablecoin.transfer(creator, m.payoutAmount);
    }

    function distributeRevenue(uint256 amount) external onlyCreator {
        stablecoin.transferFrom(msg.sender, address(this), amount);
        // Distribute to CreatorToken holders (pseudo-code)
        emit RevenueDistributed(amount);
    }
}
