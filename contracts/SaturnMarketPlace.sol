// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "../interfaces/IAgentRepo.sol";
import "./AgentDetail.sol";

contract SaturnMarketPlace is ERC721URIStorage, AccessControl {
    using Counters for Counters.Counter;
    using AgentDetail for AgentDetail.Detail;

    // we use the quantity of the token to init the new tokenId
    Counters.Counter private countTokenIds;
    // countTokenIds.increment(); += 1 tokenIds
    // countTokenIds.current(); get current index returns(uint256)

    // we use this to count the number of tokens is listing in the maketplace
    Counters.Counter private countTokenListing;

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
        AgentDetail.Detail _tokenURIDetail;
        uint256 _tokenId;
        address payable _seller;
        address payable _owner;
        uint256 _price;
        bool _isSelling;
        string _tokenImg;
        string _tokenName;
    }
    //event
    event requestOnChain(address requester, uint256 tokenId);
    event toOffChain(address requester, uint256 tokenId);
    event toOnChain(address requester, uint256 tokenId);
    event doSellNFT(address requester, uint256 tokenId, uint256 price);
    event doPurchaseNFT(address requester, uint256 tokenId);
    event mintToken(address requester, fetchItem tokenDetail);

    // this is the listing fee when you list your NFT to maketplace
    uint256 private listingPrice = 2000000000000 wei;
    uint256 private onChainPrice = 2000000000000 wei;
    uint256 private offChainPrice = 2000000000000 wei;

    // Optional mapping for token details
    mapping(uint256 => uint256) private _tokenURIDetails;

    //
    mapping(address => uint256) private addressToCountAddressListing;

    // this is admin, the ones who deploy this contract, we use this to recognize him when some call a function that only admin can call
    address payable admin;

    // agent repo
    IAgentRepo public aRepo;

    // mapping store all the item in maketplace
    mapping(uint256 => marketItem) private tokenIdToItem;

    // AccessControl
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant SATURNBOX_ROLE = keccak256("SATURNBOX_ROLE");
    modifier onlyRole(bytes32 role) {
        require(hasRole(role, msg.sender) == true, "Required role");
        _;
    }

    modifier requireOnChain(uint256 tokenId) {
        AgentDetail.Detail memory details = AgentDetail.decode(
            _tokenURIDetails[tokenId]
        );
        require(details.isOnchain == 1, "Requires onChain");
        _;
    }

    modifier requireOffChain(uint256 tokenId) {
        AgentDetail.Detail memory details = AgentDetail.decode(
            _tokenURIDetails[tokenId]
        );
        require(details.isOnchain == 0, "Requires offChain");
        _;
    }

    constructor(address saturnBoxAddress) ERC721("SaturnMKP", "SMKP") {
        admin = payable(msg.sender);
        _setupRole(ADMIN_ROLE, admin);
        _setupRole(SATURNBOX_ROLE, saturnBoxAddress);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // set contract AgentRepo
    function initializeContract(address contractAddressAgentRepo)
        external
        onlyRole(ADMIN_ROLE)
    {
        aRepo = IAgentRepo(contractAddressAgentRepo);
    }

    // for admin only: to update listing price
    function updateListingPrice(uint256 newPrice)
        external
        payable
        onlyRole(ADMIN_ROLE)
    {
        listingPrice = newPrice;
    }

    // for admin only: to update listing price
    function updateOnChainPrice(uint256 newPrice)
        external
        payable
        onlyRole(ADMIN_ROLE)
    {
        onChainPrice = newPrice;
    }

    // for admin only: to update listing price
    function updateOffChainPrice(uint256 newPrice)
        external
        payable
        onlyRole(ADMIN_ROLE)
    {
        offChainPrice = newPrice;
    }

    // view function to get the listing price
    function getListingPrice() external view returns (uint256) {
        return listingPrice;
    }

    // view function to get the onchain price
    function getOnChainPrice() external view returns (uint256) {
        return onChainPrice;
    }

    // view function to get the offchain price
    function getOffChainPrice() external view returns (uint256) {
        return offChainPrice;
    }

    // only contract can request this function
    function mint(
        address owner,
        uint256 agentId,
        uint256 rarity,
        uint256 seed
    ) external onlyRole(SATURNBOX_ROLE) {
        // require(msg.value == listingPrice); // FIXME: do not pay
        countTokenIds.increment();
        uint256 newTokenId = countTokenIds.current();
        _safeMint(owner, newTokenId);
        // string memory tokenURI;
        uint256 tokenURI;
        uint256 newSeed;
        (newSeed, tokenURI) = aRepo.createRandomToken(
            newTokenId,
            agentId,
            rarity,
            seed
        );
        _tokenURIDetails[newTokenId] = tokenURI;
        // add item to marketplace mapping

        tokenIdToItem[newTokenId] = marketItem(
            // newTokenId,
            payable(address(0)),
            payable(owner),
            0,
            false
        );
        // emit new token
        AgentDetail.Detail memory detail = AgentDetail.decode(tokenURI);
        string memory aName;
        string memory aImg;
        (aName, aImg) = aRepo.getAgentNameAndImg(detail.agentId);
        emit mintToken(
            owner,
            fetchItem(
                detail,
                newTokenId,
                // tokenIdToItem[i]._tokenId,
                tokenIdToItem[newTokenId]._seller,
                tokenIdToItem[newTokenId]._owner,
                tokenIdToItem[newTokenId]._price,
                tokenIdToItem[newTokenId]._isSelling,
                aImg,
                aName
            )
        );
    }

    function sellNFT(uint256 tokenId, uint256 price)
        external
        payable
        requireOnChain(tokenId)
    {
        require(msg.value == listingPrice);
        require(msg.sender == ownerOf(tokenId), "Only owner of token can sell");
        require(
            tokenIdToItem[tokenId]._isSelling == false &&
                tokenIdToItem[tokenId]._owner != payable(address(this)),
            "NFT is listing on marketplace"
        );
        // require on chain

        require(price > 0, "price must be greater than 0");
        countTokenListing.increment();
        tokenIdToItem[tokenId]._seller = payable(msg.sender);
        tokenIdToItem[tokenId]._owner = payable(address(this));
        tokenIdToItem[tokenId]._price = price;
        tokenIdToItem[tokenId]._isSelling = true;
        _transfer(msg.sender, address(this), tokenId);
        addressToCountAddressListing[msg.sender] += 1;
        payable(admin).transfer(listingPrice);
        emit doSellNFT(msg.sender, tokenId, price);
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
        payable(seller).transfer(msg.value);
        addressToCountAddressListing[seller] -= 1;
        emit doPurchaseNFT(msg.sender, tokenId);
    }

    // function withdrawNFT(uint256 tokenId) external payable {}

    function doRequestOnChain(uint256 tokenId)
        external
        payable
        requireOffChain(tokenId)
    {
        address owner = msg.sender;
        require(ownerOf(tokenId) == owner, "Token not owned");
        require(msg.value == onChainPrice, "Required payment!");
        payable(admin).transfer(msg.value);
        emit requestOnChain(msg.sender, tokenId);
    }

    function onChain(uint256 tokenId, uint256 agentEncoded)
        external
        onlyRole(ADMIN_ROLE)
    {
        // verify agentEncoded if external for all user
        AgentDetail.Detail memory details = AgentDetail.decode(agentEncoded);
        details.isOnchain = 1;
        _tokenURIDetails[tokenId] = details.encode();
        emit toOnChain(ownerOf(tokenId), tokenId);
    }

    function isOnChain(uint256 tokenId)
        external
        view
        onlyRole(ADMIN_ROLE)
        returns (bool)
    {
        AgentDetail.Detail memory detail = AgentDetail.decode(
            _tokenURIDetails[tokenId]
        );

        if (detail.isOnchain == 1) {
            return true;
        } else {
            return false;
        }
    }

    /** Update warrior off chain for the owner. */
    function offChain(uint256 tokenId) external payable {
        address owner = msg.sender;
        require(ownerOf(tokenId) == owner, "Token not owned");
        require(msg.value == offChainPrice, "Required payment!");

        AgentDetail.Detail memory details = AgentDetail.decode(
            _tokenURIDetails[tokenId]
        );
        details.isOnchain = 0;
        _tokenURIDetails[tokenId] = details.encode();

        emit toOffChain(msg.sender, tokenId);
    }

    // get all Items that are listing on marketplace
    function getListedItems() external view returns (fetchItem[] memory) {
        uint256 lenItemListing = countTokenListing.current();
        fetchItem[] memory listItems = new fetchItem[](lenItemListing);
        uint256 index = 0;
        for (uint256 i = 1; i < countTokenIds.current() + 1; i++) {
            if (tokenIdToItem[i]._isSelling == true) {
                AgentDetail.Detail memory detail = AgentDetail.decode(
                    _tokenURIDetails[i]
                );
                string memory aName;
                string memory aImg;
                (aName, aImg) = aRepo.getAgentNameAndImg(detail.agentId);
                listItems[index] = fetchItem(
                    detail,
                    i,
                    // tokenIdToItem[i]._tokenId,
                    tokenIdToItem[i]._seller,
                    tokenIdToItem[i]._owner,
                    tokenIdToItem[i]._price,
                    tokenIdToItem[i]._isSelling,
                    aImg,
                    aName
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
                AgentDetail.Detail memory detail = AgentDetail.decode(
                    _tokenURIDetails[i]
                );
                string memory aName;
                string memory aImg;
                (aName, aImg) = aRepo.getAgentNameAndImg(detail.agentId);
                listItems[index] = fetchItem(
                    detail,
                    i,
                    // tokenIdToItem[i]._tokenId,
                    tokenIdToItem[i]._seller,
                    tokenIdToItem[i]._owner,
                    tokenIdToItem[i]._price,
                    tokenIdToItem[i]._isSelling,
                    aImg,
                    aName
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
                AgentDetail.Detail memory detail = AgentDetail.decode(
                    _tokenURIDetails[i]
                );
                string memory aName;
                string memory aImg;
                (aName, aImg) = aRepo.getAgentNameAndImg(detail.agentId);
                listItems[index] = fetchItem(
                    detail,
                    i,
                    // tokenIdToItem[i]._tokenId,
                    tokenIdToItem[i]._seller,
                    tokenIdToItem[i]._owner,
                    tokenIdToItem[i]._price,
                    tokenIdToItem[i]._isSelling,
                    aImg,
                    aName
                );
                index += 1;
            }
        }
        return listItems;
    }

    function getItemByTokenId(uint256 tokenId)
        public
        view
        returns (fetchItem memory)
    {
        AgentDetail.Detail memory detail = AgentDetail.decode(
            _tokenURIDetails[tokenId]
        );
        string memory aName;
        string memory aImg;
        (aName, aImg) = aRepo.getAgentNameAndImg(detail.agentId);
        return
            fetchItem(
                detail,
                tokenId,
                // tokenIdToItem[i]._tokenId,
                tokenIdToItem[tokenId]._seller,
                tokenIdToItem[tokenId]._owner,
                tokenIdToItem[tokenId]._price,
                tokenIdToItem[tokenId]._isSelling,
                aImg,
                aName
            );
    }

    function getItemByTokenIds(uint256[] memory tokenIds)
        external
        view
        returns (fetchItem[] memory)
    {
        fetchItem[] memory listItems = new fetchItem[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++)
            listItems[i] = getItemByTokenId(tokenIds[i]);
        return listItems;
    }
}
