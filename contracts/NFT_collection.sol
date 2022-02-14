// main smart contract

pragma solidity ^0.8.0;

import "../interfaces/ReentrancyGuard.sol"; 
import "./libraries/SafeMath.sol";
import "./ERC721.sol"; 

contract NFT_Collection is ERC721, ReentrancyGuard {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  using SafeMath for uint256;
  address public owner;
  uint256 public royalty; 
  uint256 public mintPrice;
  uint256 public startMint;
  uint256 public basePriceMint;
  uint256 public maxSupply;
  bool public renounceURIFIX = false;
  address nftmintstarter = 0xe6D97963b41ca32B923Fad0B39e74834DDD01594;

    // project info
  address public twitter;
  address public instagram;
  address public website; 
  address public telegram;

  constructor (string memory name, string memory symbol, uint256 _royalty, uint256 basePrice, uint256 _startMint, uint256 _max, address _twitter, address _insta, address _website, address _tgram) ERC721(name, symbol){
      owner = msg.sender;
      royalty = _royalty;
      startMint = _startMint;
      basePriceMint = basePrice;
      maxSupply = _max;
      twitter = _twitter;
      instagram = _insta;
      website = _website;
      telegram = _tgram;
  }

  struct Artwork{
    uint256 id;
    address payable creator;
    address tokenAddress;
    string uri;
    uint8 royalty;
  }

  mapping(uint256 => Artwork) public Artworks;
  event WithdrawBNB(uint256 _value);

  function mint(uint256 _amount, string[] memory uri) external payable nonReentrant {
      uint256 amountToPay = _amount.mul(basePriceMint);
      require(msg.value >= amountToPay, "invalid price paid");
      require(block.timestamp > startMint, "presale did not start");
      uint256 supplyBeing = _tokenIds.current().add(_amount);
      require(supplyBeing <= maxSupply, "finished minting");

      for(uint256 i=0; i<_amount; i++){
          _tokenIds.increment();
          uint256 currentID = _tokenIds.current();
          _safeMint(msg.sender, currentID);
          Artworks[currentID] = Artwork(currentID, payable(msg.sender), address(this), uri[i], 0);
      }
  }

    function fixURI(uint256 _id, string memory uri) public {
        require(msg.sender == owner && renounceURIFIX == false, "invalid");
        Artworks[_id].uri = uri;
    }

    function fixURImultiple(uint256[] memory _id, string[] memory uri) public {
        require(msg.sender == owner && renounceURIFIX == false, "invalid");
        require(_id.length == uri.length, "invalid");
        for(uint i=0; i<_id.length; i++){
        Artworks[_id[i]].uri = uri[i];
        }
    }

    function renounceURI() public {
        require(msg.sender == owner, "invalid owner");
        renounceURIFIX = true;
    }

    function returnLastId() public view returns(uint256){
        return _tokenIds.current();
    }

  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

    return Artworks[tokenId].uri;
  }

  function withdrawBNB() public {
      require(msg.sender == owner, "invalid owner");
      uint256 balance = address(this).balance;
      uint256 platformFee = balance.mul(200).div(10000); // 2%
      payable(nftmintstarter).transfer(platformFee);
      payable(msg.sender).transfer(balance.sub(platformFee));
      emit WithdrawBNB(balance);
  }

  function getRoyalty(uint256 tokenId) external virtual view returns(uint8 _royalty){
    require(_exists(tokenId), "ERC721Metadata: Royalty query for nonexistent token");

    return Artworks[tokenId].royalty;
  }

  function getCreator(uint256 tokenId) external virtual view returns(address payable creator){
    require(_exists(tokenId), "ERC721Metadata: Creator query for nonexistent token");

    return payable(Artworks[tokenId].creator);
  }
}
