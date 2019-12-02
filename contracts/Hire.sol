pragma solidity ^0.5.0;

contract Hire{

    address public owner;
    address payable public employee;
    uint256 public timeframe;
    uint256 public startTime;
    uint256 public endTimestamp;
    bool public markCompleted = false;
    bool public goodWork = false;
    bool public badWork = false;
    bool public extraFast = false;

    event _deposit(uint amount);
    event _handshake(address payable employee);
    event _completed();
    event _pay();

    constructor (uint256 _endTimestamp) public {
      owner = msg.sender;
      endTimestamp = _endTimestamp;
      startTime = getTimestamp();
      timeframe = _endTimestamp - getTimestamp();
    }

    modifier onlyStarted() {
      require(startTime > 0);
      _;
    }

    modifier onlyOwner() {
      require(owner == msg.sender);
      _;
    }

    modifier onlyEmployee() {
      require(employee == msg.sender);
      _;
    }

    modifier notOwner() {
      require(owner != msg.sender);
      _;
    }

    modifier onlyComplete() {
      require(markCompleted == true);
      _;
    }

    function deposit() onlyOwner payable public {
      emit _deposit(msg.value);
    }

    function handShake () notOwner public {
        employee = msg.sender;
        startTime = now;
        emit _handshake(msg.sender);
    }
    
    function getTimestamp() view internal returns (uint256) {
      return now;
    }

    function isCompleted() view public returns (bool) {
      if (markCompleted || passedTimeFrame()) {
        return true;
      }
      return false;
    }

    function passedTimeFrame() view public returns (bool) {
      return getTimestamp() - startTime > timeframe;
    }

    function pay() onlyEmployee onlyComplete public {
      uint balance = address(this).balance;
      if (passedTimeFrame()) {
        if(goodWork){
          balance = balance * 6/5;
        }
        else if(badWork){
          balance = balance * 4/5;
        }
        employee.transfer(balance);
      }
      else {
        if (((getTimestamp() - startTime) < timeframe * 3/4 ) && extraFast){
          if(!badWork){
            balance = balance * 11/10;
          }
        }
        if(goodWork){
          balance = balance * 6/5;
        }
        else if(badWork){
          balance = balance * 4/5;
        }
        employee.transfer(balance);
      }
      emit _pay();
    }

    function complete() onlyOwner onlyStarted public {
      markCompleted = true;
      emit _completed();
    }

    function markGood() onlyOwner onlyComplete public {
      goodWork = true;
    }

    function markBad() onlyOwner onlyComplete public {
      badWork = true;
    }

    function markExtraFast() onlyOwner public {
      extraFast = true;
    }
}