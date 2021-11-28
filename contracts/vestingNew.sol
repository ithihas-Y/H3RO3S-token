// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {ERC20,IERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/Math.sol';

contract TokenVesting is Ownable {


    event Claimed(address wallet,uint256 amt);

    address public vestingToken;

    uint256 public start;

    mapping(uint256 => uint256[3]) public details; // [0] is cliff,[1] is vestingPeriod,[2] is Release%

    uint256 constant public oneMonthinSeconds = 2592000;

    mapping(address => uint256) public vestingWallets;

    mapping(address => uint256) public vestedAmounts;

    mapping(address => uint256) public lastClaimed;

    constructor(address _vestingToken,uint256 _start){
        vestingToken = _vestingToken;
        start = _start;
    }

    function setWalletTypes(address[] memory wallets,uint256[] memory types) public onlyOwner() {
        require(wallets.length == types.length,'Array Lengths not equal');
        for (uint256 i = 0; i < wallets.length; i++) {
            vestingWallets[wallets[i]] = types[i];
        }
    }

    function setVestingDetails(uint256 _type,uint256[3] memory _details) public onlyOwner() {
        details[_type] = _details;
    }

    function assignVestedAmts(address[] memory _beneficiaries,uint256[] memory _amts) public onlyOwner() {
        require(_beneficiaries.length == _amts.length,'Array not equal');
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            vestedAmounts[_beneficiaries[i]] = _amts[i];
        }
    }

    function getTotalVested() public view returns (uint256) {
        return IERC20(vestingToken).balanceOf(address(this));
    }

    function claim() public {
        require(vestedAmounts[_msgSender()] >0,'No amount vested');
        uint256 _type = vestingWallets[_msgSender()];
        require((block.timestamp - start) > details[_type][0],'CLiff not over');
        require((block.timestamp - lastClaimed[_msgSender()]) > oneMonthinSeconds,'Last claimed under a month');
        uint256 share = Math.ceilDiv(details[_type][2], 1000);
        IERC20(vestingToken).transfer(_msgSender(), share);
        lastClaimed[_msgSender()] = block.timestamp;
        vestedAmounts[_msgSender()] -= share;
        emit Claimed(_msgSender(), share);

    }


}