// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@zk-shuffle/contracts/contracts/shuffle/IShuffleStateManager.sol";
import "@zk-shuffle/contracts/contracts/shuffle/IBaseGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ZkShuffleGame is Ownable {

    enum GameState { WaitingForPlayers, Shuffling, Dealing, InProgress, Finished }

    struct Player {
        address playerAddress;
        bool hasJoined;
        uint256 hand;
    }

    GameState public gameState;
    Player[] public players;
    uint256 public maxPlayers;
    uint256 public pot;

    event PlayerJoined(address indexed player);
    event GameStarted();
    event PlayerHandDealt(address indexed player, uint256 hand);
    event GameEnded(address indexed winner, uint256 pot);

        IShuffleStateManager public zkShuffle;
    constructor(uint256 _maxPlayers, address owner) Ownable(owner) {
        maxPlayers = _maxPlayers;
        gameState = GameState.WaitingForPlayers;
    }

    function joinGame() external payable {
        require(gameState == GameState.WaitingForPlayers, "Game is not accepting players");
        require(players.length < maxPlayers, "Game is full");
        require(!isPlayerInGame(msg.sender), "Player already in game");

        players.push(Player({
            playerAddress: msg.sender,
            hasJoined: true,
            hand: 0
        }));

        pot += msg.value;
        emit PlayerJoined(msg.sender);

        if (players.length == maxPlayers) {
            startGame();
        }
    }

    function startGame() internal {
        gameState = GameState.Shuffling;
        emit GameStarted();
        zkShuffle.shuffle();
    }

    function dealHands() external onlyOwner {
        require(gameState == GameState.Shuffling, "Game is not in shuffling state");

        for (uint256 i = 0; i < players.length; i++) {
            players[i].hand = zkShuffle.dealCard();
            emit PlayerHandDealt(players[i].playerAddress, players[i].hand);
        }

        gameState = GameState.InProgress;
    }

    function endGame(uint256 winnerIndex) external onlyOwner {
        require(gameState == GameState.InProgress, "Game is not in progress");
        
        Player memory winner = players[winnerIndex];
        require(winner.hasJoined, "Winner must be a player");

        payable(winner.playerAddress).transfer(pot);
        emit GameEnded(winner.playerAddress, pot);

        gameState = GameState.Finished;
    }

    function isPlayerInGame(address player) internal view returns (bool) {
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i].playerAddress == player) {
                return true;
            }
        }
        return false;
    }
}
