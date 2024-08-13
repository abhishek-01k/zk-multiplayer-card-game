# ZkShuffle Multiplayer card game

**Play, Shuffle, Win – All While Keeping Your Hand Secure with zkShuffle!**

## Overview
The zkShuffle Card Game is a decentralized, multiplayer card game built on blockchain technology. Utilizing the zkShuffle SDK by Manta Network, this game ensures complete privacy for player hands, allowing for a secure and anonymous gaming experience. The game features advanced functionalities, including multiplayer lobbies, multiple decks, in-game tokens, AI opponents, player statistics, and live streaming.

## Features

- **Privacy-Preserving Gameplay**: With zkShuffle by Manta Network, players' hands remain private throughout the game.
- **Multiplayer Lobbies**: Create or join lobbies and challenge other players in real-time.
- **Multiple Deck Choices**: Choose from a variety of decks to keep the game interesting.
- **In-Game Tokens**: Earn tokens as you play, which can be used for various in-game activities or traded.
- **AI Opponents**: Challenge AI-driven opponents if you prefer single-player modes.
- **Player Statistics**: Track your performance with detailed statistics on wins, losses, and more.
- **Live Streaming**: Watch live games and learn from other players' strategies.

## Smart Contract Overview

![Screenshot 2024-08-13 221326](https://github.com/user-attachments/assets/608156b7-fdcd-4326-86a3-269e432a27bc)

### `ShuffleGameInfo`
A struct that holds immutable information about each game:
- `numCards`: The total number of cards in the game.
- `numPlayers`: The total number of players participating in the game.
- `encryptVerifier`: The verifier for encryption, ensuring the privacy of each player's hand.

### `cardConfig()`
```solidity
function cardConfig() external override view returns (DeckConfig);
```
Returns the configuration of the deck used in the game. This includes details like the number of cards, the type of deck, and more.

### `startGame()`
```solidity
function startGame() external;
```
Initiates the game once all players are ready. The function handles the deck shuffling, ensuring that no player can see another player's hand.

### `playCard(uint8 cardIndex)`
```solidity
function playCard(uint8 cardIndex) external;
```
Allows a player to play a card from their hand. The card is revealed to other players, but the remaining hand remains private.

### `endGame()`
```solidity
function endGame() external;
```
Concludes the game, distributing rewards based on the players' performances.

### `joinLobby(uint8 lobbyId)`
```solidity
function joinLobby(uint8 lobbyId) external;
```
Allows a player to join an existing lobby. If the lobby is full, the player will need to choose another one.

## How the DApp Works

1. **Lobby Creation and Joining**: Players can either create a new lobby or join an existing one. Each lobby supports a set number of players.

2. **Deck Selection**: Once the lobby is full, players select their preferred decks. The `cardConfig()` function ensures that all players have the correct deck configuration.

3. **Game Start**: The `startGame()` function shuffles the deck and deals the cards, ensuring that each player's hand remains private through zkShuffle.

4. **Gameplay**: Players take turns playing cards by invoking the `playCard(uint8 cardIndex)` function. The played card is revealed to all, but the rest of the player's hand remains private.

5. **Game End**: The game ends when all rounds are completed or a player reaches the win condition. The `endGame()` function then distributes rewards, including in-game tokens.

6. **Statistics and Streaming**: Player statistics are updated after each game, and live streaming options allow others to watch ongoing games.

![Screenshot 2024-08-13 221520](https://github.com/user-attachments/assets/5a4fa26b-6c0e-4ac6-8afa-9ec269359a53)

## Privacy with zkShuffle by Manta Network

The core privacy feature of the game is powered by zkShuffle, an SDK developed by Manta Network. zkShuffle uses zero-knowledge proofs (zk-SNARKs) to shuffle and encrypt the deck of cards in such a way that no player, including the one initiating the shuffle, can determine the order of cards.

### How Privacy is Maintained:

- **Zero-Knowledge Proofs**: zkShuffle ensures that the shuffle and distribution of cards are done in a manner that preserves player anonymity.
- **Encryption**: Each player's hand is encrypted, and only the respective player can decrypt their cards. This is verified by the `encryptVerifier` in the `ShuffleGameInfo` struct.
- **Verifiable Randomness**: The shuffle process is both random and verifiable, ensuring fairness without revealing any player's hand.

By combining blockchain technology with zkShuffle, this game guarantees that your strategies and cards remain secure and private, making it a truly decentralized and trustless experience.

## Getting Started

To start playing the zkShuffle Card Game, follow these steps:

1. **Clone the Repository**: `git clone https://github.com/YourRepo/zkShuffleGame.git`
2. **Install Dependencies**: `npm install` or `yarn install`
3. **Compile Contracts**: `npx hardhat compile`
4. **Deploy Contracts**: `npx hardhat run scripts/deploy.js`
5. **Start the Frontend**: `npm start` or `yarn start`

Enjoy the game and may the best strategist win!
