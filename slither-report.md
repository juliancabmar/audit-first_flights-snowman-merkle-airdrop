Summary
 - [arbitrary-send-erc20](#arbitrary-send-erc20) (1 results) (High)
 - [unchecked-transfer](#unchecked-transfer) (1 results) (High)
 - [incorrect-equality](#incorrect-equality) (2 results) (Medium)
 - [reentrancy-no-eth](#reentrancy-no-eth) (1 results) (Medium)
 - [unused-return](#unused-return) (1 results) (Medium)
 - [reentrancy-events](#reentrancy-events) (1 results) (Low)
 - [timestamp](#timestamp) (1 results) (Low)
 - [pragma](#pragma) (1 results) (Informational)
 - [costly-loop](#costly-loop) (1 results) (Informational)
 - [low-level-calls](#low-level-calls) (1 results) (Informational)
 - [naming-convention](#naming-convention) (5 results) (Informational)
 - [unused-state](#unused-state) (1 results) (Informational)
 - [immutable-states](#immutable-states) (2 results) (Optimization)
## arbitrary-send-erc20
Impact: High
Confidence: High
 - [ ] ID-0
[SnowmanAirdrop.claimSnowman(address,bytes32[],uint8,bytes32,bytes32)](src/SnowmanAirdrop.sol#L69-L99) uses arbitrary from in transferFrom: [i_snow.safeTransferFrom(receiver,address(this),amount)](src/SnowmanAirdrop.sol#L92)

src/SnowmanAirdrop.sol#L69-L99


## unchecked-transfer
Impact: High
Confidence: Medium
 - [ ] ID-1
[Snow.collectFee()](src/Snow.sol#L101-L107) ignores return value by [i_weth.transfer(s_collector,collection)](src/Snow.sol#L103)

src/Snow.sol#L101-L107


## incorrect-equality
Impact: Medium
Confidence: High
 - [ ] ID-2
[SnowmanAirdrop.claimSnowman(address,bytes32[],uint8,bytes32,bytes32)](src/SnowmanAirdrop.sol#L69-L99) uses a dangerous strict equality:
	- [i_snow.balanceOf(receiver) == 0](src/SnowmanAirdrop.sol#L76)

src/SnowmanAirdrop.sol#L69-L99


 - [ ] ID-3
[SnowmanAirdrop.getMessageHash(address)](src/SnowmanAirdrop.sol#L112-L122) uses a dangerous strict equality:
	- [i_snow.balanceOf(receiver) == 0](src/SnowmanAirdrop.sol#L113)

src/SnowmanAirdrop.sol#L112-L122


## reentrancy-no-eth
Impact: Medium
Confidence: Medium
 - [ ] ID-4
Reentrancy in [Snowman.mintSnowman(address,uint256)](src/Snowman.sol#L36-L44):
	External calls:
	- [_safeMint(receiver,s_TokenCounter)](src/Snowman.sol#L38)
		- [ERC721Utils.checkOnERC721Received(_msgSender(),address(0),to,tokenId,data)](lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#L315)
		- [retval = IERC721Receiver(to).onERC721Received(operator,from,tokenId,data)](lib/openzeppelin-contracts/contracts/token/ERC721/utils/ERC721Utils.sol#L33-L47)
	State variables written after the call(s):
	- [s_TokenCounter ++](src/Snowman.sol#L42)
	[Snowman.s_TokenCounter](src/Snowman.sol#L23) can be used in cross function reentrancies:
	- [Snowman.constructor(string)](src/Snowman.sol#L30-L33)
	- [Snowman.getTokenCounter()](src/Snowman.sol#L76-L78)
	- [Snowman.mintSnowman(address,uint256)](src/Snowman.sol#L36-L44)

src/Snowman.sol#L36-L44


## unused-return
Impact: Medium
Confidence: Medium
 - [ ] ID-5
[SnowmanAirdrop._isValidSignature(address,bytes32,uint8,bytes32,bytes32)](src/SnowmanAirdrop.sol#L102-L109) ignores return value by [(actualSigner,None,None) = ECDSA.tryRecover(digest,v,r,s)](src/SnowmanAirdrop.sol#L107)

src/SnowmanAirdrop.sol#L102-L109


## reentrancy-events
Impact: Low
Confidence: Medium
 - [ ] ID-6
Reentrancy in [Snowman.mintSnowman(address,uint256)](src/Snowman.sol#L36-L44):
	External calls:
	- [_safeMint(receiver,s_TokenCounter)](src/Snowman.sol#L38)
		- [ERC721Utils.checkOnERC721Received(_msgSender(),address(0),to,tokenId,data)](lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#L315)
		- [retval = IERC721Receiver(to).onERC721Received(operator,from,tokenId,data)](lib/openzeppelin-contracts/contracts/token/ERC721/utils/ERC721Utils.sol#L33-L47)
	Event emitted after the call(s):
	- [SnowmanMinted(receiver,s_TokenCounter)](src/Snowman.sol#L40)

src/Snowman.sol#L36-L44


## timestamp
Impact: Low
Confidence: Medium
 - [ ] ID-7
[Snow.earnSnow()](src/Snow.sol#L92-L99) uses timestamp for comparisons
	Dangerous comparisons:
	- [s_earnTimer != 0 && block.timestamp < (s_earnTimer + 604800)](src/Snow.sol#L93)

src/Snow.sol#L92-L99


## pragma
Impact: Informational
Confidence: High
 - [ ] ID-8
2 different versions of Solidity are used:
	- Version constraint ^0.8.20 is used by:
		-[^0.8.20](lib/openzeppelin-contracts/contracts/access/Ownable.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/interfaces/IERC1363.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/interfaces/IERC165.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/interfaces/IERC5267.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol#L3)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Metadata.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC721/utils/ERC721Utils.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/utils/Base64.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/utils/Context.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/utils/Panic.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/utils/ShortStrings.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/utils/StorageSlot.sol#L5)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/utils/Strings.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/utils/cryptography/Hashes.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol#L5)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/utils/math/SafeCast.sol#L5)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/utils/math/SignedMath.sol#L4)
	- Version constraint ^0.8.24 is used by:
		-[^0.8.24](src/Snow.sol#L2)
		-[^0.8.24](src/Snowman.sol#L2)
		-[^0.8.24](src/SnowmanAirdrop.sol#L2)
		-[^0.8.24](src/mock/MockWETH.sol#L2)

lib/openzeppelin-contracts/contracts/access/Ownable.sol#L4


## costly-loop
Impact: Informational
Confidence: Medium
 - [ ] ID-9
[Snowman.mintSnowman(address,uint256)](src/Snowman.sol#L36-L44) has costly operations inside a loop:
	- [s_TokenCounter ++](src/Snowman.sol#L42)

src/Snowman.sol#L36-L44


## low-level-calls
Impact: Informational
Confidence: High
 - [ ] ID-10
Low level call in [Snow.collectFee()](src/Snow.sol#L101-L107):
	- [(collected,None) = address(s_collector).call{value: address(this).balance}()](src/Snow.sol#L105)

src/Snow.sol#L101-L107


## naming-convention
Impact: Informational
Confidence: High
 - [ ] ID-11
Variable [Snow.s_buyFee](src/Snow.sol#L31) is not in mixedCase

src/Snow.sol#L31


 - [ ] ID-12
Parameter [Snow.changeCollector(address)._newCollector](src/Snow.sol#L109) is not in mixedCase

src/Snow.sol#L109


 - [ ] ID-13
Variable [Snowman.s_TokenCounter](src/Snowman.sol#L23) is not in mixedCase

src/Snowman.sol#L23


 - [ ] ID-14
Variable [Snow.i_weth](src/Snow.sol#L34) is not in mixedCase

src/Snow.sol#L34


 - [ ] ID-15
Variable [Snowman.s_SnowmanSvgUri](src/Snowman.sol#L24) is not in mixedCase

src/Snowman.sol#L24


## unused-state
Impact: Informational
Confidence: High
 - [ ] ID-16
[SnowmanAirdrop.s_claimers](src/SnowmanAirdrop.sol#L42) is never used in [SnowmanAirdrop](src/SnowmanAirdrop.sol#L26-L140)

src/SnowmanAirdrop.sol#L42


## immutable-states
Impact: Optimization
Confidence: High
 - [ ] ID-17
[Snow.s_buyFee](src/Snow.sol#L31) should be immutable 

src/Snow.sol#L31


 - [ ] ID-18
[Snow.i_weth](src/Snow.sol#L34) should be immutable 

src/Snow.sol#L34


