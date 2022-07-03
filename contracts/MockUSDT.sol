// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSDT is ERC20 {

    uint256 public constant MOCK_SUPPLY = 100e18;

    constructor() ERC20("Tether", "USDT") {
        _mint(msg.sender, MOCK_SUPPLY);
    }

    function mint(address account, uint value) public {
        _mint(account, value);
    }


}