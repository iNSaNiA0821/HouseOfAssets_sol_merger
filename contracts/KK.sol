// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// @author: Tai Ming
///////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                               //
//                                                                                               //
//                                                                                               //
//            ██╗  ██╗███████╗███████╗███╗   ███╗ ██████╗ ██╗  ██╗ █████╗ ███████╗██╗            //
//            ██║ ██╔╝██╔════╝██╔════╝████╗ ████║██╔═══██╗██║ ██╔╝██╔══██╗╚══███╔╝██║            //
//            █████╔╝ █████╗  █████╗  ██╔████╔██║██║   ██║█████╔╝ ███████║  ███╔╝ ██║            //
//            ██╔═██╗ ██╔══╝  ██╔══╝  ██║╚██╔╝██║██║   ██║██╔═██╗ ██╔══██║ ███╔╝  ██║            //
//            ██║  ██╗███████╗███████╗██║ ╚═╝ ██║╚██████╔╝██║  ██╗██║  ██║███████╗██║            //
//            ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝            //
//                                                                                               //
//                                                                                               //
//                                                                                               //
///////////////////////////////////////////////////////////////////////////////////////////////////
contract KeemokaziTiktokCourse is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    using Strings for uint256;

    uint256 public PRICE = 0.20 ether;
    uint256 public PERNFTs = 3;
    string public baseTokenURI;
    Counters.Counter private _tokenIdTracker;

    bool locked = true;

    mapping (address => uint) public ownWallet;

    event NewPriceEvent(uint256 price);
    event NewPerNFTs(uint256 perNFTs);
    event NewMaxElement(uint256 max);
    event welcomeToKK(uint256 indexed id);

    constructor(string memory baseURI) ERC721("Keemokazi Tiktok Course", "KTC") {
        setBaseURI(baseURI);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, "Keemokazi")) : "";
    }

    function totalToken() public view returns (uint256) {
        return _tokenIdTracker.current();
    }
    
    function mint(uint256 _tokenAmount) public payable {
        uint256 total = totalToken();
        require(ownWallet[msg.sender] < PERNFTs, "Maxium issue");
        require(msg.value >= price(_tokenAmount), "Value below price");

        address wallet = _msgSender();

        for(uint8 i = 1; i <= _tokenAmount; i++) {
            _mintAnElement(wallet, total + i);
        }
    }

    function _mintAnElement(address _to, uint256 _tokenId) private {
        _safeMint(_to, _tokenId);
        ownWallet[_to]++;
        _tokenIdTracker.increment();

        emit welcomeToKK(_tokenId);
    }

    function setLocked(bool _locked) external onlyOwner {
        locked = _locked;
    }
    
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(!locked, "Cannot transfer - currently locked");
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }
    
    function price(uint256 _count) public view returns (uint256) {
        return PRICE.mul(_count);
    }

    function setPrice(uint256 _price) public onlyOwner {
        PRICE = _price;
        emit NewPriceEvent(PRICE);
    }

    function setPerNFTs(uint256 _count) public onlyOwner {
        PERNFTs = _count;
        emit NewPerNFTs(PERNFTs);
    }

    function withdrawAll() public onlyOwner {
        address _owner = msg.sender;
        uint256 balance = address(this).balance;
        require(balance > 0);
        _withdraw(_owner, address(this).balance);
    }

    function _withdraw(address _address, uint256 _amount) private {
        (bool success, ) = _address.call{value: _amount}("");
        require(success, "Transfer failed.");
    }
}