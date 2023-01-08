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

    uint256 private openPrice = 2000000000000 wei;
    // we use the quantity of the token to init the new tokenId
    Counters.Counter private countTokenIds;
    // this is admin, the ones who deploy this contract, we use this to recognize him when some call a function that only admin can call
    address payable admin;
    uint256 countBoxTypes;
    IAgentRepo public aRepo;
    ISaturnMarketPlace public iSaturnMarketPlace;

    //event
    event doPurchaseBox(address requester, uint256 tokenId, uint256 typeBox);

    struct catalogItem {
        uint256 _boxType;
        string _img;
        uint256 _price;
        uint256 _commonWeight;
        uint256 _rareWeight;
        uint256 _eliteWeight;
        uint256 _epicWeight;
        uint256 _legendaryWeight;
        uint256 _mythicalWeight;
    }

    mapping(uint256 => string) private typeBoxtoURI;
    mapping(uint256 => uint256) private typeBoxtoPrice;
    //AgentRarity => 0:common, 1:rare, 2:elite, 3:epic, 4:legendary, 5:mythical
    mapping(uint256 => uint256[]) private typeBoxtoWeight;
    mapping(uint256 => SaturnBoxDetail.BoxDetail) private tokenIdToBoxDetail;
    mapping(address => uint256) private addressToCountToken;

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
        typeBoxtoPrice[1] = 20000000000000 wei; //box type 1: small_box price
        typeBoxtoPrice[2] = 30000000000000 wei; //box type 2: big_box price
        typeBoxtoPrice[3] = 40000000000000 wei; //box type 3: mega_box price
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

    // view function to get the open Box price
    function getOpenBoxPrice() external view returns (uint256) {
        return openPrice;
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
        // _transfer(tokenIdToBoxDetail[tokenId]._owner_by, msg.sender, tokenId);
        tokenIdToBoxDetail[tokenId]._owner_by = msg.sender;
        addressToCountToken[msg.sender] += 1;
        payable(admin).transfer(tokenIdToBoxDetail[tokenId]._price);
        emit doPurchaseBox(msg.sender, tokenId, typeBox);
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
        (seed, rarity) = Utils.randomByWeights(
            seed,
            typeBoxtoWeight[tokenIdToBoxDetail[tokenId]._box_type]
        );
        //random agentName => request contract AgenRepo
        uint256 agentId;
        (seed, agentId) = aRepo.getRandomAgentId(seed);
        // request SaturnMKP input(agentName, rarity, seed) -> SaturnMKP request AgentRepo to get URI -> mintAgent
        iSaturnMarketPlace.mint(msg.sender, agentId, rarity, seed);
        // set status box
        tokenIdToBoxDetail[tokenId]._is_opened = true;
        addressToCountToken[msg.sender] -= 1;
        payable(admin).transfer(msg.value);
    }

    function getCatalog() external view returns (catalogItem[] memory) {
        catalogItem[] memory catalogs = new catalogItem[](countBoxTypes);
        for (uint256 i = 1; i < countBoxTypes + 1; i++) {
            catalogItem memory item = catalogItem(
                i,
                typeBoxtoURI[i],
                typeBoxtoPrice[i],
                typeBoxtoWeight[i][0],
                typeBoxtoWeight[i][1],
                typeBoxtoWeight[i][2],
                typeBoxtoWeight[i][3],
                typeBoxtoWeight[i][4],
                typeBoxtoWeight[i][5]
            );
            catalogs[i - 1] = item;
        }
        return catalogs;
    }

    // get my box
    function getMyBox()
        external
        view
        returns (SaturnBoxDetail.fetchBoxDetail[] memory)
    {
        uint256 countBox = addressToCountToken[msg.sender];
        SaturnBoxDetail.fetchBoxDetail[]
            memory listBox = new SaturnBoxDetail.fetchBoxDetail[](countBox);
        uint256 index = 0;
        for (uint256 i = 1; i < countTokenIds.current() + 1; i++) {
            if (
                tokenIdToBoxDetail[i]._owner_by == msg.sender &&
                tokenIdToBoxDetail[i]._is_opened == false
            ) {
                listBox[index] = SaturnBoxDetail.fetchBoxDetail(
                    tokenIdToBoxDetail[i]._id,
                    tokenIdToBoxDetail[i]._targetBLock,
                    tokenIdToBoxDetail[i]._price,
                    tokenIdToBoxDetail[i]._box_type,
                    tokenIdToBoxDetail[i]._is_opened,
                    tokenIdToBoxDetail[i]._owner_by,
                    typeBoxtoURI[tokenIdToBoxDetail[i]._box_type]
                );
                index += 1;
            }
        }
        return listBox;
    }
}
