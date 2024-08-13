// @ts-nocheck
"use client";

import { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import {
    Alert,
    AlertDescription,
    AlertTitle,
  } from "@/components/ui/alert"
import { Button } from "@/components/ui/button";
import {
    Card,
    CardContent,
    CardDescription,
    CardFooter,
    CardHeader,
    CardTitle,
  } from "@/components/ui/card"
  
import ZkShuffleGameABI from '@/artifacts/contracts/ZkShuffleGame.sol/ZkShuffleGame.json';

const zkShuffleGameAddress = '';

export default function Home() {
    const [gameContract, setGameContract] = useState<ethers.Contract | null>(null);
    const [players, setPlayers] = useState<string[]>([]);
    const [pot, setPot] = useState<number>(0);
    const [gameState, setGameState] = useState<string>('WaitingForPlayers');
    const [showModal, setShowModal] = useState(false);

    useEffect(() => {
        if (typeof window.ethereum !== 'undefined') {
            const newProvider = new ethers.providers.Web3Provider(window.ethereum);

            const contract = new ethers.Contract(
                zkShuffleGameAddress,
                ZkShuffleGameABI.abi,
                newProvider.getSigner()
            );
            setGameContract(contract);
        }
    }, []);

    const joinGame = async () => {
        if (!gameContract) return;
        try {
            const tx = await gameContract.joinGame({ value: ethers.utils.parseEther('0.01') });
            await tx.wait();
            alert('Successfully joined the game!');
        } catch (err) {
            console.error(err);
        }
    };

    const startGame = async () => {
        if (!gameContract) return;
        try {
            const tx = await gameContract.startGame();
            await tx.wait();
            alert('Game started!');
        } catch (err) {
            console.error(err);
        }
    };

    const dealHands = async () => {
        if (!gameContract) return;
        try {
            const tx = await gameContract.dealHands();
            await tx.wait();
            alert('Hands dealt!');
        } catch (err) {
            console.error(err);
        }
    };

    return (
        <div className="container mx-auto p-4">
            <h1 className="text-3xl font-bold">zkShuffle Card Game</h1>
            <div className="grid grid-cols-2 gap-4">
                <Card>
                    <h2 className="text-xl">Game State: {gameState}</h2>
                    <h2 className="text-xl">Pot: {pot} ETH</h2>
                    <Button onClick={joinGame}>Join Game</Button>
                    <Button onClick={startGame}>Start Game</Button>
                    <Button onClick={dealHands}>Deal Hands</Button>
                </Card>
                <Card>
                    <h2 className="text-xl">Players</h2>
                    <ul>
                        {players.map((player, index) => (
                            <li key={index}>{player}</li>
                        ))}
                    </ul>
                </Card>
            </div>
            <div show={showModal} onClose={() => setShowModal(false)}>
                <Alert variant="success">Game Finished!</Alert>
            </div>
        </div>
    );
}
