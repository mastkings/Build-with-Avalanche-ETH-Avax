const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DegenToken contract", function () {
  let DegenToken;
  let degenToken;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    DegenToken = await ethers.getContractFactory("DegenToken");
    [owner, addr1, addr2] = await ethers.getSigners();
    degenToken = await DegenToken.deploy();
  });

  describe("Minting", function () {
    it("Should mint tokens to a specified address", async function () {
      const mintAmount = 1000;
      await degenToken.mint(addr1.address, mintAmount);
      expect(await degenToken.balanceOf(addr1.address)).to.equal(mintAmount);
    });
  });

  describe("Redemption", function () {
    it("Should allow users to redeem tokens for items", async function () {
      const itemId = 1;
      const amount = 10;
      const rate = 100;
      await degenToken.setRedemptionRate(itemId, rate);
      await degenToken.mint(addr1.address, amount * rate);
      await degenToken.connect(addr1).redeem(itemId, amount);
      expect(await degenToken.balanceOf(addr1.address)).to.equal(0);
    });
  });

  describe("Setting Redemption Rates", function () {
    it("Should allow the owner to set redemption rates for items", async function () {
      const itemId = 1;
      const rate = 100;
      await degenToken.setRedemptionRate(itemId, rate);
      expect(await degenToken.getRedemptionRate(itemId)).to.equal(rate);
    });
  });

  describe("Burning Tokens", function () {
    it("Should allow users to burn tokens", async function () {
      const burnAmount = 500;
      await degenToken.mint(addr1.address, burnAmount);
      await degenToken.connect(addr1).burn(burnAmount);
      expect(await degenToken.balanceOf(addr1.address)).to.equal(0);
    });
  });
});
