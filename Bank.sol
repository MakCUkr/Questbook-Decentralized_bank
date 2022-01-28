// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface CEth {
    function mint() external payable; // to deposit to compound
    function redeem(uint redeemTokens) external returns (uint); // to withdraw from compound
    function exchangeRateStored() external view returns (uint); 
    function balanceOf(address owner) external view returns (uint256 balance);
}

interface IERC20{
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}

interface UniswapRouter{
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)  external  returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)  external  payable  returns (uint[] memory amounts);
    function WETH() external pure returns (address);
}

contract TestCompoundEth {
    CEth public cToken;
    IERC20 public ercToken;
    mapping(address => uint) public balances;
    UniswapRouter uniswap;
    address constant public UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address constant public C_ETH_TOKEN_ADDRESS = 0xd6801a1DfFCd0a410336Ef88DeF4320D6DF1883e;
    // uint public totalAccountEthBalance;

    constructor(/*address _cToken, address _ercToken*/) 
    {
        cToken = CEth(C_ETH_TOKEN_ADDRESS);
        uniswap = UniswapRouter(UNISWAP_ROUTER_ADDRESS);
    }
    
    function addEthBalance() public payable {     
        // totalAccountEthBalance += msg.value;
        uint balanceBefore = cToken.balanceOf(address(this));
        cToken.mint{value: msg.value}();
        uint toAddCEth = cToken.balanceOf(address(this)) - balanceBefore;
        balances[msg.sender] += toAddCEth;   
    }

    function addERC20tokenBalance(uint _ercAmount, address _ercToken) public {
        ercToken = IERC20(_ercToken);

        require(ercToken.allowance(msg.sender, address(this)) >= _ercAmount, "amount less than approved amount");
        require(ercToken.transferFrom(msg.sender, address(this), _ercAmount), "ERC transfer unsuccesful");

        uint ethBalanceBefore = address(this).balance;

        require(ercToken.approve(UNISWAP_ROUTER_ADDRESS, _ercAmount), "approve faile");
        address[] memory path = new address[](2);
        path[0] = _ercToken;
        path[1] = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
        uniswap.swapExactTokensForETH(_ercAmount, 73450, path, msg.sender, block.timestamp+1200);
        uint ethBalanceDiff = address(this).balance - ethBalanceBefore;
        balances[msg.sender] += ethBalanceDiff;
    }



    function getErcApprovedAmount() public view returns(uint)
    {
        return ercToken.allowance(msg.sender, address(this));
    }

    receive() external payable {}
    
    function withdraw() public  payable
    {
        // uint256 toTransfer = cToken.balanceOf(address(this));
        uint256 toTransfer = balances[msg.sender];
        balances[msg.sender] = balances[msg.sender] - toTransfer;
        cToken.redeem(toTransfer);

        // uint toReturn = address(this).balance - totalAccountEthBalance;
        // payable(msg.sender).transfer(toReturn);
    }
    
    // function getCTokenBalance() external view returns (uint) {
    //     return cToken.balanceOf(address(this));
    // }



    function redeem(uint _cTokenAmount) external {
        require(balances[msg.sender] >= _cTokenAmount);
        balances[msg.sender] -= _cTokenAmount;
        require(cToken.redeem(_cTokenAmount) == 0, "redeem failed");
    }

}


// for Rinkeby , use following contract address for cEth = 0xd6801a1DfFCd0a410336Ef88DeF4320D6DF1883e
// for other Compound addresses, go to https://compound.finance/docs#getting-started
// my wallet address = 0xC3B9701E27f2f6Eae771C157D09f6999969803B2
// DAI on Rinkeby address : 0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735
// Uniswap Router v2 on RInkeby : 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D

// 0xd6801a1DfFCd0a410336Ef88DeF4320D6DF1883e, 
// 100, 0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735