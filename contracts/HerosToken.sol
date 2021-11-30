// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20,IERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';



contract H3RO3S is ERC20,Ownable {

    using SafeERC20 for ERC20;

    address payable public treasury;

    uint256 public publicPriceWei;

    mapping(uint256 => uint256) public specificPrices;  // Price including all decimals for different walletTypes

    mapping(address => uint256) public specificWallets; // 0 for publicSale, choose number for others

    mapping(IERC20 => bool) public supportedBuyTokens;  // supported Tokens used for buying


    constructor(string memory __name,string memory __symbol,uint256 supply,address payable _treasury) ERC20(__name,__symbol){
        _mint(_msgSender(),supply*(10**decimals()));
        treasury = _treasury;
    }

    function setPublicPrice(uint256 _priceWei) onlyOwner() public {
        publicPriceWei = _priceWei;
    }

    function setSpecificPrices(uint256[] memory walletTypes,uint256[] memory priceInWei) onlyOwner() public {
        require(walletTypes.length == priceInWei.length,"Array length not equal");
        for (uint256 i = 0; i < walletTypes.length; i++) {
            specificPrices[walletTypes[i]] = priceInWei[i];
        }
    }

    function setSpecificWallets(address[] memory wallets,uint256[] memory pricesInWei) onlyOwner() public {
        require(wallets.length == pricesInWei.length,"Array length not equal");
        for (uint256 i = 0; i < wallets.length; i++) {
            specificWallets[wallets[i]] = pricesInWei[i];
        }
    }

    function setSupportedBuyTokens(address[] memory tokens,bool[] memory supportedOr) public onlyOwner() {
        require(tokens.length == supportedOr.length,"Array length not equal");
        for (uint256 i = 0; i < tokens.length; i++) {
            supportedBuyTokens[IERC20(tokens[i])] = supportedOr[i];
        }
    }

    function buy(uint256 amountOfHero,address BuyToken) public {
        require(supportedBuyTokens[IERC20(BuyToken)],"Unsupported Token for Buying");
        uint256 cost;
        if(specificWallets[_msgSender()] == 0){
            cost = amountOfHero * publicPriceWei;
        }else{
            cost = amountOfHero * specificPrices[specificWallets[_msgSender()]];
        }
        require(ERC20(BuyToken).transferFrom(_msgSender(),treasury,cost),"Transfer of Buying TOken Failed");
    }


}

