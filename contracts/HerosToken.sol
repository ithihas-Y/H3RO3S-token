// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20,IERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';



contract H3RO3S is ERC20,Ownable {


    constructor(string memory __name,string memory __symbol,uint256 supply,address payable _treasury) ERC20(__name,__symbol){
        _mint(_msgSender(),supply*(10**decimals()));
        treasury = _treasury;
    }

}

