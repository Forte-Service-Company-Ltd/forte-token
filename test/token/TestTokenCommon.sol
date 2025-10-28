// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract DummyAMM{
    function dummyTrade(address tokenA, address tokenB, uint256 amountIn, uint256 amountOut, bool isTokenAIn) public {
        if(isTokenAIn){
            IERC20(tokenA).transferFrom(msg.sender, address(this), amountIn);
            IERC20(tokenB).transfer(msg.sender, amountOut);
        }else{
            IERC20(tokenB).transferFrom(msg.sender, address(this), amountIn);
            IERC20(tokenA).transfer(msg.sender, amountOut);
        }
    }
}

contract DummyNFTAMM{
    function dummyTrade(address erc20, address erc721, uint256 erc20Amount, uint256 tokenId, bool isBuyingNFT) public {
        if(isBuyingNFT){
            IERC20(erc20).transferFrom(msg.sender, address(this), erc20Amount);
            IERC721(erc721).safeTransferFrom(address(this), msg.sender, tokenId);
        }else{
            IERC721(erc721).safeTransferFrom(msg.sender, address(this), tokenId);
            IERC20(erc20).transfer(msg.sender, erc20Amount);
        }
    }
    
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external pure returns (bytes4) {
        _operator;
        _from;
        _tokenId;
        _data;
        return this.onERC721Received.selector;
    }
}

contract DummyStaking{
    function dummyStake(address erc20, uint256 erc20Amount) public {
        IERC20(erc20).transferFrom(msg.sender, address(this), erc20Amount);
    }
    function dummyUnStake(address erc20, uint256 erc20Amount) public {
        IERC20(erc20).transfer(msg.sender, erc20Amount);
    }
}
