pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract BetFactory is Ownable {
  
  using SafeMath for uint256;

  event NewBet(uint betId, address owner, string title, uint entryPrice);
  event NewEntry(uint betId, uint entryId, address owner, string content, uint price);

  struct Bet {
    address owner;
    string title;
    uint entryPrice;
    uint raised;
    string status; //Possible Statuses: ACTIVE <-> STOPPED -> ENDED -> ASSIGNED -> DONE
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
    uint _betId = bets.push(Bet(msg.sender, _title, _entryPrice, 'ACTIVE', new uint[](0), '', new uint[](0), 0)).sub(1);
    betToOwner[_betId] = msg.sender;
    emit NewBet(_betId, msg.sender, _title, _entryPrice);

    return _betId;
  }

  function enter(uint _betId, string _content) public payable returns(uint) {
    require(bets[_betId].status == 'ACTIVE');
    require(msg.value == bets[_betId].entryPrice);
    
    bets[_betId].raised.add(msg.value);
    uint _entryId = entries.push(Entry(_betId, msg.sender, _content, msg.value)).sub(1);
    bets[_betId].entries.push(_entryId);

    emit NewEntry(_betId, _entryId, msg.sender, _content, msg.value);

    return _entryId;
  }

  function close(uint _betId) public onlyOwnerOf(_betId){
    bets[_betId].status = 'STOPPED';
  }

  function finish(uint _betId, string _winner_content) public onlyOwnerOf(_betId){
    require(bets[_betId].status == 'STOPPED');
    
    bets[_betId].status = 'ENDED'
    bets[_betId].winner_content = _winner_content;
  }

  function assignPrices(uint _betId) public onlyOwnerOf(_betId){
    require(bets[_betId].status == 'ENDED');

    bets[_betId].status = 'ASSIGNED';

    //Getting the winners looping through entries
    for (uint i = 0; i < bets[_betId].length; i++) {  
      if(bets[_betId].entries[i].content == bets[_betId].winner_content){
        winners.push(i);
      }
    }
  }

  function sendPrices(uint _betId) public onlyOwnerOf(_betId){
    require(bets[_betId].status == 'ASSIGNED');

    bets[_betId].status = 'DONE';

    if(bets[_betId].winners.length > 0){
      uint each_prize = raised.div(bets[_betId].winners.length);

      for(uint i = 0; i < bets[_betId].winners.length; i++){
        require(bets[_betId].entries[bets[_betId].winners[i]].owner.send(each_prize));
      }
    }

  }

  /**
   * Struct UnPacker
   * TODO: IS THIS ONLY NEEDED/USED IN THE SOLIDITY TESTS?
   */
  function getBet(uint _betId) external view returns (address, string, uint, bool, bool, bool, string) {
    return (bets[_betId].owner, bets[_betId].title, bets[_betId].entryPrice, bets[_betId].active, bets[_betId].finished, bets[_betId].prices_sent, bets[_betId].winner_content);
  }

  /**
   * Struct UnPacker
   * TODO: IS THIS ONLY NEEDED/USED IN THE SOLIDITY TESTS?
   */
  function getEntry(uint _entryId) external view returns (uint, address, string, uint) {
    return (entries[_entryId].betId, entries[_entryId].owner, entries[_entryId].content, entries[_entryId].price);
  }
}