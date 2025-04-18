import { useState, useEffect } from "react";
import {
    tokenContractAddress,
    tokenContractABI,
    lendBorrowContractABI,
    lendBorrowContractAddress,
    usdtContractAddress,
    usdtContractABI,
    daiContractAddress,
    daiContractABI, 
  } from "@/abiAndContractSettings";
    import { useWeb3ModalProvider, useWeb3ModalAccount } from '@web3modal/ethers/react'
    import { BrowserProvider, Contract, formatUnits } from 'ethers'

    export default function MyBalancesSection({displayComponent, setDisplayComponent, changeBg3, changeBg4}) {
               // wallet connect settings
               const { address, chainId, isConnected } = useWeb3ModalAccount()
               const { walletProvider } = useWeb3ModalProvider()

              // lets read data for the Metrics section using inbuilt functions and abi related read functions
               const [NXFBalance, setNXFBalance] = useState()
               const [tokenPrice, setTokenPrice] = useState()
               const [userXFIBalance, setuserXFIBalance] = useState()
               const [userCreatedLoans, setuserCreatedLoans] = useState()
               const [userFundedLoans, setuserFundedLoans] = useState()
   
               useEffect(()=>{
                const getUserData = async() => {
                    if(isConnected){
                    //read settings first
                    const ethersProvider = new BrowserProvider(walletProvider) 
                    const tokenContractReadSettings = new Contract(tokenContractAddress, tokenContractABI, ethersProvider)
                    const usdtContractReadSettings = new Contract(usdtContractAddress, usdtContractABI, ethersProvider)
                    const daiContractReadSettings = new Contract(daiContractAddress, daiContractABI, ethersProvider)
                    const lendBorrowContractReadSettings = new Contract(lendBorrowContractAddress, lendBorrowContractABI, ethersProvider)
                  try {
                    const getNXFBalance = await tokenContractReadSettings.balanceOf(address)
                    console.log(getNXFBalance)
                    setNXFBalance(getNXFBalance.toString() * 10**-18)
                    setTokenPrice(parseFloat(0.1).toFixed(10))
                    const XFIbalance = await ethersProvider.getBalance(address)   
                    console.log(XFIbalance)
                    setuserXFIBalance(formatUnits(XFIbalance, 18))
                    const userCreatedLoanArray = []
                    const userFundedLoanArray = []
                    const getAllLoannsNumber = await lendBorrowContractReadSettings.loanCount();
                    for (let i=0; i < getAllLoannsNumber; i++){
                      const allLoansData = await lendBorrowContractReadSettings.getLoanInfo(i);
                      if (allLoansData.borrower.toString().toLowerCase() === address.toLowerCase()){
                        userCreatedLoanArray.push(allLoansData)
                      }
                      else if (allLoansData.lender.toString().toLowerCase() === address.toLowerCase()){
                        userFundedLoanArray.push(allLoansData)
                      }
                    }
                    setuserCreatedLoans(userCreatedLoanArray.length)
                    setuserFundedLoans(userFundedLoanArray.length)
                  } catch (error) {
                    console.log(error)
                  }
                }
                }
                getUserData();  
               }, [isConnected, address])
    
    return (
        <div>
        <div className="font-[500] bg-[#502] px-[0.4cm] py-[0.15cm] rounded-md mb-[0.2cm]" style={{display:"inline-block", boxShadow:"2px 2px 2px 2px #333"}}>My Balances</div>
        <div className="text-[#ccc] text-[90%]">Manage all your assets on Revolend</div>
        <div className="text-center mt-[0.4cm]">
            <div className="text-center m-[0.4cm]" style={{display:"inline-block"}}>
                <div className="font-[500] text-[110%]">NXF Balance</div>
                {NXFBalance > 0 ? (<div className="text-[#aaa]">{Intl.NumberFormat().format(parseFloat(NXFBalance).toFixed(10))} NXF</div>) : (<span>0</span>)}
            </div>
            <div className="text-center m-[0.4cm]" style={{display:"inline-block"}}>
                <div className="font-[500] text-[110%]">NXF Price</div>
                {tokenPrice ? (<div className="text-[#aaa]">≈ ${tokenPrice}</div>) : (<span>0</span>)}
            </div>
            <div className="text-center m-[0.4cm]" style={{display:"inline-block"}}>
                <div className="font-[500] text-[110%]">XFI Balance</div>
                {userXFIBalance > 0 ? (<div className="text-[#aaa]">{parseFloat(userXFIBalance).toFixed(10)} XFI</div>) : (<span>0</span>)}
            </div>
            <div className="text-center m-[0.4cm]" style={{display:"inline-block"}}>
                <div className="font-[500] text-[110%]">Loans you Created</div>
                {userCreatedLoans > 0 ? (<div className="text-[#aaa]">{Intl.NumberFormat().format(userCreatedLoans)}</div>) : (<span>0</span>)}
            </div>
            <div className="text-center m-[0.4cm]" style={{display:"inline-block"}}>
                <div className="font-[500] text-[110%]">Loans you Funded</div>
                {userFundedLoans > 0 ? (<div className="text-[#aaa]">{Intl.NumberFormat().format(userFundedLoans)}</div>) : (<span>0</span>)}
            </div>
        </div>
        <div className="grid lg:grid-cols-2 grid-cols-1 gap-4 mt-[1cm]">
            <div className="grid-cols-1 bg-[#000] p-[0.5cm] rounded-xl" style={{boxShadow:"2px 2px 2px 2px #333"}}>
                <div className="font-[500] text-[#fff] bg-[#502] px-[0.4cm] py-[0.1cm] rounded-md mb-[0.2cm]" style={{display:"inline-block"}}>$NXF</div>
               <div className="text-[#ccc] font-[500] underline">What is NXF?</div>
               <div className="text-[#aaa] text-[90%]">
               NXF is the native token of Revolend. NXF is used as a collateral for lending. NXF shall also be used to reward community members in potential airdrops 
                organised by the platform in the future.
               </div>
               <button onClick={(e) => setDisplayComponent("daogovernance") & changeBg3(e)} className="text-center px-[0.4cm] py-[0.2cm] bg-[#502] w-[100%] mt-[0.3cm] generalbutton text-[#fff] rounded-md">Buy NXF</button>
            </div>
            <div className="grid-cols-1 bg-[#000] p-[0.5cm] rounded-xl" style={{boxShadow:"2px 2px 2px 2px #333"}}>
                <div className="font-[500] text-[#fff] bg-[#502] px-[0.4cm] py-[0.1cm] rounded-md mb-[0.2cm]" style={{display:"inline-block"}}>P2P Lending/Borrowing</div>
                <div className="text-[#ccc] font-[500] underline">What is P2P lending/borrowing?</div>
                <div className="text-[#aaa] text-[90%]">
                Revolend users are able to participate in unique P2P lending/borrowing activities of supported tokens. 
                Firstly, a loan has to be created by the borrower, then another user (the lender) funds the loan by lending to the borrower. The loan has the 
                following characteristics: loan amount, interest, expiry date, and collateral. Collateral provided by the borrower is locked up by the system until the given active loan duration expires.
                 The collateral is sent out to the lender if the borrower fails to repay the loan during the specified time. Simultaneously, if there is no lender, the borrower can claim his collateral back.
                </div>
                <button onClick={(e) => setDisplayComponent("lend") & changeBg3(e)} className="text-center px-[0.4cm] py-[0.2cm] lg:float-left bg-[#502] lg:w-[49%] w-[100%] mt-[0.3cm] generalbutton text-[#fff] rounded-md">Lend Now</button>
                <button onClick={(e) => setDisplayComponent("borrow") & changeBg4(e)} className="text-center px-[0.4cm] py-[0.2cm] lg:float-right bg-[#502] lg:w-[49%] w-[100%] mt-[0.3cm] generalbutton text-[#fff] rounded-md">Borrow Now</button>
            </div>
        </div>
        </div>
    )
}