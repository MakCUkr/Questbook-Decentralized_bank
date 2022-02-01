//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyERC20
{

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
        balances[msg.sender] += 1000* 1e8; 
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
    
    function mine(address _receiver) public
    {
        require(msg.sender == owner);
        balances[_receiver] += 10 * 1e8;
        totalMined += 10 * 1e8;
        require(totalMined <= totalSupply());
    }

    function getBlockNumber() public view returns (uint num)
    {
        return block.number;
    }

    function isMined(uint blockNumber) public view returns (bool res)
    {
        return blocksMined[blockNumber];
    }

}

// Contract address VNAB : 0xc18348E13D85bB121Ad509f2aA7db5A1c0b71254
