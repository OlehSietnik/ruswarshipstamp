const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Auction", function () {
  let deployer, user1, user2, user3, RuswarshipStamp, stamp, RWSSAuction, auction, usdt;
  
  beforeEach(async function () {
    RuswarshipStamp = await ethers.getContractFactory("RuswarshipStamp");
    [deployer, user1, user2] = await ethers.getSigners();
    MockUSDT = await ethers.getContractFactory("MockUSDT");
    usdt = await MockUSDT.deploy();
    stamp = await RuswarshipStamp.deploy(100000, 1000, 3600*24*7, usdt.address);
    RWSSAuction = await ethers.getContractFactory("RWSSAuction");
    auction = await RWSSAuction.attach((await stamp.getAuctionAddress()).toString());
  });

  it("Mustn't allow making bid twice", async function () {
    await auction.connect(user1).makeBid(false,0, {value:324500});
    await expect(auction.connect(user1).makeBid(false,0, {value:324500})).to.be.revertedWith("Buyer already made bid");
  });

  it("Must accept payings in USDT", async function () {
    await usdt.mint(user1.address, 450000);
    await usdt.connect(user1).approve(auction.address, 450000);
    await auction.connect(user1).makeBid(true,450000);
    await expect(await usdt.balanceOf(auction.address)).to.equal(450000);
  });

  it("Must mint tokens at the end of auction", async function () {
    await auction.connect(user1).makeBid(false,0, {value:324500});
    await hre.ethers.provider.send('evm_increaseTime', [8 * 24 * 60 * 60]);
    await hre.ethers.provider.send('evm_mine');
    await auction.connect(user2).makeBid(false,0, {value:424500});
    await expect(await stamp.balanceOf(user1.address)).to.equal(1);
    await expect(await stamp.balanceOf(user2.address)).to.equal(1);
  });
});

