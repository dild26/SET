// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "contracts/_sol/SECOINFI.sol";

contract TestSECOINFI {
    SECOINFI private secoinfi;
    address payable private owner;

    constructor() {
        owner = payable(0x68652807D33EB9a147Af2fa5C75196A2Fc06de1D);
        secoinfi = new SECOINFI();
    }

    function shareBalance() public {
        secoinfi.shareBalance();
    }

    function runTests() external {
        // Perform necessary setup and deposit funds
        // ...

        // Call the shareBalance function
        shareBalance();

        // Verify the updated balances
        uint256 lastincInvIndex = secoinfi.incInvLength() - 1;

        for (uint256 i = 0; i < secoinfi.earnIntLength(); i++) {
            if (secoinfi.getIncInv(i) == secoinfi.getEarnInt(i)) {
                uint256 transferAmount = secoinfi.getIncInv(i);

                secoinfi.setIncInv(i, 0);  // Clear the balance from incInv[i]
                secoinfi.setIncInv(lastincInvIndex, secoinfi.getIncInv(lastincInvIndex) + transferAmount);  // Transfer the balance to the last incInv

                // Verify the updated balances
                assert(secoinfi.getIncInv(i) == 0);
                assert(secoinfi.getIncInv(lastincInvIndex) == transferAmount);
            }
        }
    }
}
