const { ethers, upgrades } = require("hardhat");

async function main() {
    const Credit = await ethers.getContractFactory("CapitalCredit");
    const credit = await upgrades.deployProxy(Credit);
    await credit.deployed();
    console.log("credit deployed to:", credit.address);
  }
  
  main();