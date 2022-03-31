//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract LW3Punks is ERC721Enumerable, Ownable {

    using Strings for uint256;
    /*
    * @dev _baseTokenURI for computing {tokenURI}. If set, the resulting URI for each
    * token will be the concatenation of the `baseURI` and the `tokenId`.
     */
     string _baseTokenURI;

     //_price is the price of one LW3Punks NFT
     uint256 public _price = 0.01 ether;

     //_pause is used to pause the contract incase of any emergency
     bool public _paused;

     //max number of LW3punks
     uint256 public maxTokenIds = 10;

     //Total of tokens minted
     uint256 public tokenIds;

     modifier onlyWhenNotPaused {
         require(!_paused, "Contract currently paused");
         _;
     }

     constructor(string memory _baseURI) ERC721("LW3Punks", "LW3P"){
         _baseTokenURI = _baseURI;
     }

         /**
        * @dev mint allows an user to mint 1 NFT per transaction.
        */

        function mint() public payable onlyWhenNotPaused {
            require(tokenIds < maxTokenIds, "Exceeded maximum LW3Punks supply");
            require(msg.value >= _price, "Ether sent is not correct");
            tokenIds += 1;
            _safeMint(msg.sender, tokenIds);
        }

        /**
        * @dev _baseURI overides the Openzeppelin's ERC721 implementation which by default
        * returned an empty string for the baseURI
        */

        function _baseURI() internal view virtual override returns(string memory) {
            return _baseTokenURI;
        }

         /**
        * @dev tokenURI overides the Openzeppelin's ERC721 implementation for tokenURI function
        * This function returns the URI from where we can extract the metadata for a given tokenId
        */

        function tokenURI(uint256 tokenId) public view virtual override returns(string memory){
            require(_exists(tokenId), "ERC721Metadata: URI query for non existent token");
            string memory baseURI = _baseURI();
            // Here we checks if the length of the baseURI is greater than 0, if it is return the baseURI and attach
            // the tokenId and `.json` to it so that it knows the location of the metadata json file for a given 
            // tokenId stored on IPFS
            // If baseURI is empty return an empty string
            return bytes (baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json")):"";

           }
           function setPaused(bool val) public onlyOwner {
               _paused = val;
           }

        /**
        * @dev withdraw sends all the ether in the contract 
        * to the owner of the contract
         */

         function withdraw() public onlyOwner {
             address _owner = owner();
             uint256 amount = address(this).balance;
             (bool sent,) = _owner.call{value: amount}("");
             require(sent, "Failed to send Ether");
         }

          receive() external payable {}
          fallback() external payable {}
         

}