// SPDX-License-Identifier: unlicensed
/*
For test 
AIICF Contract + Token
*/
pragma solidity >=0.4.0 <0.9.0;
pragma solidity ^0.5.00;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal returns (uint256) {
         assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
         assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    function sub(uint256 a, uint256 b) internal returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control 
 * functions, this simplifies the implementation of "user permissions". 
 */
contract Ownable {
    address public owner;
    /** 
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
     constructor() public{
        owner = msg.sender;
    }
    /**
    * @dev Throws if called by any account other than the owner. 
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to. 
    */
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}
/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20Basic {
    uint256 public totalSupply;
   function balanceOf(address account) external view returns (uint256);
  //  function balanceOf(address who) constant returns (uint256);
    function transfer(address to, uint256 value) public;
    event Transfer(address indexed from, address indexed to, uint256 value);
}
/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
   function allowance(address _owner, address spender) external view returns (uint256);
   // function allowance(address owner, address spender) constant returns (uint256);
    function transferFrom(address from, address to, uint256 value)public;
    function approve(address spender, uint256 value)public;
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) balances;
    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public{
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
    }
    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of. 
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) external view returns (uint256 balance) {
        return balances[_owner];
    }
}
/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {
    mapping (address => mapping (address => uint256)) allowed;
    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amout of tokens to be transfered
    */
    function transferFrom(address _from, address _to, uint256 _value) public{
        uint256 _allowance = allowed[_from][msg.sender];
        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // if (_value > _allowance) throw;
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        emit Transfer(_from, _to, _value);
    }
    /**
    * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) public{
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
    }
    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifing the amount of tokens still avaible for the spender.
    */
    function allowance(address _owner, address _spender) external view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}
contract Saleshare is Ownable,StandardToken {
    using SafeMath for uint256;
 string public name = "AIICFToken_v0.0";
    string public symbol = "TEST0";
    uint256 public decimals = 0;
    uint256 public initialSupply = 1;
    uint256 public totalSupply=1;
    /* 
    * Stores the contribution in wei
    * Stores the amount received in TKR
    */
    struct Contributor {
        uint256 contributed;
        uint256 received;
        uint256 dividend;
    }
    /* Backers are keyed by their address containing a Contributor struct */
    mapping(address => Contributor) public contributors;
    /* Events to emit when a contribution has successfully processed */
    event TokensSent(address indexed to, uint256 value);
    event ContributionReceived(address indexed to, uint256 value);
   // event MigratedTokens(address indexed _address, uint256 value);
event DataStored(uint256 data1, bytes indexed data2);
   uint256 data1;
   uint256 data2;
    /* Constants */
    uint256 public constant TOKEN_CAP = 100000000 * 10 ** 18;
    uint256 public constant MINIMUM_CONTRIBUTION = 1**16;
    uint256 public constant TOKENS_PER_ETHER = 1000;
    uint256 public constant sharesSALE_DURATION = 14 days;
    /* Public Variables */
//    TKRToken public token;
 //   TKRPToken public preToken;
    address public sharessaleOwner;
    uint256 public etherReceived;
    uint256 public tokensSent;
    uint256 public sharessaleStartTime;
    uint256 public sharessaleEndTime;
    /* Modifier to check whether the sharessale is running */
    modifier sharessaleRunning() {
        require(now < sharessaleEndTime && sharessaleStartTime != 0);
        _;
    }
    /**
    * @dev Fallback function which invokes the processContribution function
    * param _tokenAddress TKR Token address
    * param _to sharessale owner address
    */
    constructor() public{
 //       token = this.address;
        sharessaleOwner = msg.sender;
      //  address(this).balance=0;
    }
    /**
    * @dev Fallback function which invokes the processContribution function
    */
    function() sharessaleRunning payable external{
        processContribution(msg.sender);
        require(msg.data.length == 0); emit DataStored(msg.value,msg.data);
    }
 //   receive() external payable {
  //    emit  Transfer(address(this),sharessaleOwner,address(this).balance);
  // }
    /**
    * @dev Starts the sharessale
    */
    function start() onlyOwner public{
        require(sharessaleStartTime == 0);
        sharessaleStartTime = now;            
        sharessaleEndTime = now + sharesSALE_DURATION;    
    }
    /**
    * @dev A backup fail-safe drain if required
    */
    function drain() onlyOwner public{
      //  assert(sharessaleOwner.send
      msg.sender.transfer(address(this).balance);
    }
    function safeTransfer(address token, address to, uint value) onlyOwner public{
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
   
   //function rescueToken(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) {
     //   return tokenAddress.call(tokenAddress.transfer(msg.sender, tokens));
   // }
   
   
   //function drainToken(address token) onlyOwner public{
      //  assert(sharessaleOwner.send
     // msg.sender.transfer(address(token).balance);
   // }
    /**
    * @dev Finalizes the sharessale and sends funds
    */
    function finalize() onlyOwner public{
        require(sharessaleStartTime != 0 );
        msg.sender.transfer(address(this).balance);
        sharessaleStartTime=0;
    }
function deletec() onlyOwner public{
       
        msg.sender.transfer(address(this).balance);
        selfdestruct(msg.sender);
    }
   
    function processContribution(address sender) internal {
        require(msg.value >= MINIMUM_CONTRIBUTION);
        // // /* Calculate total (+bonus) amount to send, throw if it exceeds cap*/
        uint256 contributionInTokens = bonus(msg.value.mul(TOKENS_PER_ETHER).div(1 ether));
        require(contributionInTokens.add(tokensSent) <= TOKEN_CAP);
        /* Send the tokens */
      //  token.transfer(sender, contributionInTokens);
        emit Transfer(address(0), sender, contributionInTokens);
        /* Create a contributor struct and store the contributed/received values */
        Contributor storage contributor = contributors[sender];
        contributor.received = contributor.received.add(contributionInTokens);
        contributor.contributed = contributor.contributed.add(msg.value);
        // /* Update the total amount of tokens sent and ether received */
        etherReceived = etherReceived.add(msg.value);
        tokensSent = tokensSent.add(contributionInTokens);
        totalSupply=tokensSent;
        // /* Emit log events */
        balances[sender] = balances[sender].add(contributionInTokens);
        emit TokensSent(sender, contributionInTokens);
        emit ContributionReceived(sender, msg.value);
    }
    /**
    * @dev Calculates the bonus amount based on the contribution date
    * @param amount The contribution amount given
    */
    function bonus(uint256 amount) internal view returns (uint256) {
        /* This adds a bonus 20% such as 100 + 100/5 = 120 */
      //  if (now < sharessaleStartTime.add(2 days)) return amount.add(amount.div(5));
        /* This adds a bonus 10% such as 100 + 100/10 = 110 */
      //  if (now < sharessaleStartTime.add(14 days)) return amount.add(amount.div(10));
        /* This adds a bonus 5% such as 100 + 100/20 = 105 */
      //  if (now < sharessaleStartTime.add(21 days)) return amount.add(amount.div(20));
        /* No bonus is given */
        return amount;
    }
}
