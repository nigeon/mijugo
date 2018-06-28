pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract BetFactory is Ownable {
  
  using SafeMath for uint256;

  event NewBet(uint betId, address owner, string title, uint entryPrice);
  event NewEntry(uint betId, uint entryId, address owner, string content, uint price);

  enum BetStatus { active, stopped, ended, assigned, done } //ACTIVE <-> STOPPED -> ENDED -> ASSIGNED -> DONE

  struct Bet {
    address owner;
    string title;
    uint entryPrice;
    uint raised;
    BetStatus status;
    uint[] entries;
    string winner_content;
    uint[] winners;
  }

  struct Entry {
    uint betId;
    address owner;
    string content;
    uint price;
  }

  Bet[] public bets;
  Entry[] public entries;

  mapping (uint => address) public betToOwner;

  modifier onlyOwnerOf(uint _betId) {
    require(msg.sender == betToOwner[_betId]);
    _;
  }

  function createBet(string _title, uint _entryPrice) public returns(uint) {
    uint _betId = bets.push(Bet(msg.sender, _title, _entryPrice, 0, BetStatus.active, new uint[](0), '', new uint[](0))).sub(1);
    betToOwner[_betId] = msg.sender;
    emit NewBet(_betId, msg.sender, _title, _entryPrice);

    return _betId;
  }

  function enter(uint _betId, string _content) public payable returns(uint) {
    require(bets[_betId].status == BetStatus.active);
    require(msg.value == bets[_betId].entryPrice);
    
    bets[_betId].raised.add(msg.value);
    uint _entryId = entries.push(Entry(_betId, msg.sender, _content, msg.value)).sub(1);
    bets[_betId].entries.push(_entryId);

    emit NewEntry(_betId, _entryId, msg.sender, _content, msg.value);

    return _entryId;
  }

  function stop(uint _betId) public onlyOwnerOf(_betId){
    bets[_betId].status = BetStatus.stopped;
  }

  function end(uint _betId, string _winner_content) public onlyOwnerOf(_betId){
    require(bets[_betId].status == BetStatus.stopped);
    
    bets[_betId].status = BetStatus.ended;
    bets[_betId].winner_content = _winner_content;
  }

  function assignPrices(uint _betId) public onlyOwnerOf(_betId){
    require(bets[_betId].status == BetStatus.ended);

    bets[_betId].status = BetStatus.assigned;

    //Getting the winners looping through entries
    for (uint i = 0; i < bets[_betId].entries.length; i++) {  
      uint _entryId = bets[_betId].entries[i];
      if(keccak256(entries[_entryId].content) == keccak256(bets[_betId].winner_content)){
        bets[_betId].winners.push(i);
      }
    }
  }

  function sendPrices(uint _betId) public onlyOwnerOf(_betId){
    require(bets[_betId].status == BetStatus.assigned);

    bets[_betId].status = BetStatus.done;

    if(bets[_betId].winners.length > 0){
      uint each_prize = bets[_betId].raised.div(bets[_betId].winners.length);

      for(uint i = 0; i < bets[_betId].winners.length; i++){
        uint _entryId = bets[_betId].winners[i];
        require(entries[_entryId].owner.send(each_prize));
      }
    }

  }

}