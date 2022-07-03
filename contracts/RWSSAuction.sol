// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./RuswarshipStamp.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//import "hardhat/console.sol";

contract RWSSAuction {

    struct Bid {
        address buyer;
        uint256 amount;
        bool isUSDT;
    }

    struct Auction {
        mapping(address => bool) buyers;
        Bid[] bids;
    }

    address private _tokenAddress;
    uint256 private _maxTokensForPeriod;
    uint256 private _periodTime;
    uint256 private _nextMintPeriodDate;
    bool private _canMakeBid;
    RuswarshipStamp private _token;
    Auction[] private _auctions;
    address private _USDTAddress;


    constructor(address tokenAddress, uint256 maxTokensForPeriod, uint256 periodTime, address USDTAddress) {
        _tokenAddress = tokenAddress;
        _maxTokensForPeriod = maxTokensForPeriod;
        _periodTime = periodTime;
        _nextMintPeriodDate = block.timestamp + _periodTime;
        _canMakeBid = true;
        _auctions.push();
        _USDTAddress = USDTAddress;
    }

    function makeBid(bool isUSDT, uint256 amount) payable external { // 0 - native currency, 1 - USDT
        require(_canMakeBid, "Auction is over");
        Auction storage auction = _auctions[_auctions.length - 1];
        require(!auction.buyers[msg.sender], "Buyer already made bid");
        if(!isUSDT) {
            amount = msg.value;
        }
        else {
            ERC20 usdtContract = ERC20(_USDTAddress);
            usdtContract.transferFrom(msg.sender, address(this), amount);
        }
        auction.bids.push(Bid(msg.sender, amount, isUSDT));
        auction.buyers[msg.sender] = true;
        if(block.timestamp > _nextMintPeriodDate) {
            mintTokens();
            _nextMintPeriodDate += _periodTime;
            _auctions.push();
        }
    }

    function mintTokens() internal {
        Auction storage auction = _auctions[_auctions.length - 1];
        _token = RuswarshipStamp(_tokenAddress);
        Bid[] memory bids = auction.bids;
        uint256 usdtPrice = mockUSDTPrice();
        for(uint i = 0; i < bids.length; i++) {
            if(!bids[i].isUSDT) {
                bids[i].amount = (bids[i].amount / usdtPrice) * (10**4);
            }
        }
        quickSort(bids, 0, bids.length - 1);
        uint256 len = bids.length > _maxTokensForPeriod ? _maxTokensForPeriod : bids.length;
        address[] memory ads = new address[](len);
        for(uint i = 0; i < len; i++) {
            ads[i] = bids[i].buyer;
        }
        _token.mint(ads, _maxTokensForPeriod);
        _canMakeBid = (_token.getNumTokens() + _maxTokensForPeriod) <= _token.getMaxTokens();
    }

    function quickSort(Bid[] memory arr, uint left, uint right) internal {
        uint i = left;
        uint j = right;
        if(i==j) return;
        uint pivot = arr[left + (right - left) / 2].amount;
        while (i <= j) {
            while (arr[i].amount > pivot) i++;
            while (pivot > arr[j].amount) j--;
            if (i <= j) {
                (arr[i], arr[j]) = (arr[j], arr[i]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSort(arr, left, j);
        if (i < right)
            quickSort(arr, i, right);
    }

    function mockUSDTPrice() internal pure returns (uint256) {
        return 200000;
    }

}