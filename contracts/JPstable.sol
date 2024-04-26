// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract JPStablecoin is ERC20, Ownable {
    // KYC/AML Data
    struct KYCData {
        address userAddress;
        bool isKYCApproved;
        bool isAMLApproved; 
    }

    mapping(address => KYCData) public kycRecords;

    // Events for KYC/AML
    event KYCApproved(address indexed userAddress);
    event AMLApproved(address indexed userAddress);

    constructor(address initialOwner) 
        ERC20("JapaneseStableCoin", "JPSC")
        Ownable(initialOwner) {     
            _mint(msg.sender, 1000 * 10**decimals());  // 初期供給量としてトークンを発行 
        }

    // **Minting Function (Owner Only)**
    function mint(address to, uint256 amount) external onlyOwner {
        // Ensure corresponding fiat reserves exist before minting
        _mint(to, amount);
    }

    // **Burning Function (Owner Only)**
    function burn(address from, uint256 amount) external onlyOwner {
        // Ensure fiat reserves are released when burning
        _burn(from, amount);
    }

    // **KYC/AML Functions (Owner Only)**
    function setKYCApproval(address userAddress, bool approved) external onlyOwner {
        kycRecords[userAddress].isKYCApproved = approved;
        emit KYCApproved(userAddress);
    }

    function setAMLApproval(address userAddress, bool approved) external onlyOwner {
        kycRecords[userAddress].isAMLApproved = approved;
        emit AMLApproved(userAddress);
    }

    // **Override Transfer Functions (KYC/AML Checks)**
    function transfer(address to, uint256 amount) public override returns (bool) {
        require(kycRecords[msg.sender].isKYCApproved, "KYC not approved");
        require(kycRecords[msg.sender].isAMLApproved, "AML not approved");
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        require(kycRecords[from].isKYCApproved, "KYC not approved for sender");
        require(kycRecords[from].isAMLApproved, "AML not approved for sender");
        return super.transferFrom(from, to, amount);
    }
}
