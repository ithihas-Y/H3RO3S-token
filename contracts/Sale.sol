pragma solidity ^0.8.0;
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Sale is Ownable {

    address public token;

    uint256 public currentRate;

    address public fundWallet;

    mapping(address => bool) public supportedBuyTokens;

    uint256 public start;
    uint256 public end;

    constructor(address _token){
        token = _token;
    }

    function setBuyTokens(address[] memory _tokens) public onlyOwner() {
        for(uint256 i=0;i<_tokens.length;i++){
            supportedBuyTokens[_tokens[i]] = true; 
        }
    }

    function startSale(uint256 rate,uint256 _start,uint256 _end) public onlyOwner() {
        currentRate = rate;
        require(_start > block.timestamp,"start block set properly");
        require(_end > _start);
        start = _start;
        end = _end;
    }

    function getCurrentBlock() public view returns (uint256) {
        return block.timestamp;
    }

    function getBalance() public view returns (uint256) {
        return ERC20(token).balanceOf(address(this));
    }

    function buy(uint256 amtOfToken,address buyingToken) public {
        require(block.timestamp > start && block.timestamp < end,"sale time over or not started");
        require(supportedBuyTokens[buyingToken],"unsupported buying token");
        require(currentRate != 0);
        uint256 cost = amtOfToken * currentRate;
        require(ERC20(buyingToken).transferFrom(msg.sender,fundWallet,cost));
        ERC20(token).transferFrom(address(this),msg.sender,amtOfToken);
    }
}
