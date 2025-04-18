import { createWeb3Modal, defaultConfig } from '@web3modal/ethers/react'

// 1. Get projectId at https://cloud.walletconnect.com
const projectId = '4ae4f912d4e7629aeeccff8fb3804be4'

// 2. Set chains
const mainnet = {
  chainId: 1,
  name: 'Ethereum',
  currency: 'ETH',
  explorerUrl: 'https://etherscan.io',
  rpcUrl: 'https://cloudflare-eth.com'
}

const CrossFiTestnet = {
  chainId: 4157,
  name: 'CrossFi Testnet',
  currency: 'XFI',
  explorerUrl: 'https://test.xfiscan.com',
  rpcUrl: 'https://rpc.testnet.ms'
}

// 3. Create a metadata object
const metadata = {
  name: 'Revolend',
  description: 'The ultimate efficient lending/borrowing dApp on CrossFi',
  url: 'localhost:3000', // origin must match domain & subdomain
  icons: ['https://supposed-emerald-snake.myfilebase.com/ipfs/QmXpFX8TmiGTuQywDF9wtkpxGBAumUua5Hn9XLRGsgyTJZ']
}

// 4. Create Ethers config
const ethersConfig = defaultConfig({
  /*Required*/
  metadata,

  /*Optional*/
  enableEIP6963: true, // true by default
  enableInjected: true, // true by default
  enableCoinbase: false, // true by default
  rpcUrl: '...', // used for the Coinbase SDK
  defaultChainId: 1, // used for the Coinbase SDK
  enableEmail: true
})

// 5. Create a Web3Modal instance
createWeb3Modal({
  ethersConfig,
  chains: [mainnet, CrossFiTestnet],
  projectId,
  enableAnalytics: true, // Optional - defaults to your Cloud configuration
  enableOnramp: true, // Optional - false as default
  themeVariables: {
    '--w3m-z-index': 9999,
    '--w3m-accent': '#00f'
  },
  defaultChain: mainnet,
  chainImages: {
    4157: 'https://supposed-emerald-snake.myfilebase.com/ipfs/QmRtvYpyfx5peFYpiBRQxmAvwNMWyr4VZ4kTb1pjo6qEXg'
  }
})

export function Web3Modal({ children }) {
  return children
}


