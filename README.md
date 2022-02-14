## Mintstarter

Releasing NFT collections via the NFT_collection.sol smart contract

### Information for audit

`NFT_collection.sol`

This is the smart contract that manages the minting and the creation of NFTs, through which users interact via frontend. 
Each NFT has a base price `basePriceMint` and, if someone wants to mint X nfts via the "mint" function, they must send at least
10X basePriceMint in `msg.value`

If the URI is broken, the owner can always fix the URI via the function "fixURI". The owner may also call `renounceURI` function 
and they won't be able to call fixURI ever again.



#### Minified version

If you're trying to compile smart contract all in one, see "MINIFIED.sol" in minified folder