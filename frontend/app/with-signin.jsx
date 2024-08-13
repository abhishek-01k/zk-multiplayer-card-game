'use client'
import { useRef, useEffect, useState } from 'react'
import useLocalStorageState from 'use-local-storage-state'
import useSWR from 'swr'

import { createThirdwebClient } from 'thirdweb'
import { createWallet, walletConnect } from 'thirdweb/wallets'
import { ConnectButton, useActiveWallet } from 'thirdweb/react'

export default function WithSignined({
  children
}) {
  const [ userInfo, setUserInfo ] = useLocalStorageState('userinfo', { defaultValue: { id: -1 } })
  // const [ userInfo, setUserInfo ] = useState(null)

  const wallet = useActiveWallet();

  console.log(wallet,"wallet")

  const account = wallet?.getAccount();

  const walletAccount = {
    address : account ? account.address : ""
  };

  const client = createThirdwebClient({
    clientId: process.env.NEXT_PUBLIC_THIRDWEB_CLIENT,
  });
  
  console.log(walletAccount.address,"addre",);

  const wallets = [
    createWallet("io.metamask"),
    createWallet("com.coinbase.wallet"),
    walletConnect(),
  ];


  const dealerRef = useRef(null)

  useEffect(() => {
    const handler = event => {
      if(dealerRef.current) {
        const { pageX, pageY } = event
        const { innerWidth, innerHeight } = window
        dealerRef.current.style.transform = `translate3d(${
          Math.min(Math.max(-20, (pageX - innerWidth / 2) / 30), 20)
        }px, ${
          Math.min(Math.max(-5, (pageY - innerHeight / 2) / 50), 5)
        }px, 0px)`
      }
    }
    document.documentElement.addEventListener('mousemove', handler)
    return () => {
      document.documentElement.removeEventListener('mousemove', handler)
    }
  }, [ dealerRef.current ])

  if(userInfo?.token) {
    return (
      <div className='relative mt-36 w-[1280px] mx-auto'>
        {children(userInfo)}
        <h1>You are connected</h1>
      </div>
    )
  }

  return (
    <div className='bg-white w-[1280px] h-[720px] overflow-hidden mx-auto my-8 px-4 py-2 rounded-lg bg-cover bg-[url("/bg-2.jpg")] relative shadow-[0_0_20px_rgba(0,0,0,0.8)]'>
      {/* <div className='absolute top-5 left-5 w-40 h-40 bg-no-repeat bg-[url("/logo.png")]'></div> */}
      <div className='absolute inset-0 bg-no-repeat bg-[url("/table-1.png")]'></div>
      <div className='absolute left-8 -right-8 top-14 -bottom-14 bg-no-repeat bg-[url("/dealer.png")] transform-gpu' ref={ dealerRef }>
        <div className='absolute -left-8 right-8 -top-14 bottom-14 bg-no-repeat bg-[url("/card-0.png")] animate-floating'></div>
      </div>
      <div className='absolute top-0 left-1/2 right-0 bottom-0 pr-20 py-12'>
        <div className='relative text-center flex justify-center'>
          <img src='/login-button-bg.png' />
          <ConnectButton
            client={client}
            wallets={wallets}
            theme={"dark"}
            connectModal={{ size: "wide" }}
          />
        </div>
      </div>
    </div>
  )
}