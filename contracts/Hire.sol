pragma solidity 0.4.21;

contract Hire{
    address public owner;
    address public employee;
    uint256 public timeframe;
    uint256 public startTime;
    uint256 public endTimestamp;
    bool public markCompleted = false;

    event _deposit(uint amount);
    event _handshake(address employee);
    event _completed();
    event _pay(uint amount);

    function Hire (uint256 _endTimestamp) public {
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

    function handShake () notOwner public {
        employee = msg.sender;
        startTime = now;
        emit _handshake(msg.sender);
    }
    
    function getTimestamp() constant internal returns (uint256) {
      return now;
    }

    function isCompleted() constant public returns (bool) {
      if (markCompleted || passedTimeFrame()) {
        return true;
      }

      return false;
    }

    function passedTimeFrame() constant public returns (bool) {
      return getTimestamp() - startTime > timeframe;
    }

    function pay() onlyEmployee public {
      uint balance = address(this).balance;
      if (passedTimeFrame()) {
        employee.transfer(balance);
        emit _pay(balance);
      } else {
        uint amountFast = balance + (balance*0.2);
        employee.transfer(amountFast);
        emit _pay(amountFast);
      }
    }

    function complete() onlyOwner onlyStarted public {
      employee.transfer(address(this).balance);
      markCompleted = true;
      emit _completed();
    }
}