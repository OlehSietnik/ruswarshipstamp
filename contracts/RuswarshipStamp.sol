// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./RWSSAuction.sol";

contract RuswarshipStamp is ERC721 {

    struct Stamp {
        string data;
    }

    Stamp[] private _stamps;
    RWSSAuction private _auction;
    uint256 private _maxTokens;
    

    constructor(uint256 maxTokens, uint256 maxTokensForPeriod, uint256 periodTime, address USDTAddress) ERC721("RuswarshipStamp", "RWSS") {
        _auction = new RWSSAuction(address(this), maxTokensForPeriod, periodTime, USDTAddress);
        _maxTokens = maxTokens;
    }

    function getAuctionAddress() view external returns (address) {
        return address(_auction);
    }

    function getMaxTokens() view external returns (uint256) {
        return _maxTokens;
    }

    function getNumTokens() view external returns (uint256) {
        return _stamps.length;
    }

    function mint(address[] memory to, uint256 expectedLen) external onlyAuction {
        require((_stamps.length + to.length) <= _maxTokens, "Not enough space for tokens");
        for(uint256 i = 0; i < to.length; i++) {
            _stamps.push(Stamp("Won auction"));
            _mint(to[i], _stamps.length - 1);
        }
        if(to.length < expectedLen) {
            burnMultiple(expectedLen - to.length);
        }
    }

    function burnMultiple(uint256 num) internal {
        if((_stamps.length + num) > _maxTokens) {
            num = _maxTokens - _stamps.length;
        }
        for(uint i = 0; i < num; i++) {
            _stamps.push(Stamp("Burnt"));
        }
    }

    modifier onlyAuction {
        require(msg.sender == address(_auction), "Only auction can call this function");
        _;
    }

}
