//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
    function latestRoundData() external view returns (uint80 roundId, uint answer, uint startedAt, uint updatedAt, uint80 answeredInRound)  ;
}


contract MyERC20
{
    AggregatorV3Interface internal priceFeed;
    string public NAME  = "VitalikNotABot";
    string public SYMBOL = "VNAB";
    mapping(address => uint) balances;
    mapping(uint => bool) public blocksMined;
    mapping(address => mapping(address => uint)) allowances;
    uint public totalMined;
    address public owner;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor()
    {
        // balances[msg.sender] += 1000 * 1e8; 
        priceFeed = AggregatorV3Interface(0xFABe80711F3ea886C3AC102c81ffC9825E16162E);
        owner = msg.sender;
    }


    function name() public view returns (string memory)
    {
        return NAME;
    }

    function symbol() public view returns (string memory)
    {
        return SYMBOL;
    }

    function decimals() public view returns (uint8)
    {
        return 8;
    }

    function totalSupply() public view returns (uint256)
    {
        return 1000000 * 1e8;
    }

    function balanceOf(address _owner) public view returns (uint256 balance)
    {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success)
    {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to]+= _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] > _value, "_from balance not enough");
        require(allowances[_from][msg.sender] >= _value, "allowance not enough");

        balances[_from] -= _value;
        balances[_to] += _value;
        allowances[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }
    
    function getBlockNumber() public view returns (uint num)
    {
        return block.number;
    }

    function isMined(uint blockNumber) public view returns (bool res)
    {
        return blocksMined[blockNumber];
    }

    function mine() public payable returns (uint a) // the mint function prints (the amount fo MATIC you could get for the msg.value)/10 in VNAB tokens
    {
        uint coinsToBeMined = mintAmount(msg.value);
        require (coinsToBeMined <= 1e13, "cant mint more than 1 lakh VNAB");
        require((totalMined+coinsToBeMined)  <= totalSupply(), "can't mint tokens more than supply");

        balances[msg.sender] += coinsToBeMined;
        totalMined += coinsToBeMined;
        
        return coinsToBeMined;
    }

    function mintAmount(uint val) public view returns(uint weiAmount) 
    {
        uint a; uint tokenPrice; uint c;  uint d; uint e; uint tokenAmount;
        (a, tokenPrice, c, d, e) = priceFeed.latestRoundData();
        val  = val * 1e8 ;
        val =  val / tokenPrice;
        // val  = val * 1000000 * 1000000 * 1000000 ;
        return val;
    }

    function receive() public payable
    {
        require(false, "tried to receive money but couldn't hehe");
    }

}



// Chainlink rinkeby MATIC/ETH Data Feed = 0x7794ee502922e2b723432DDD852B3C30A911F021
// 1e8 = 100000000
// 1e18 = 1000000000000000000 = 162 VNAB (by current price)