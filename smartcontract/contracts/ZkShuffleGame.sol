// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@zk-shuffle/contracts/contracts/shuffle/IShuffleStateManager.sol";
import "@zk-shuffle/contracts/contracts/shuffle/IBaseGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract ZkShuffleGame is IBaseGame, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    enum GameState { WaitingForPlayers, Shuffling, Dealing, InProgress, Finished }

    struct Player {
        address playerAddress;
        uint256 hand;
        bool isAI;
        bool hasJoined;
    }

    GameState public gameState;
    Player[] public players;
    uint256 public maxPlayers;
    uint256 public pot;
    DeckConfig public deckConfig;
    EnumerableSet.AddressSet private activePlayers;

    IShuffleStateManager public zkShuffle;
    uint256 public gameId;

    event PlayerJoined(address indexed player);
    event GameStarted();
    event PlayerHandDealt(address indexed player, uint256 hand);
    event GameEnded(address indexed winner, uint256 pot);

    constructor(uint256 _maxPlayers, DeckConfig _deckConfig, address _zkShuffleAddress) Ownable(msg.sender) {
        require(_maxPlayers > 0, "Max players must be greater than zero");
        require(_zkShuffleAddress != address(0), "Invalid Shuffle Manager address");

        maxPlayers = _maxPlayers;
        gameState = GameState.WaitingForPlayers;
        deckConfig = _deckConfig;
        zkShuffle = IShuffleStateManager(_zkShuffleAddress);
    }

    function joinGame() external payable {
        require(gameState == GameState.WaitingForPlayers, "Game is not accepting players");
        require(players.length < maxPlayers, "Game is full");
        require(!isPlayerInGame(msg.sender), "Player already in game");

        players.push(Player({
            playerAddress: msg.sender,
            hand: 0,
            isAI: false,
            hasJoined: true
        }));

        activePlayers.add(msg.sender);
        pot += msg.value;
        emit PlayerJoined(msg.sender);

        if (players.length == maxPlayers) {
            startGame();
        }
    }

    function addAIPlayer() external onlyOwner {
        require(gameState == GameState.WaitingForPlayers, "Game is not accepting players");
        require(players.length < maxPlayers, "Game is full");

        players.push(Player({
            playerAddress: address(0),
            hand: 0,
            isAI: true,
            hasJoined: true
        }));

        if (players.length == maxPlayers) {
            startGame();
        }
    }

    function startGame() internal {
        gameState = GameState.Shuffling;
        emit GameStarted();

        gameId = zkShuffle.createShuffleGame(uint8(players.length));

        bytes memory next = abi.encodeWithSelector(this.dealHands.selector);
        zkShuffle.shuffle(gameId, next);
    }

    function dealHands() external onlyOwner {
        require(gameState == GameState.Shuffling, "Game is not in shuffling state");

        for (uint256 i = 0; i < players.length; i++) {
            uint256 playerId = zkShuffle.getPlayerIdx(gameId, players[i].playerAddress);
            BitMaps.BitMap256 memory dealtCards = zkShuffle.getDecryptRecord(gameId, playerId);
            players[i].hand = uint256(dealtCards._data); // This is a simplification; actual implementation depends on the card data.
            emit PlayerHandDealt(players[i].playerAddress, players[i].hand);
        }

        gameState = GameState.InProgress;
    }

    function cardConfig() external override view returns (DeckConfig) {
        return deckConfig;
    }

    function endGame(uint256 winnerIndex) external onlyOwner {
        require(gameState == GameState.InProgress, "Game is not in progress");
        require(winnerIndex < players.length, "Invalid winner index");

        Player memory winner = players[winnerIndex];
        require(winner.hasJoined, "Winner must be a player");

        if (winner.isAI) {
            activePlayers.remove(address(0));
        } else {
            activePlayers.remove(winner.playerAddress);
            payable(winner.playerAddress).transfer(pot);
        }

        emit GameEnded(winner.playerAddress, pot);

        gameState = GameState.Finished;
    }

    function isPlayerInGame(address player) internal view returns (bool) {
        return activePlayers.contains(player);
    }

    function allowJoinGame() external onlyOwner {
        require(gameState == GameState.WaitingForPlayers, "Game not waiting for players");
        bytes memory next = abi.encodeWithSelector(this.moveToShuffleStage.selector);
        zkShuffle.register(gameId, next);
    }

    function moveToShuffleStage() external onlyOwner {
        require(gameState == GameState.WaitingForPlayers, "Game not in waiting state");
        bytes memory next = abi.encodeWithSelector(this.dealHands.selector);
        zkShuffle.shuffle(gameId, next);
    }
}
