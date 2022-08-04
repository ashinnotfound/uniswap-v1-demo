// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract UniswapExchange{

    event AddLiquidity(address indexed account, address indexed exchangeAddress, uint256 balanceOfTokenA, uint256 balanceOfTokenB);
    event RemoveLiquidity(address indexed account, address indexed exchangeAddress, uint256 balanceOfTokenA, uint256 balanceOfTokenB);
    event Swap(address indexed account, address indexed exchangeAddress, uint256 balanceUsed, uint256 balanceGot);

    address internal tokenA;
    address internal tokenB;

    //记录用户增加的代币 account=>tokenAddress=>addedToken
    mapping(address=>mapping(address=>uint256))addedToken;

    constructor(address _tokenA,address _tokenB){
        require(_tokenA != address(0)&&_tokenB != address(0), "token address cannot be 0"); //代币地址不能为0
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    //查看交易池里代币A数量
    function showBalanceOfTokenA() public view returns (uint256) {
        return IERC20(tokenA).balanceOf(address(this));
    }

    //查看交易池里代币B数量
    function showBalanceOfTokenB() public view returns (uint256) {
        return IERC20(tokenB).balanceOf(address(this));
    }

    //查看增加过的代币量
    function showAddedTokenA() public view returns(uint256){
        return addedToken[msg.sender][tokenA];
    }
    function showAddedTokenB() public view returns(uint256){
        return addedToken[msg.sender][tokenB];
    }

    //查看流动性
    function showLiquidity() public view returns (uint256) {
        return IERC20(tokenA).balanceOf(address(this))*IERC20(tokenB).balanceOf(address(this));
    }

    //增加流动性
    function addLiquidity(address account, uint256 balanceOfTokenA, uint256 balanceOfTokenB)
        public
        returns (bool)
    {
        require(IERC20(tokenA).balanceOf(account)>=balanceOfTokenA,"not enough tokenA");
        require(IERC20(tokenB).balanceOf(account)>=balanceOfTokenB,"not enough tokenB");

        IERC20(tokenA).transferFrom(account,address(this),balanceOfTokenA);
        addedToken[account][tokenA]+=balanceOfTokenA;
        IERC20(tokenB).transferFrom(account,address(this),balanceOfTokenB);
        addedToken[account][tokenB]+=balanceOfTokenB;

        emit AddLiquidity(account, address(this), balanceOfTokenA, balanceOfTokenB);
        return true;
    }

    //减少流动性
    function removeLiquidity(address account, uint256 balanceOfTokenA, uint256 balanceOfTokenB)
        public
        returns (bool)
    {
        require(addedToken[account][tokenA]>=balanceOfTokenA,"[Token A] you cannot remove more than you had added");
        require(addedToken[account][tokenB]>=balanceOfTokenB,"[Token B] you cannot remove more than you had added");
        
        IERC20(tokenA).transfer(account, balanceOfTokenA);
        addedToken[account][tokenA]-=balanceOfTokenA;
        IERC20(tokenB).transfer(account, balanceOfTokenB);
        addedToken[account][tokenB]-=balanceOfTokenB;

        emit RemoveLiquidity(account, address(this), balanceOfTokenA, balanceOfTokenB);
        return true;
    }

    //返回代币A对应代币B的数量
    function showTokenAPrice(uint256 balanceOfTokenA) public view returns (uint256) {
        uint256 tokenAPool = IERC20(tokenA).balanceOf(address(this))+balanceOfTokenA;
        uint256 tokenBPool = IERC20(tokenA).balanceOf(address(this))*IERC20(tokenB).balanceOf(address(this))/tokenAPool;
        return IERC20(tokenB).balanceOf(address(this))-tokenBPool;
    }

    //返回代币B对应代币A的数量
    function showTokenBPrice(uint256 balanceOfTokenB) public view returns (uint256) {
        uint256 tokenBPool = IERC20(tokenB).balanceOf(address(this))+balanceOfTokenB;
        uint256 tokenAPool = IERC20(tokenA).balanceOf(address(this))*IERC20(tokenB).balanceOf(address(this))/tokenBPool;
        return IERC20(tokenA).balanceOf(address(this))-tokenAPool;
    }

    //代币兑换
    function swap(address account, uint256 balanceOfTokenA, uint256 balanceOfTokenB) public{
        require(balanceOfTokenA!=0||balanceOfTokenB!=0,"the amount to swap should not be zero");
        if(balanceOfTokenA>0){
            require(IERC20(tokenA).balanceOf(account)>=balanceOfTokenA);
            uint256 amountB=showTokenAPrice(balanceOfTokenA);
            
            IERC20(tokenA).transferFrom(account,address(this),balanceOfTokenA);
            IERC20(tokenB).transfer(account, amountB);  

            emit Swap(account, address(this), balanceOfTokenA, amountB);
        }else if(balanceOfTokenB>0){
            require(IERC20(tokenB).balanceOf(account)>=balanceOfTokenB);
            uint256 amountA=showTokenBPrice(balanceOfTokenB);
            
            IERC20(tokenB).transferFrom(account,address(this),balanceOfTokenB);
            IERC20(tokenA).transfer(account, amountA);  

            emit Swap(account, address(this), balanceOfTokenB, amountA);
        }
    }
}
