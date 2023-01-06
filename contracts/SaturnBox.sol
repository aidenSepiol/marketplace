// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// import "./SaturnMarketPlace.sol";
import "./SaturnBoxDetail.sol";
import "./Utils.sol";
import "../interfaces/IAgentRepo.sol";
import "../interfaces/ISaturnMarketPlace.sol";

contract SaturnBox is ERC721URIStorage, AccessControl {
    using Counters for Counters.Counter;
    using SaturnBoxDetail for SaturnBoxDetail.BoxDetail;

    uint256 private openPrice = 25000000000 wei;
    // we use the quantity of the token to init the new tokenId
    Counters.Counter private countTokenIds;
    // this is admin, the ones who deploy this contract, we use this to recognize him when some call a function that only admin can call
    address payable admin;
    uint256 countBoxTypes;
    IAgentRepo public aRepo;
    ISaturnMarketPlace public iSaturnMarketPlace;

    // struct WeightAgentRarity {
    //     uint256 _common;
    //     uint256 _rare;
    //     uint256 _elite;
    //     uint256 _epic;
    //     uint256 _legendary;
    //     uint256 _mythical;
    // }

    mapping(uint256 => string) private typeBoxtoURI;
    mapping(uint256 => uint256) private typeBoxtoPrice;
    //AgentRarity => 0:common, 1:rare, 2:elite, 3:epic, 4:legendary, 5:mythical
    mapping(uint256 => uint256[]) private typeBoxtoWeight;
    mapping(uint256 => SaturnBoxDetail.BoxDetail) private tokenIdToBoxDetail;

    // AccessControl
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    modifier onlyRole(bytes32 role) {
        require(hasRole(role, msg.sender) == true, "Required role");
        _;
    }

    constructor() ERC721("SaturnB", "STB") {
        admin = payable(msg.sender);
        _setupRole(ADMIN_ROLE, admin);
        // initialize countBoxTypes
        countBoxTypes = 3; // we have 3 boxes
        // initialize the weight
        typeBoxtoWeight[1] = [40, 30, 10, 10, 5, 5]; //box type 1: small_box
        typeBoxtoWeight[2] = [20, 20, 25, 10, 15, 10]; //box type 2: big_box
        typeBoxtoWeight[3] = [10, 15, 15, 15, 20, 25]; //box type 3: mega_box
        // initialize the Image box URI
        typeBoxtoURI[1] = "http://localhost/#######/img1.png"; //box type 1: small_box image url
        typeBoxtoURI[2] = "http://localhost/#######/img2.png"; //box type 2: big_box image url
        typeBoxtoURI[3] = "http://localhost/#######/img3.png"; //box type 2: mega_box image url
        // initialize box price
        typeBoxtoPrice[1] = 100000000 wei; //box type 1: small_box price
        typeBoxtoPrice[2] = 100000000 wei; //box type 2: big_box price
        typeBoxtoPrice[3] = 100000000 wei; //box type 3: mega_box price
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

    // set contract AgentRepo, ISaturnMarketPlace
    function initializeContract(
        address contractAddressAgentRepo,
        address contractAddressSaturnMKP
    ) external onlyRole(ADMIN_ROLE) {
        aRepo = IAgentRepo(contractAddressAgentRepo);
        iSaturnMarketPlace = ISaturnMarketPlace(contractAddressSaturnMKP);
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
    ) external onlyRole(ADMIN_ROLE) {
        require(msg.sender == admin, "Only admin can update the weight!");
        require(
            typeBox >= 1 && typeBox <= countBoxTypes,
            "This BoxType is not valid!"
        );
        // TODO: require the typeBox is valid
        typeBoxtoWeight[typeBox] = [
            _common,
            _rare,
            _elite,
            _epic,
            _legendary,
            _mythical
        ];
    }

    // update price for each box type, require admin
    function updatePrice(uint256 typeBox, uint256 newPrice)
        external
        onlyRole(ADMIN_ROLE)
    {
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
        onlyRole(ADMIN_ROLE)
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

        uint256 targetBlock = block.number + 5;
        SaturnBoxDetail.BoxDetail memory newBoxDetail = SaturnBoxDetail
            .BoxDetail(
                newTokenId,
                targetBlock,
                typeBoxtoPrice[typeBox],
                typeBox,
                false,
                address(this)
            );

        tokenIdToBoxDetail[newTokenId] = newBoxDetail;
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
    function openBox(uint256 tokenId) external payable {
        require(msg.value == openPrice, "Require payment to open a box");
        // check if the blocknumber is already valid or not
        uint256 targetBlock = tokenIdToBoxDetail[tokenId]._targetBLock;
        require(targetBlock < block.number, "Target block not arrived");
        uint256 seed = uint256(blockhash(targetBlock));
        //request mint agent in saturnMKP
        //get random rarity => 0:common, 1:rare, 2:elite, 3:epic, 4:legendary, 5:mythical
        uint256 rarity;
        (seed, rarity) = Utils.randomByWeights(seed, typeBoxtoWeight[tokenId]);
        //random agentName => request contract AgenRepo
        uint256 agentId;
        (seed, agentId) = aRepo.getRandomAgentId(seed);
        // request SaturnMKP input(agentName, rarity, seed) -> SaturnMKP request AgentRepo to get URI -> mintAgent
        iSaturnMarketPlace.mint(msg.sender, agentId, rarity, seed);
        // set status box
        tokenIdToBoxDetail[tokenId]._is_opened = true;
    }

    // get my box
    function getMyBox(uint256 tokenId)
        external
        view
        returns (SaturnBoxDetail.BoxDetail[] memory)
    {}
}
