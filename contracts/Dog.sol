// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title CAT Token
 * @dev Compatible with ERC20/VIP180 Standard.
 * Special thanks go to openzeppelin-solidity project.
 */
contract Dog is ERC20{

    constructor() ERC20("DOG Token","DOG"){
      _mint(msg.sender,(10**10)*(10**18));
    }
}
