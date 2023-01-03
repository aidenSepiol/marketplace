// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// import "./SaturnMarketPlace.sol";
// import "./SaturnBoxDetail.sol";

contract SaturnBox is ERC721URIStorage {
    using Counters for Counters.Counter;
    // using SaturnBoxDetail for SaturnBoxDetail.BoxDetail;
    // we use the quantity of the token to init the new tokenId
    Counters.Counter private countTokenIds;
    // this is admin, the ones who deploy this contract, we use this to recognize him when some call a function that only admin can call
    address payable admin;
    uint256 countBoxTypes;

    struct WeightAgent {
        uint256 _common;
        uint256 _rare;
        uint256 _elite;
        uint256 _epic;
        uint256 _legendary;
        uint256 _mythical;
    }
    struct BoxDetail {
        uint256 _id;
        // uint256 index; // index of id in user token array
        uint256 _price; // price box
        uint256 _box_type; // 1 -> 3: agent box.
        bool _is_opened; // 0: still not open, 1: opened
        address _owner_by; // Owner token before on chain for marketplace.
    }

    mapping(uint256 => string) private typeBoxtoURI;
    mapping(uint256 => uint256) private typeBoxtoPrice;
    mapping(uint256 => WeightAgent) private typeBoxtoWeight;
    mapping(uint256 => BoxDetail) private tokenIdToBoxDetail;

    constructor() ERC721("SaturnB", "STB") {
        admin = payable(msg.sender);
        // initialize countBoxTypes
        countBoxTypes = 3; // we have 3 boxes
        // initialize the weight
        typeBoxtoWeight[1] = WeightAgent(40, 30, 10, 10, 5, 5); //box type 1: box level 1
        typeBoxtoWeight[2] = WeightAgent(20, 20, 25, 10, 15, 10); //box type 2: box level 2
        typeBoxtoWeight[3] = WeightAgent(10, 15, 15, 15, 20, 25); //box type 3: box level 3
        // initialize the Image box URI
        typeBoxtoURI[1] = "http://localhost/#######/img1.png"; //box type 1: box level 1 image url
        typeBoxtoURI[2] = "http://localhost/#######/img2.png"; //box type 2: box level 2 image url
        typeBoxtoURI[3] = "http://localhost/#######/img3.png"; //box type 2: box level 3 image url
        // initialize box price
        typeBoxtoPrice[1] = 100000000 wei; //box type 1: box level 1 price
        typeBoxtoPrice[2] = 100000000 wei; //box type 2: box level 2 price
        typeBoxtoPrice[3] = 100000000 wei; //box type 3: box level 3 price
    }

    // update weight for each box type, require admin
    function updateWeight(
        uint256 typeBox,
        uint256 _common,
        uint256 _rare,
        uint256 _elite,
        uint256 _epic,
        uint256 _legendary,
        uint256 _mythical
    ) external payable {
        require(msg.sender == admin, "Only admin can update the weight!");
        require(
            typeBox >= 1 && typeBox <= countBoxTypes,
            "This BoxType is not valid!"
        );
        // TODO: require the typeBox is valid
        typeBoxtoWeight[typeBox] = WeightAgent(
            _common,
            _rare,
            _elite,
            _epic,
            _legendary,
            _mythical
        );
    }

    // update price for each box type, require admin
    function updatePrice(uint256 typeBox, uint256 newPrice) external payable {
        require(msg.sender == admin, "Only admin can update the weight!");
        require(
            typeBox >= 1 && typeBox <= countBoxTypes,
            "This BoxType is not valid!"
        );
        typeBoxtoPrice[typeBox] = newPrice;
    }

    //update box URI for each box type, require admin
    function updateBoxURI(uint256 typeBox, string memory newURI)
        external
        payable
    {
        require(msg.sender == admin, "Only admin can update the weight!");
        require(
            typeBox >= 1 && typeBox <= countBoxTypes,
            "This BoxType is not valid!"
        );
        typeBoxtoURI[typeBox] = newURI;
    }

    // initialize a box by boxType
    function initializeBox(uint256 typeBox) private returns (uint256) {
        require(
            typeBox >= 1 && typeBox <= countBoxTypes,
            "This BoxType is not valid!"
        );
        countTokenIds.increment();
        uint256 newTokenId = countTokenIds.current();
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, typeBoxtoURI[typeBox]);

        // SaturnBoxDetail.BoxDetail memory newBoxDetail;
        tokenIdToBoxDetail[newTokenId] = BoxDetail(
            newTokenId,
            typeBoxtoPrice[typeBox],
            typeBox,
            false,
            address(this)
        );
        return newTokenId;
    }

    // buy a box
    function purchaseBox(uint256 typeBox) external payable {
        require(
            typeBox >= 1 && typeBox <= countBoxTypes,
            "This BoxType is not valid!"
        );
        uint256 tokenId = initializeBox(typeBox);
        require(
            msg.value == tokenIdToBoxDetail[tokenId]._price,
            "Require payment!"
        );
        _transfer(tokenIdToBoxDetail[tokenId]._owner_by, msg.sender, tokenId);
        tokenIdToBoxDetail[tokenId]._owner_by = msg.sender;
        payable(admin).transfer(tokenIdToBoxDetail[tokenId]._price);
    }

    // open a box
    function openBox(uint256 tokenId) external payable {}

    // get my box
    function getMyBox(uint256 tokenId)
        external
        view
        returns (BoxDetail[] memory)
    {}
}
