// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SECOINFI {
    address payable immutable owner;
    mapping(address => uint256) public balances;
    mapping(address => bool) public depositors; // Track unique depositors
    uint256[] public depositAmounts;
    uint256[] public sortDepositAmounts;
    uint256[] public runDeposits;
    uint256[] public bonusEarn;

    uint256 public sumDepositAmounts;
    uint256 public sumrunDeposits;
    uint256 public sumbonusEarn;
    uint256 public depInd;
    uint256[] public debitAmounts;
    uint256[] public creditAmounts;

    uint256 public A13;
    uint256 public A3;
    uint256[] public B2;
    uint256 public C1_A1;    

    constructor() {
        owner = payable(0x68652807D33EB9a147Af2fa5C75196A2Fc06de1D);
        depInd = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }    

    function Deposit(uint256 index) public payable {
        depositAmounts.push(index);
        depInd++;
        update();
        depositors[msg.sender] = true; // Track the depositor
    }

    function revArr(uint256[] memory array) internal pure returns (uint256[] memory) {
        uint256 length = array.length;
        uint256[] memory revd = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            revd[i] = array[length - i - 1];
        }

        return revd;
    }

    function update() public {
        sortDepositAmounts = sortArray(depositAmounts);
        runDeposits = reverseArray(sortDepositAmounts);

        bonusEarn = new uint256[](depositAmounts.length);
        for (uint256 i = 0; i < depositAmounts.length; i++) {            
            uint256 numerator = (depositAmounts[i] * 1) + (runDeposits[i] * 3);
            bonusEarn[i] = numerator / 4;
        }

        sumDepositAmounts = sumArray(depositAmounts);
        sumrunDeposits = sumArray(runDeposits);
        sumbonusEarn = sumArray(bonusEarn);

        A13 = depositAmounts.length;
        A3 = A13 + 1;

        B2 = new uint256[](1);
        B2[0] = sumDepositAmounts / sumrunDeposits;

        C1_A1 = sumbonusEarn / sumDepositAmounts;
    }
    
    function sortArray(uint256[] memory array) public pure returns (uint256[] memory) {
        uint256[] memory sorted = new uint256[](array.length);
        for (uint256 i = 0; i < array.length; i++) {
            sorted[i] = array[i];
        }

        for (uint256 i = 0; i < sorted.length - 1; i++) {
            for (uint256 j = i + 1; j < sorted.length; j++) {
                if (sorted[i] > sorted[j]) {
                    uint256 temp = sorted[i];
                    sorted[i] = sorted[j];
                    sorted[j] = temp;
                }
            }
        }

        return sorted;
    }

    function getSortedDepositAmounts() public view returns (uint256[] memory) {
        //uint256[] memory depositAmounts = depositAmounts;
        return sortArray(depositAmounts);
    }

    function reverseArray(uint256[] memory array) internal pure returns (uint256[] memory) {
        uint256[] memory reversed = new uint256[](array.length);
        for (uint256 i = 0; i < array.length; i++) {
            reversed[i] = array[array.length - i - 1];
        }
        return reversed;
    }

    function sumArray(uint256[] memory array) internal pure returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < array.length; i++) {
            sum += array[i];
        }
        return sum;
    }

    function getSumData() external view returns (uint256, uint256, uint256) {
        return (sumDepositAmounts, sumrunDeposits, sumbonusEarn);
    }

    function mulBonusEarn() public view returns (uint256[] memory) {
        uint256[] memory bonusEarns = new uint256[](depInd);

        for (uint256 i = 0; i < depInd; i++) {
            uint256 numerator = (depositAmounts[i] * 1) + (runDeposits[i] * 3);
            bonusEarns[i] = numerator / 4;
        }

        return bonusEarns;
    }



/*
    function mulBonusEarn() public view returns (uint256[] memory) {
        uint256[] memory bonusEarns = new uint256[](depInd);

        for (uint256 i = 0; i < depInd; i++) {
            if (i == 0) {
                bonusEarns[i] = depositAmounts[i] * runDeposits[i] / runDeposits[0];
            } else {
                bonusEarns[i] = depositAmounts[i] * runDeposits[i] / runDeposits[i - 1];
            }
        }

        return bonusEarns;
    }
*/
    function getArrADE() public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](depInd);
        for (uint256 i = 0; i < depInd; i++) {
            result[i] = depositAmounts[i] * (sumDepositAmounts / sumrunDeposits);
        }
        return result;
    }


    function DepositorCount() external view returns (uint256) {
        uint256 count = 0;
        uint256 length = depositAmounts.length;

        for (uint256 i = 0; i < length; i++) {
            if (depositors[address(uint160(msg.sender))]) {
                count++;
            }
        }
        return count;
    }

    function depositFD() external payable {
        require(msg.value > 0, "Dep amount must be greater than zero");
        Deposit(uint256(msg.value));
    }

    function depositEMI(uint256 monthlyAmount, uint256 numberOfMonths) external payable {
        require(msg.value > 0, "Dep amount must be greater than zero");
        uint256 sumAmount = monthlyAmount * numberOfMonths;
        require(msg.value >= sumAmount, "Insufficient funds");
        for (uint256 i = 0; i < numberOfMonths; i++) {
            Deposit(monthlyAmount);
        }
        if (msg.value > sumAmount) {
            payable(msg.sender).transfer(msg.value - sumAmount); // Refund any excess funds
        }
    }

    function getBalance(address account) public view returns (uint256) {
        return balances[account];
    }

    function withdraw(uint256 amount) external {
        require(amount <= balances[msg.sender], "Insufficient bal");
        balances[msg.sender] = uint256(uint256(balances[msg.sender]) - amount);
        payable(msg.sender).transfer(uint256(amount));
    }

    function withdrawAll() external onlyOwner {
        uint256 contractBal = address(this).balance;
        require(contractBal > 0, "Contract has no bal");
        owner.transfer(contractBal);
    }

    // Implement the addressToUint256 function from the AddressInterface
    function addressToUint256(address addr) external pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

    receive() external payable {
        if (msg.value > 0) {
            Deposit(uint256(msg.value));
        }
    }

    fallback() external payable {
        if (msg.value > 0) {
            Deposit(uint256(msg.value));
        }
    }

    event Transfer(address indexed from, address indexed to, uint256 amount);

    function transfer(address from, address to, uint256 amount) external payable {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBal = balances[from];
        require(fromBal >= amount, "ERC20: transfer amount exceeds bal");
        unchecked {
            balances[from] = fromBal - amount;
            balances[to] += amount;
        }

        emit Transfer(from, to, amount);
    }  

    event ShareBal(address indexed account, uint256 indexed amount);

    function shareBal() public {
        require(sumDepositAmounts == sumbonusEarn, "Sum mismatch");

        uint256 lastDepIndex = depositAmounts.length - 1;
        uint256 transferAmount = address(this).balance;
        depositAmounts[lastDepIndex] += transferAmount;

        for (uint256 i = 0; i < bonusEarn.length; i++) {
            uint256 previousWithdrawal = debitAmounts[i];
            uint256 balanceToTransfer = bonusEarn[i] - previousWithdrawal;
            debitAmounts[i] = bonusEarn[i];

            if (depInd == bonusEarn.length) {
                address payable bonusEarnAddress = payable(address(uint160(bonusEarn[i])));
                bonusEarnAddress.transfer(balanceToTransfer);
                emit ShareBal(bonusEarnAddress, balanceToTransfer);
            }
        }
    }


}
