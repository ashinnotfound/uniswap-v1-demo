// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./UniswapExchange.sol";


contract UniswapFactory{

    event newExchange(address indexed creator,address tokenA, address tokenB, address indexed exchangeAddress);

    mapping(address=>mapping(address=>address))querryExchangeByToken;

    //创建交易合约（token-eth）
    function createExchange(address tokenA,address tokenB) public returns(address){
        UniswapExchange exchange=new UniswapExchange(tokenA,tokenB);
        address exchangeAddress=address(exchange);

        querryExchangeByToken[tokenA][tokenB]=exchangeAddress;
        querryExchangeByToken[tokenB][tokenA]=exchangeAddress;
        emit newExchange(msg.sender,tokenA,tokenB,exchangeAddress);
        return exchangeAddress;
    }

    //根据代币地址查找交易合约地址
    function searchForExchangeByToken(address tokenA,address tokenB)public view returns(address){
        return querryExchangeByToken[tokenA][tokenB];
    }


}