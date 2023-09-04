//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
import {IStandardToken} from "./IStandardToken.sol";


// allow users to stake standardToken
//able to view the total amount stake by any user
//allows user to be able withdraw their stake amount

contract StakingContract{
    IStandardToken standardToken;
struct User{
    uint amountStaked;
    uint timeStaked;
    uint reward;
}
// 0.1 = 10%
  uint256 public rewardPercentage;

mapping (address => User) user;

event Staked(uint amountstake, uint totalAmountStaked, uint time);
// allow users to stake standardToken

//set the address of the Token to be staked
constructor(address _standardToken, uint256 _rewardPercentage){
    standardToken = IStandardToken(_standardToken);
    rewardPercentage = _rewardPercentage;
}
    function stake(uint amount) external {
        uint balance = standardToken.balanceOf(msg.sender);
        require(balance >=  amount, "ERC20 insuficient balance");
        //make external call to standardToken by calling transferfrom;
        bool status = standardToken.transferFrom(msg.sender, address(this), amount);
        require(status == true, "transfer Failed");
        //update state after confirming transfer of standardToken
        User storage _user = user[msg.sender];
        _user.reward += calcReward();
        _user.amountStaked += amount;
        _user.timeStaked = block.timestamp;
        emit Staked(amount, _user.amountStaked, block.timestamp);
    }

    function getStakeAmount(address who) public view returns(uint _staked){
        User storage _user = user[who];
      _staked = _user.amountStaked;
    }

    function withdraw(uint amount) external{
         uint totalStaked = getStakeAmount(msg.sender);
         require(totalStaked >= amount, "insufficent stake amount");
         User storage _user = user[msg.sender];
         _user.amountStaked -= amount;
         standardToken.transfer(msg.sender, amount);

    }

    function withdrawEther()  external{
        standardToken.withdrawEther();
        payable(msg.sender).transfer(address(this).balance);
    }

   function calcReward() public view returns(uint256) {
     User storage _user = user[msg.sender];
     uint256 stakeDuration = block.timestamp - _user.timeStaked;
     return _user.amountStaked * rewardPercentage * stakeDuration;
   } 

    function getStakedReward() public view {
      User storage _user = user[msg.sender];
      uint256 SReward = _user.reward + calcReward();
      require(SReward > 0, "You did not stake");
    }
    
    receive() external payable{}
    fallback() external payable{}
}