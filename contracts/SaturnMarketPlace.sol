// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract SaturnMarketPlace is ERC721URIStorage {
    using Counters for Counters.Counter;

    // we use the quantity of the token to init the new tokenId
    Counters.Counter private tokenIds;
    // _tokenIds.increment(); += 1 tokenIds
    // _tokenIds.current(); get current index returns(uint256)

    // we use this to count the number of tokens is listing in the maketplace
    Counters.Counter private tokenSold;

    // this is the listing fee when you list your NFT to maketplace
    uint256 public listingPrice = 25000000000 wei;

    // this is admin, the ones who deploy this contract, we use this to recognize him when some call a function that only admin can call
    address payable owner;

    // an object in list items
    struct Item {
        uint256 _tokenId;
        address payable _seller;
        address payable _owner;
        uint256 price;
        bool isSold;
    }

    // mapping store all the item in maketplace
    mapping(uint256 => Item) private tokenIdToItem;

    constructor() ERC721("Saturn", "STR") {
        owner = payable(msg.sender);
    }

    // for admin only: to update listing price
    function updateListingPrice(uint256 newPrice) external {
        require(
            msg.sender == owner,
            "Only admin can update the listing price!"
        );
        listingPrice = newPrice;
    }
}
