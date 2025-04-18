import '@/styles/globals.css'
import { Web3Modal } from '@/context/web3modal';
export const metadata = {
  title: 'Revolend',
  description: 'The most efficient lending protocol on CrossFi featuring a lending/borrowing dApp, token, treasury'
}

export default function App({ Component, pageProps }) {
  return  <Web3Modal> <Component {...pageProps} /> </Web3Modal>
}

 