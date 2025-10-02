// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Campaign.sol";

contract CampaignFactory {
    address[] public allCampaigns;

    event CampaignCreated(address indexed creator, address campaign);

    function createCampaign(
        uint256 goal,
        uint256 deadline,
        address stablecoin,
        string[] memory milestoneDesc,
        uint256[] memory milestonePayouts
    ) external returns (address) {
        Campaign newCampaign = new Campaign(
            msg.sender,
            goal,
            deadline,
            stablecoin,
            milestoneDesc,
            milestonePayouts
        );
        allCampaigns.push(address(newCampaign));
        emit CampaignCreated(msg.sender, address(newCampaign));
        return address(newCampaign);
    }

    function getAllCampaigns() external view returns (address[] memory) {
        return allCampaigns;
    }
}
