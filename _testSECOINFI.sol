// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./SECOINFI.sol";

contract _testSECOINFI {
    SECOINFI secoinfi;

    function beforeEach() public {
        secoinfi = new SECOINFI();
    }

    function testDeposit() public {
        uint256 amount = 100;
        secoinfi.Deposit{value: amount}(amount);

        uint256[] memory arrADE = secoinfi.getArrADE();
        assert(arrADE[0] == amount);

        assert(secoinfi.depositAmounts(0) == amount);
        assert(secoinfi.runDeposits(0) == amount);
        assert(secoinfi.bonusEarn(0) == amount);
        assert(secoinfi.sumDepositAmounts() == amount);
        assert(secoinfi.sumrunDeposits() == amount);
        assert(secoinfi.sumbonusEarn() == amount);
        assert(secoinfi.A13() == 1);
        assert(secoinfi.A3() == 2);
        assert(secoinfi.B2(0) == 1);
        assert(secoinfi.C1_A1() == 1);
    }

    function testUpdate() internal {
        secoinfi.update();

        uint256[] memory SortDepositAmounts = secoinfi.getSortedDepositAmounts();
        uint256[] memory RunDeposits = reverseArray(SortDepositAmounts);

        uint256[] memory depositAmounts = new uint256[](secoinfi.depInd());
        uint256[] memory BonusEarn = new uint256[](secoinfi.depInd());

        for (uint256 i = 0; i < secoinfi.depInd(); i++) {
            uint256 numerator = (secoinfi.depositAmounts(i) * 1) + (RunDeposits[i] * 3);
            BonusEarn[i] = numerator / 4;
        }

        //assert(areArraysEqual(secoinfi.bonusEarn(), BonusEarn));

        uint256 SumDepositAmounts = sumArray(depositAmounts);
        assert(secoinfi.sumDepositAmounts() == SumDepositAmounts);

        uint256 expectedSumRunDeposits = sumArray(RunDeposits);
        assert(secoinfi.sumrunDeposits() == expectedSumRunDeposits);

        uint256 expectedSumBonusEarn = sumArray(BonusEarn);
        assert(secoinfi.sumbonusEarn() == expectedSumBonusEarn);
    }

    function testGetSortedDepositAmounts() public view {
        uint256[] memory depositAmounts = new uint256[](3);
        depositAmounts[0] = 30;
        depositAmounts[1] = 10;
        depositAmounts[2] = 20;
        
        depositAmounts;
        
        uint256[] memory sortedAmounts = secoinfi.getSortedDepositAmounts();
        
        assert(sortedAmounts[0] == 10 && sortedAmounts[1] == 20 && sortedAmounts[2] == 30);
    }
/*
    
    function areArraysEqual(uint256[] memory arr1, uint256[] memory arr2) private pure returns (bool) {
        if (arr1.length != arr2.length) {
            return false;
        }

        for (uint256 i = 0; i < arr1.length; i++) {
            if (arr1[i] != arr2[i]) {
                return false;
            }
        }

        return true;
    }
*/

    function reverseArray(uint256[] memory array) private pure returns (uint256[] memory) {
        uint256[] memory reversed = new uint256[](array.length);

        for (uint256 i = 0; i < array.length; i++) {
            reversed[i] = array[array.length - 1 - i];
        }

        return reversed;
    }

    function sumArray(uint256[] memory array) private pure returns (uint256) {
        uint256 sum = 0;

        for (uint256 i = 0; i < array.length; i++) {
            sum += array[i];
        }

        return sum;
    }

    function testReverseArray() public pure {
        uint256[] memory array = new uint256[](3);
        array[0] = 10;
        array[1] = 20;
        array[2] = 30;
        uint256[] memory reversed = reverseArray(array);
        assert(reversed[0] == 30 && reversed[1] == 20 && reversed[2] == 10);
    }

    function testSumArray() public pure {
        uint256[] memory array = new uint256[](3);
        array[0] = 10;
        array[1] = 20;
        array[2] = 30;
        uint256 sum = sumArray(array);
        assert(sum == 60);
    }

    function testGetSumData() public {
        secoinfi.Deposit{value: 100}(100);
        secoinfi.update();
        (uint256 sumDepositAmounts, uint256 sumrunDeposits, uint256 sumbonusEarn) = secoinfi.getSumData();
        assert(sumDepositAmounts == 100 && sumrunDeposits == 100 && sumbonusEarn == 75);
    }

    function testMulBonusEarn() public {
        secoinfi.Deposit{value: 100}(100);
        secoinfi.update();
        uint256[] memory bonusEarns = secoinfi.mulBonusEarn();
        assert(bonusEarns[0] == 75);
    }

    function testGetArrADE() public {
        uint256 amount = 100;
        secoinfi.Deposit{value: amount}(amount);
        uint256[] memory arrADE = secoinfi.getArrADE();
        assert(arrADE[0] == amount);
    }

    function testDepositorCount() public {
        secoinfi.Deposit{value: 100}(100);
        uint256 count = secoinfi.DepositorCount();
        assert(count == 1);
    }
    
    function testGetBalance() public {
        // Deploy the SECOINFI contract
        secoinfi = new SECOINFI();

        // Perform a deposit
        secoinfi.depositFD{value: 100}();

        // Get the balance for the current contract
        uint256 balance = secoinfi.getBalance(address(this));

        // Assert the balance is correct
        assert(balance == 100);
    }

    function testBalance() public {
        // Deploy the SECOINFI contract
        secoinfi = new SECOINFI();

        // Perform deposits
        secoinfi.depositFD{value: 100}();
        secoinfi.depositFD{value: 200}();

        // Get the balance for the test contract
        uint256 balance = secoinfi.getBalance(address(this));

        // Assert the balance is correct
        assert(balance == 300);
    }


    function testWithdraw() public {
        secoinfi.Deposit{value: 100}(100);
        secoinfi.withdraw(50);
        assert(secoinfi.balances(address(this)) == 50);
    }

    function testWithdrawAll() public {
        secoinfi.Deposit{value: 100}(100);
        secoinfi.withdrawAll();
        assert(secoinfi.balances(address(this)) == 0);
    }

    function testTransfer() public {
        secoinfi.Deposit{value: 100}(100);
        secoinfi.transfer(address(this), address(0x123), 50);
        assert(secoinfi.balances(address(this)) == 50 && secoinfi.balances(address(0x123)) == 50);
    }

    function testShareBal() public {
        secoinfi.Deposit{value: 100}(100);
        secoinfi.update();
        secoinfi.shareBal();
        assert(secoinfi.depositAmounts(0) == 0 && secoinfi.depositAmounts(1) == 200);
    }

    function testAddressToUint256() public {
        // Deploy the SECOINFI contract
        secoinfi = new SECOINFI();

        // Convert the address to bytes32 using the addressToUint256 function
        bytes32 result = secoinfi.addressToUint256(address(0x68652807D33EB9a147Af2fa5C75196A2Fc06de1D));

        // Assert the result is the expected address
        assert(result == 0x00000000000000000000000068652807d33eb9a147af2fa5c75196a2fc06de1d);
    }

}
