// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract SaturnMarketPlace is ERC721URIStorage {
    using Counters for Counters.Counter;

    // we use the quantity of the token to init the new tokenId
    Counters.Counter private countTokenIds;
    // countTokenIds.increment(); += 1 tokenIds
    // countTokenIds.current(); get current index returns(uint256)

    // we use this to count the number of tokens is listing in the maketplace
    Counters.Counter private countTokenSold;

    // this is the listing fee when you list your NFT to maketplace
    uint256 private listingPrice = 25000000000 wei;

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
    function updateListingPrice(uint256 newPrice) external payable {
        require(
            msg.sender == owner,
            "Only admin can update the listing price!"
        );
        listingPrice = newPrice;
    }

    // view function to get the listing price
    function getListingPrice() external view returns (uint256) {
        return listingPrice;
    }

    function createNFTOnMarket(string memory tokenURI, uint256 price)
        external
        payable
    {
        countTokenIds.increment();
        uint256 newTokenId = countTokenIds.current();
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        // list item to marketplace mapping
        require(price > 0, "price must be greater than 0");
        require(msg.value == listingPrice);
        tokenIdToItem[newTokenId] = Item(
            newTokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );
        _transfer(msg.sender, address(this), newTokenId);
    }

    function createMyNFT(string memory tokenURI) external payable {
        countTokenIds.increment();
        uint256 newTokenId = countTokenIds.current();
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        // add item to marketplace mapping
        require(msg.value == listingPrice);
        tokenIdToItem[newTokenId] = Item(
            newTokenId,
            payable(msg.sender),
            payable(msg.sender),
            0,
            true
        );
    }

    function sellNFT(string memory tokenId, uint256 price) external payable {}
}
