import Head from 'next/head';
import { useState, useEffect } from "react";
import Link from 'next/link';
import AOS from 'aos';
import 'aos/dist/aos.css';
import axios from 'axios';
import Header from '@/components/header';
import { useRouter } from 'next/router';

export default function Home(){
  useEffect(() => {
    AOS.init();
  }, [])

  // create countdown for dashboard navigation
  const [count, setCount] = useState(60);
  useEffect(() => {
    const countdownInterval = setInterval(() => {
      setCount((prevCount) => prevCount - 1);
    }, 1000);

    // Clear the interval when the component is unmounted
    return () => clearInterval(countdownInterval);
  }, []);

  //navigate to dashboard page
  const [allowAutoNav, setAllowAutoNav] = useState(true);
  const router = useRouter();
  useEffect(() => {
    const autoNav = allowAutoNav && setTimeout(() => {
      router.push("/dashboard");
    }, 60000);

    // Cleanup function to clear the timeout when the component is unmounted or auto navigation is stopped
    return () => clearTimeout(autoNav);
}, [allowAutoNav, router])

  //stop navigation to dashboard page
  const stopNav = () => {
    setAllowAutoNav(false)
  }

  return (
    <>
    <Head>
   <title>Revolend - The ultimate efficient lending/borrowing dApp on CrossFi'</title>
   <link rel="shortcut icon" href="/favicon.ico" />
   </Head>
   <div>
   <Header />
   <div className='lg:mx-[8%] mx-[5%] pt-[3cm]'>


   <div className='lg:mx-[-8%] mx-[-5%] lg:pb-[50%] pb-[100%] firstsectiondiv' style={{backgroundImage:"url(images/bg7.jpg)", transition:"0.3s ease-in-out"}}>
   <div className='text-center text-[170%] lg:text-[230%] md:text-[180%] pt-[1.5cm] font-[500]'>Mass Adoption of EVM-compatible Technologies on CrossFi</div>
   <div className='mt-[1cm] text-center lg:text-[140%] text-[120%] lg:mx-[20%] md:mx-[10%] mx-[5%] p-[0.5cm] lg:px-[2cm] text-[#ccc] bg-[rgba(0,0,0,0.95)]' style={{border:"1px solid #502"}}>
    <div data-aos="fade-in" className='info1' style={{transition:"0.5s ease-in-out"}}>
      Lending: Using supported tokens, CrossFi users can engage in peer-to-peer lending and borrowing activities on our unique P2P lending/borrowing dApp. 
      Lending on CrossFi yields substantial interest rewards. Our lending/borrowing dApp is designed to be user-friendly with a decentralised chat system
      and search functionalities and paginations. Our well-audited security algorithm protects your money at all cost.
    </div>
    <div data-aos="fade-in" className='info2' style={{transition:"0.5s ease-in-out"}}>
      Borrowing: To borrow on CrossFi, all a user has to do is to create a loan from the Borrow section, presenting a collateral, and pay back with interest when you repay the amount.
      A lender lends to the borrower in due time. For a smooth user experience, a "view all available loans section" and "view your loans section" have been created.
    </div>
   </div>
   <div className='mt-[1cm] text-center' style={{transition:"0.3s ease-in-out"}}>
    <Link href="/dashboard"><button className='m-[0.2cm] rounded-md bg-[#502] px-[0.3cm] py-[0.2cm] text-[#fff] generalbutton ecobutton' style={{border:"2px solid #502"}}>Explore dApp <img src="images/blockchain.png" width="25" className='ml-[0.2cm]' style={{display:"inline-block"}}/></button></Link>
    <Link href="https://github.com/jerydam/Revolend/blob/master/README.md"><button className='m-[0.2cm] rounded-md bg-[#111] px-[0.3cm] py-[0.2cm] text-[#fff] generalbutton docbutton' style={{border:"2px solid #502"}}>Documentation <img src="images/documentation.png" width="25" className='ml-[0.2cm]' style={{display:"inline-block"}}/></button></Link>
   </div>
   {allowAutoNav ? (<div className='text-center mt-[1cm] text-[#000]'>You will be automatically navigated to the dashboard in {count} seconds....</div>) : 
   (<div className='text-center mt-[1cm] text-[#000] font-[500]'>Auto-navigation cancelled....</div>)}
   <div className='text-center'>
    {allowAutoNav ? (<button onClick={(e) => stopNav(e)} className='fa-fade mt-[0.5cm] rounded-md bg-[#fff] px-[0.3cm] py-[0.2cm] text-[#001]' style={{boxShadow:"2px 2px 2px 2px #502", animationDuration:"5s"}}>Cancel auto-navigation</button>) : (<span></span>)}
   </div>
   </div>

   </div>
   </div>
  </>
  );
};

