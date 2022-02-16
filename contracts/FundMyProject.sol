// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMyProject {
    using SafeMathChainlink for uint256;

    address owner;
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public{
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function fund() public payable {
        uint256 minimumUSD = 50 * 10 ** 18; //$50 * 10^18
        require(getConversionRate(msg.value) >= minimumUSD, "You need to spend at least USD 50 in ETH.");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    //Get Aggregator Interface version
    function getVersion() public view returns(uint256) {
        return priceFeed.version();
    }

    //ETH -> USD conversion rate
    function getPrice() public view returns(uint256){
        (,int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    //
    function getConversionRate(uint256 _ethAmount) public view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * _ethAmount) / 1000000000000000000; //gwei conversion
        return ethAmountInUsd;
    }

    function getEntranceFee() public view returns(uint256){
        // Minimum USD
        uint256 minimumUSD = 50* 10**18;
        uint256 price = getPrice();
        uint256 precision = 1* 10**18;
        return (minimumUSD * precision) / price;
    }

    modifier onlyOwner{
        require(msg.sender == owner, "You're not authorized.");
        _;
    }

    //withdraw all the funds
    function withdraw() payable onlyOwner public {
        msg.sender.transfer(address(this).balance);
        //reset funders' balance to 0
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //reset funders array
        funders = new address[](0);
    }
}