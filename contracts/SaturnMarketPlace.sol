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
    Counters.Counter private countTokenListing;

    // this is the listing fee when you list your NFT to maketplace
    uint256 private listingPrice = 25000000000 wei;

    //
    mapping(address => uint256) private addressToCountAddressListing;

    // this is admin, the ones who deploy this contract, we use this to recognize him when some call a function that only admin can call
    address payable admin;

    // an object in list items
    struct marketItem {
        // uint256 _tokenId;
        address payable _seller;
        address payable _owner;
        uint256 _price;
        bool _isSelling;
    }
    // struct item return
    struct fetchItem {
        string _tokenURI;
        uint256 _tokenId;
        address payable _seller;
        address payable _owner;
        uint256 _price;
        bool _isSelling;
    }

    // mapping store all the item in maketplace
    mapping(uint256 => marketItem) private tokenIdToItem;

    constructor() ERC721("Saturn", "STR") {
        admin = payable(msg.sender);
    }

    // for admin only: to update listing price
    function updateListingPrice(uint256 newPrice) external payable {
        require(
            msg.sender == admin,
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
        countTokenListing.increment();
        uint256 newTokenId = countTokenIds.current();
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        // list item to marketplace mapping
        require(price > 0, "price must be greater than 0");
        require(msg.value == listingPrice);
        tokenIdToItem[newTokenId] = marketItem(
            // newTokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            true
        );
        _transfer(msg.sender, address(this), newTokenId);
        addressToCountAddressListing[msg.sender] += 1;
    }

    function createMyNFT(string memory tokenURI) external payable {
        countTokenIds.increment();
        uint256 newTokenId = countTokenIds.current();
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        // add item to marketplace mapping
        require(msg.value == listingPrice);
        tokenIdToItem[newTokenId] = marketItem(
            // newTokenId,
            payable(address(0)),
            payable(msg.sender),
            0,
            false
        );
    }

    function sellNFT(uint256 tokenId, uint256 price) external payable {
        require(msg.value == listingPrice);
        require(msg.sender == ownerOf(tokenId), "Only owner of token can sell");
        require(
            tokenIdToItem[tokenId]._isSelling == false &&
                tokenIdToItem[tokenId]._owner != payable(address(this)),
            "NFT is listing on marketplace"
        );
        require(price > 0, "price must be greater than 0");
        countTokenListing.increment();
        tokenIdToItem[tokenId]._seller = payable(msg.sender);
        tokenIdToItem[tokenId]._owner = payable(address(this));
        tokenIdToItem[tokenId]._price = price;
        tokenIdToItem[tokenId]._isSelling = true;
        _transfer(msg.sender, address(this), tokenId);
        addressToCountAddressListing[msg.sender] += 1;
    }

    function purchaseNFT(uint256 tokenId) external payable {
        uint256 tokenPrice = tokenIdToItem[tokenId]._price;
        address payable seller = tokenIdToItem[tokenId]._seller;
        require(msg.value == tokenPrice, "Require payment!");
        countTokenListing.decrement();
        tokenIdToItem[tokenId]._seller = payable(address(0));
        tokenIdToItem[tokenId]._owner = payable(msg.sender);
        tokenIdToItem[tokenId]._isSelling = false;
        _transfer(address(this), msg.sender, tokenId);
        payable(admin).transfer(listingPrice);
        payable(seller).transfer(msg.value);
        addressToCountAddressListing[seller] -= 1;
    }

    // get all Items that are listing on marketplace
    function getListedItems() external view returns (fetchItem[] memory) {
        uint256 lenItemListing = countTokenListing.current();
        fetchItem[] memory listItems = new fetchItem[](lenItemListing);
        uint256 index = 0;
        for (uint256 i = 1; i < countTokenIds.current() + 1; i++) {
            if (tokenIdToItem[i]._isSelling == true) {
                listItems[index] = fetchItem(
                    tokenURI(i),
                    i,
                    // tokenIdToItem[i]._tokenId,
                    tokenIdToItem[i]._seller,
                    tokenIdToItem[i]._owner,
                    tokenIdToItem[i]._price,
                    tokenIdToItem[i]._isSelling
                );
                index += 1;
            }
        }
        return listItems;
    }

    // get all Items that the sender is listing on marketplace
    function getMyListedItems() external view returns (fetchItem[] memory) {
        uint256 lenItemListing = addressToCountAddressListing[msg.sender];
        fetchItem[] memory listItems = new fetchItem[](lenItemListing);
        uint256 index = 0;
        for (uint256 i = 1; i < countTokenIds.current() + 1; i++) {
            if (
                tokenIdToItem[i]._isSelling == true &&
                tokenIdToItem[i]._seller == msg.sender
            ) {
                listItems[index] = fetchItem(
                    tokenURI(i),
                    i,
                    // tokenIdToItem[i]._tokenId,
                    tokenIdToItem[i]._seller,
                    tokenIdToItem[i]._owner,
                    tokenIdToItem[i]._price,
                    tokenIdToItem[i]._isSelling
                );
                index += 1;
            }
        }
        return listItems;
    }

    // get all Items that the sender owned
    function getMyItems() external view returns (fetchItem[] memory) {
        uint256 lenItemListing = balanceOf(msg.sender);
        fetchItem[] memory listItems = new fetchItem[](lenItemListing);
        uint256 index = 0;
        for (uint256 i = 1; i < countTokenIds.current() + 1; i++) {
            if (tokenIdToItem[i]._owner == msg.sender) {
                listItems[index] = fetchItem(
                    tokenURI(i),
                    i,
                    // tokenIdToItem[i]._tokenId,
                    tokenIdToItem[i]._seller,
                    tokenIdToItem[i]._owner,
                    tokenIdToItem[i]._price,
                    tokenIdToItem[i]._isSelling
                );
                index += 1;
            }
        }
        return listItems;
    }
}
