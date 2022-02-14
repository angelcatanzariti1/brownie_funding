//SPDX-Licence-Identifier: MIT
pragma solidity >=0.6.6 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/vendor/SafeMathChainlink.sol";

contract FundMyProject {
    using SafeMathChainlink for uint256;

    address owner;
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    constructor() public{
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
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e); //Rinkeby
        priceFeed.version();
    }

    //ETH -> USD conversion rate
    function getPrice() public view returnt(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    //
    function getConversionRate(uint256 _ethAmount) public view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * _ethAmount) / 1000000000000000000; //gwei conversion
        return ethAmountInUsd;
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
        funders = new address[];
    }
}