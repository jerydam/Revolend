// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract P2PLending is Ownable {
    constructor(
        address _initialowner,
        address _treasuryaddr,
        address Revo,
        address usdt,
        address dai
    ) Ownable(_initialowner) {
        treasuryAddress = _treasuryaddr;
        _addCollateral(Revo);
        _addCollateral(usdt);
        _addCollateral(dai);
    }

    // The minimum and maximum amount of ETH that can be loaned
    uint public constant MIN_LOAN_AMOUNT = 0.001 ether;
    uint public constant MAX_LOAN_AMOUNT = 100000 ether;
    // The minimum and maximum interest rate in percentage that can be set for a loan
    uint public constant MIN_INTEREST_RATE = 2;
    uint public constant MAX_INTEREST_RATE = 20;
    // Service fee percentage
    uint public constant SERVICE_FEE_PERCENTAGE = 2;

    struct Loan {
        uint loan_id;
        uint amount;
        uint interest;
        uint duration;
        uint repaymentAmount;
        uint fundingDeadline;
        uint collateralAmount;
        address borrower;
        address payable lender;
        address collateral;
        bool isCollateralErc20;
        bool active;
        bool repaid;
    }

    mapping(uint => Loan) public loans;
    mapping(address => uint) public defaulters;
    mapping(address => bool) public outstanding;
    mapping(address=>bool) public accepteddCollaterals;
    address[] public accepted_collaterals;
    uint public loanCount;
    address public treasuryAddress;
    address public dao;
    uint public totalServiceCharges;
    event LoanCreated(
        uint loanId,
        uint amount,
        uint interest,
        uint duration,
        uint fundingDeadline,
        address borrower,
        address lender
    );
    event LoanFunded(uint loanId, address funder, uint amount);
    event LoanRepaid(uint loanId, uint amount);
    event ServiceFeeDeducted(uint loanId, uint amount);
    event ServiceChargesWithdrawn(address owner, uint amount);
    event CollateralClaimed(uint loanId, address lender);
    event CollateralAdded(address collateral);

    modifier onlyActiveLoan(uint _loanId) {
        require(loans[_loanId].active, "Loan is not active");
        _;
    }
    modifier isCollateral(address _addr){
        require(accepteddCollaterals[_addr]==true, "collateral not acceptable");
        _;
    }

       modifier onlyDao(address _caller){
        require(_caller == dao, "unauthorized");
        _;
    }


    modifier onlyBorrower(uint _loanId) {
        require(
            msg.sender == loans[_loanId].borrower,
            "Only the borrower can perform this action"
        );
        _;
    }

    function setadaoaddress(address _dao) public onlyOwner{
        dao = _dao;
    }
    
    function addCollateral(address _collateral) public onlyOwner{
           _addCollateral(_collateral);
            emit CollateralAdded(_collateral);
    }

    function _addCollateral(address _collateral) internal{
            accepteddCollaterals[_collateral] = true;
            accepted_collaterals.push(_collateral);   
    }
    function getAllLoans() external view returns (Loan[] memory) {
        Loan[] memory allLoans = new Loan[](loanCount);
        for (uint i = 0; i < loanCount; i++) {
            allLoans[i] = loans[i];
        }
        return allLoans;
    }

    function createLoan(
        uint _amount,
        uint _interest,
        uint _duration,
        uint _collateralamount,
        address _collateral,
        bool _isERC20,
        uint _fundingDeadline
    ) external payable isCollateral(_collateral) {
        require(
            _amount >= MIN_LOAN_AMOUNT && _amount <= MAX_LOAN_AMOUNT,
            "Loan amount must be between MIN_LOAN_AMOUNT and MAX_LOAN_AMOUNT"
        );
        require(
            _interest >= MIN_INTEREST_RATE && _interest <= MAX_INTEREST_RATE,
            "Interest rate must be between MIN_INTEREST_RATE and MAX_INTEREST_RATE"
        );
        require(_duration > 0, "Loan duration must be greater than 0");
        uint loanId = loanCount++;
        Loan storage loan = loans[loanId];
        require(outstanding[loan.borrower]==false, "settle outstanding loan");
        uint _repaymentAmount = _amount + (_amount * _interest) / 100;
        loan.amount = _amount;
        loan.loan_id = loanId;
        loan.interest = _interest;
        loan.duration = _duration + block.timestamp;
        loan.collateral = _collateral;
        loan.collateralAmount = _collateralamount;
        loan.repaymentAmount = _repaymentAmount;
        loan.fundingDeadline = _fundingDeadline + block.timestamp;
        loan.borrower = msg.sender;
        loan.isCollateralErc20 = _isERC20;
        loan.lender = payable(address(0));
        loan.active = true;
        loan.repaid = false;

        

        if (_isERC20) {
            /// Transfer ERC20 tokens from the borrower to this contract
            require(
                IERC20(_collateral).transferFrom(
                    msg.sender,
                    address(this),
                    _collateralamount
                ),
                "ERC20 transfer failed"
            );
        } else {
            /// @dev: pass in nft id for collateralammount in case where _isERC20 is false
            IERC721(_collateral).transferFrom(
                msg.sender,
                address(this),
                _collateralamount
            );
        }

        emit LoanCreated(
            loanId,
            _amount,
            _interest,
            _duration,
            _fundingDeadline,
            msg.sender,
            address(0)
        );
    }

    function fundLoan(uint _loanId) external payable onlyActiveLoan(_loanId) {
        Loan storage loan = loans[_loanId];
        require(
            msg.sender != loan.borrower,
            "Borrower cannot fund their own loan"
        );
        if (block.timestamp > loan.fundingDeadline){
            loan.active = false;
            revert("deadline passed");
        }
        payable(msg.sender).transfer(loan.amount);
        loan.lender = payable(msg.sender);
        outstanding[loan.borrower] = true;
        loan.active = true;
        emit LoanFunded(_loanId, msg.sender, msg.value);
    }

    function repayLoan(
        uint _loanId
    ) external payable onlyActiveLoan(_loanId) onlyBorrower(_loanId) {
        Loan storage loan = loans[_loanId];
        require(!loan.repaid, "Loan has already been repaid");

        uint interestAmount = (loan.amount * loan.interest) / 100;
        uint repaymentAmount = loan.amount + interestAmount;
        // Deduct service fee from the repayment amount
        uint serviceFee = (repaymentAmount * SERVICE_FEE_PERCENTAGE) / 100;
        uint amountAfterFee = repaymentAmount - serviceFee;

        // Transfer repayment amount minus service fee to the lender
        loan.lender.transfer(amountAfterFee);
        payable(treasuryAddress).transfer(serviceFee);
        if (loan.isCollateralErc20) {
            // If collateral is ERC20
            require(
                IERC20(loan.collateral).transfer(
                    msg.sender,
                    loan.collateralAmount
                ),
                "Failed to transfer ERC20 collateral"
            );
        } else {
            // If collateral is ERC721 NFT
            IERC721(loan.collateral).transferFrom(
                address(this),
                msg.sender,
                loan.collateralAmount
            );
        }

        // Accumulate service charges
        totalServiceCharges += serviceFee;

        // Emit events
        emit LoanRepaid(_loanId, repaymentAmount);
        emit ServiceFeeDeducted(_loanId, serviceFee);

        // Update loan status
        loan.repaid = true;
        outstanding[loan.borrower] = false;
        loan.active = false;
    }

function getLoanInfo(uint _loanId) external view returns (Loan memory) {
    Loan storage loan = loans[_loanId];
    return Loan(
        loan.loan_id,
        loan.amount,
        loan.interest,
        loan.duration,
        loan.repaymentAmount,
        loan.fundingDeadline,
        loan.collateralAmount,
        loan.borrower,
        loan.lender,
        loan.collateral,
        loan.isCollateralErc20,
        loan.active,
        loan.repaid
    );
}

    function claimCollateral(uint _loanId) external onlyActiveLoan(_loanId) {
        Loan storage loan = loans[_loanId];

        require(
            block.timestamp > loan.fundingDeadline && !loan.repaid,
            "Loan is still active or already repaid"
        );

        // Only the lender can claim collateral
        require(
            msg.sender == loan.lender,
            "Only the lender can claim collateral"
        );

        // Transfer collateral to the lender
        if (loan.isCollateralErc20) {
            // If collateral is ERC20
            require(
                IERC20(loan.collateral).transfer(
                    msg.sender,
                    loan.collateralAmount
                ),
                "Failed to transfer ERC20 collateral"
            );
        } else {
            // If collateral is ERC721 NFT
            IERC721(loan.collateral).transferFrom(
                address(this),
                msg.sender,
                loan.collateralAmount
            );
        }

        // Update loan status
        loan.active = false;

        // Whitelist the borrower as a defaulter
        defaulters[loan.borrower] += 1 ;
        outstanding[loan.borrower] = false;

        // Emit event
        emit CollateralClaimed(_loanId, msg.sender);
    }


// allows loan creator to withdraw his collaterals in case no one funds his loan
    function withdrawFunds(uint _loanId) external onlyBorrower(_loanId) {
        Loan storage loan = loans[_loanId];
        require(loan.collateralAmount !=0, "no collateral found");
        if (block.timestamp > loan.fundingDeadline){
            loan.active = false;
             if (loan.isCollateralErc20) {
            // If collateral is ERC20
            require(
                IERC20(loan.collateral).transfer(
                    msg.sender,
                    loan.collateralAmount
                ),
                "Failed to transfer ERC20 collateral"
            );
        } else {
            // If collateral is ERC721 NFT
            IERC721(loan.collateral).transferFrom(
                address(this),
                msg.sender,
                loan.collateralAmount
            );
        }
        }
        loan.active = false;
        loan.collateralAmount = 0;
        loan.collateral = address(0);      
    }

    // function withdrawServiceCharges() external onlyOwner {
    //     require(totalServiceCharges > 0, "No service charges available to withdraw");
    //     payable(owner()).transfer(totalServiceCharges);
    //     emit ServiceChargesWithdrawn(owner(), totalServiceCharges);
    //     totalServiceCharges = 0; // Reset total service charges after withdrawal
    // }

    receive() external payable{}
    fallback() external payable{}
}