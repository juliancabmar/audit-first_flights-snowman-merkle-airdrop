### [S-#] TITLE (Root Cause + Impact)

**Description:**\

**Impact:**\

**Proof of Concept:**\

**Recommended Mitigation:**\

---------------------------------------------------------------

### [H] `Snow::buySnow` function make the earn timer resets

**Description:**\
Calling `Snow::buySnow` function resets the users earn timer, starting the actual earn period over from zero again.

```solidity
function buySnow(uint256 amount) external payable canFarmSnow {
    if (msg.value == (s_buyFee * amount)) {
        _mint(msg.sender, amount);
    } else {
        i_weth.safeTransferFrom(msg.sender, address(this), (s_buyFee * amount));
        _mint(msg.sender, amount);
    }

@>  s_earnTimer = block.timestamp;

    emit SnowBought(msg.sender, amount);
}
```

**Impact:**\
Users will lose any unclaimed rewards until the buying execution.

**Proof of Concept:**\
Add the following after the `TestSnowmanAirdrop` test suite:

```solidity
function testBuyResetEarnsTime() public {
    vm.deal(bob, 10 ether);
    uint256 alicePrevBalance = snow.balanceOf(alice);

    vm.warp(block.timestamp + 1 weeks);

    vm.prank(alice);
    snow.earnSnow();

    assertEq(snow.balanceOf(alice), alicePrevBalance + 1);

    vm.warp(block.timestamp + 1 weeks);

    vm.prank(bob);
    snow.buySnow{value: snow.s_buyFee() * 3}(3);

    vm.prank(alice);
    vm.expectRevert(Snow.S__Timer.selector);
    snow.earnSnow();
}
```

**Recommended Mitigation:**\

On Snow.sol:

```diff
    function buySnow(uint256 amount) external payable canFarmSnow {
        if (msg.value == (s_buyFee * amount)) {
            _mint(msg.sender, amount);
        } else {
            i_weth.safeTransferFrom(msg.sender, address(this), (s_buyFee * amount));
            _mint(msg.sender, amount);
        }

-        s_earnTimer = block.timestamp;

        emit SnowBought(msg.sender, amount);
    }
```

### [H] Anyone and anytime can mint `Snowman` Nft freely.

**Description:**\
The `mintSnowman` function in the `Snowman` contract is external and lacks access control.

```solidity
@>  function mintSnowman(address receiver, uint256 amount) external {
        for (uint256 i = 0; i < amount; i++) {
            _safeMint(receiver, s_TokenCounter);

            emit SnowmanMinted(receiver, s_TokenCounter);

            s_TokenCounter++;
        }
    }
```

**Impact:**\
Anyone can mint unlimited Snowman NFTs freely at any time, breaking scarcity and the intended distribution process.

**Proof of Concept:**\
Add the following after the `TestSnowmanAirdrop` test suite:

```solidity
function testAnyoneAnytimeCanMintSnowman() public {
    vm.prank(bob);
    nft.mintSnowman(bob, 10);

    assertEq(nft.balanceOf(bob), 10);
}
```

**Recommended Mitigation:**\
Use the `onlyOwner` modifier on `Snowman::mintSnowman` declaration.

```diff
-   function mintSnowman(address receiver, uint256 amount) external {
+   function mintSnowman(address receiver, uint256 amount) external onlyOwner {
        for (uint256 i = 0; i < amount; i++) {
            // _safeMint(receiver, s_TokenCounter);

            emit SnowmanMinted(receiver, s_TokenCounter);

            s_TokenCounter++;
        }
    }
```

### [H] Unbounded minting allow DoS on `Snowman Nft`.

**Description:**\
An attaker can mint Snowman NFT until counter reach the maximum value of uint256, after which no more NFTs can be minted, because this will cause a overflow condition.

**Impact:**\
Once the counter hits its upper limit, no further Snowman NFTs can be claimed or minted, causing a permanent denial of service for new claimants.

**Proof of Concept:**\
Add the following after the `TestSnowmanAirdrop` test suite:

```solidity
function testDoSOnSnowmanNft() public {
    // Simulating an attaker who has minted snow until the limit
    vm.pauseGasMetering();
    nft.mintSnowman(bob, type(uint256).max);
    vm.resumeGasMetering();

    // Alice claim setup
    vm.prank(alice);
    snow.approve(address(airdrop), 1);

    // Get alice's digest
    bytes32 alDigest = airdrop.getMessageHash(alice);

    // alice signs a message
    (uint8 alV, bytes32 alR, bytes32 alS) = vm.sign(alKey, alDigest);

    // Alice try to claims a Nft using her signed message
    vm.expectRevert();
    vm.prank(alice);
    airdrop.claimSnowman(alice, AL_PROOF, alV, alR, alS);
}
```

**Recommended Mitigation:**\
Set a max amount of Snowman to mint per address


### [S-#] Balance change after snapshot breaks merkle proof, making Nft claims fail.

**Description:**\
If a user receives extra Snow tokens before claiming their NFT in `SnowmanAirdrop`, their claim will fail. This is because the `SnowmanAirdrop::claimSnowman` function uses the snow balance of the user to make the leaf for the merkle tree, and how this was set before with a fixed value, the related verification will fails.

```solidity
function claimSnowman(address receiver, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s)
    external
    nonReentrant
{
    if (receiver == address(0)) {
        revert SA__ZeroAddress();
    }
    if (i_snow.balanceOf(receiver) == 0) {
        revert SA__ZeroAmount();
    }

    if (!_isValidSignature(receiver, getMessageHash(receiver), v, r, s)) {
        revert SA__InvalidSignature();
    }

@>  uint256 amount = i_snow.balanceOf(receiver);

@>  bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(receiver, amount))));

    if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
        revert SA__InvalidProof();
    }

    i_snow.safeTransferFrom(receiver, address(this), amount); // send tokens to contract... akin to burning

    s_hasClaimedSnowman[receiver] = true;

    emit SnowmanClaimedSuccessfully(receiver, amount);

    i_snowman.mintSnowman(receiver, amount);
}
```


**Impact:**\
Users who receive additional Snow tokens (e.g., via transfer) before claiming cannot claim their NFT, potentially locking them out of the airdrop.

**Proof of Concept:**\
Add the following after the `TestSnowmanAirdrop` test suite:

```solidity
function testBalanceChangeDenialClaim() public {
    // Bob send to Alice 1 snow increasing her balance to 2
    vm.prank(bob);
    snow.transfer(alice, 1);

    // Alice claim setup
    vm.prank(alice);
    snow.approve(address(airdrop), 2);

    // Get alice's digest
    bytes32 alDigest = airdrop.getMessageHash(alice);

    // alice signs a message
    (uint8 alV, bytes32 alR, bytes32 alS) = vm.sign(alKey, alDigest);

    // Alice try to claims a Nft using her signed message
    vm.expectRevert(SnowmanAirdrop.SA__InvalidProof.selector);
    vm.prank(alice);
    airdrop.claimSnowman(alice, AL_PROOF, alV, alR, alS);
}
```

**Recommended Mitigation:**\
On `SnowmanAirdrop::claimSnowman`function allow only one nft per claim:

```diff
function claimSnowman(address receiver, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s)
    external
    nonReentrant
{
    if (receiver == address(0)) {
        revert SA__ZeroAddress();
    }
    if (i_snow.balanceOf(receiver) == 0) {
        revert SA__ZeroAmount();
    }

    if (!_isValidSignature(receiver, getMessageHash(receiver), v, r, s)) {
        revert SA__InvalidSignature();
    }

-   uint256 amount = i_snow.balanceOf(receiver);
+   uint256 amount = 1;

    bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(receiver, amount))));

    if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
        revert SA__InvalidProof();
    }

    i_snow.safeTransferFrom(receiver, address(this), amount); // send tokens to contract... akin to burning

    s_hasClaimedSnowman[receiver] = true;

    emit SnowmanClaimedSuccessfully(receiver, amount);

    i_snowman.mintSnowman(receiver, amount);
}
```

### [M] Unburned Snow tokens becomes inflationary.

**Description:**\
When a user claims an NFT in `SnowmanAirdrop`, the Snow tokens are transferred to the contract but never burned, remaining in circulation.

**Impact:**\
This leads to inflation of the Snow token supply, as claimed tokens are not removed from the total supply, potentially reducing the token's value and undermining the intended tokenomics.


**Recommended Mitigation:**\
Burn just after Nft minting:

```diff
function claimSnowman(address receiver, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s)
    external
    nonReentrant
{
    if (receiver == address(0)) {
        revert SA__ZeroAddress();
    }
    if (i_snow.balanceOf(receiver) == 0) {
        revert SA__ZeroAmount();
    }

    if (!_isValidSignature(receiver, getMessageHash(receiver), v, r, s)) {
        revert SA__InvalidSignature();
    }

    uint256 amount = i_snow.balanceOf(receiver);

    bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(receiver, amount))));

    if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
        revert SA__InvalidProof();
    }

    i_snow.safeTransferFrom(receiver, address(this), amount); // send tokens to contract... akin to burning

    s_hasClaimedSnowman[receiver] = true;

    emit SnowmanClaimedSuccessfully(receiver, amount);

    i_snowman.mintSnowman(receiver, amount);
+   i_snow.burn(amount);
}
```

### [L] Misspelling on `SnowmanAirdrop::MESSAGE_TYPEHASH`. 

**Description:**\
The `MESSAGE_TYPEHASH` constant in `SnowmanAirdrop` is misspelled as `"SnowmanClaim(addres receiver, uint256 amount)"` (missing a "s" in "address").

**Impact:**\
None

**Recommended Mitigation:**\
Correct the spelling to `address`:

```diff
- bytes32 private constant MESSAGE_TYPEHASH = keccak256("SnowmanClaim(addres receiver, uint256 amount)");
+ bytes32 private constant MESSAGE_TYPEHASH = keccak256("SnowmanClaim(address receiver, uint256 amount)");
```

### [L] Array `SnowmanAirdrop::s_claimers` never used.

**Description:**\
The `SnowmanAirdrop::s_claimers` array is never used on the entirely protocol.

```solidity
    .
    .
    // >>> TYPE
    struct SnowmanClaim {
        address receiver;
        uint256 amount;
    }

    // >>> VARIABLES
@>  address[] private s_claimers; // array to store addresses of claimers
    bytes32 private immutable i_merkleRoot; // Merkle root used to validate airdrop claims
    Snow private immutable i_snow; // Snow token to be staked for the airdrop
    Snowman private immutable i_snowman; // Snowman nft to be claimed

    mapping(address => bool) private s_hasClaimedSnowman; // mapping to verify if an address has claimed Snowman
    .
    .
```

**Recommended Mitigation:**\
Remove or use it


### [L] Error `Snowman::SM__NotAllowed` never used

**Description:**\
The error `Snowman::SM__NotAllowed` was declared but never used in the entirely protocol.

```solidity
contract Snowman is ERC721, Ownable {
    // >>> ERROR
    error ERC721Metadata__URI_QueryFor_NonExistentToken();
@>  error SM__NotAllowed();

    // >>> VARIABLES
    uint256 private s_TokenCounter;
    string private s_SnowmanSvgUri;

    // >>> EVENTS
    event SnowmanMinted(address indexed receiver, uint256 indexed numberOfSnowman);
    .
    .
```

**Recommended Mitigation:**\
Remove or use it


### [L] `Snow::changeCollector` function not check for duplicate collectors.

**Description:**\
The `Snow::changeCollector` function have check for zero address, but not for set the active collector again.

```solidity
function changeCollector(address _newCollector) external onlyCollector {
    if (_newCollector == address(0)) {
        revert S__ZeroAddress();
    }

@>  s_collector = _newCollector;

    emit NewCollector(_newCollector);
}
```

**Impact:**\
Unnecesary gas consumption

**Recommended Mitigation:**\
On `Snow::changeCollector` revert if the new collector address is the same that the old:

```diff
function changeCollector(address _newCollector) external onlyCollector {
    if (_newCollector == address(0)) {
        revert S__ZeroAddress();
    }

+   if (s_collector == _newCollector) {
+       revert("Not Allow The Same Address");
+   }

    s_collector = _newCollector;

    emit NewCollector(_newCollector);
}
```


### [S-#] Event `Snow::FeeCollected` not used on collect fees.

**Description:**\
The `FeeCollected` event is declared in the `Snow` contract but is never emitted during the fee collection process.

```solidity
    // >>> EVENTS
    event SnowBought(address indexed buyer, uint256 indexed amount);
    event SnowEarned(address indexed earner, uint256 indexed amount);
@>  event FeeCollected();
    event NewCollector(address indexed newCollector);
```

**Impact:**\
Lack of event emission reduces transparency and makes it harder for off-chain systems or users to track when fees are collected.

**Recommended Mitigation:**\
Emit the `FeeCollected` event inside the `collectFees` function:

```diff
function collectFee() external onlyCollector {
    uint256 collection = i_weth.balanceOf(address(this));
    emit 
    i_weth.transfer(s_collector, collection);
+   emit FeeCollected();
    (bool collected,) = payable(s_collector).call{value: address(this).balance}("");
    require(collected, "Fee collection failed!!!");
}
```


### [L] Event `Snow::SnowEarned` not used on earn function

**Description:**\
The `SnowEarned` event is declared in the `Snow` contract but is never emitted in the `earnSnow` function.

**Impact:**\
Not emitting this event reduces transparency and makes it difficult for off-chain systems or users to track when Snow tokens are earned.

**Recommended Mitigation:**\
Emit the `SnowEarned` event inside the `earnSnow` function:

```diff
function earnSnow() external canFarmSnow {
    if (s_earnTimer != 0 && block.timestamp < (s_earnTimer + 1 weeks)) {
        revert S__Timer();
    }
    _mint(msg.sender, 1);

    s_earnTimer = block.timestamp;
+   emit SnowEarned(msg.sender, 1);
}
```

### [M] Calls `Snow::earnSnow` disable the earns for all users for another one week

**Description:**\
The `Snow::earnSnow` function uses a single global timer (`s_earnTimer`) for earning, affecting all users earnings.

```solidity
    function earnSnow() external canFarmSnow {
        if (s_earnTimer != 0 && block.timestamp < (s_earnTimer + 1 weeks)) {
            revert S__Timer();
        }
        _mint(msg.sender, 1);

@>      s_earnTimer = block.timestamp;
    }
```

**Impact:**\
Only the first caller can earn Snow, and then all users are blocked from earning for one week, preventing fair participation and breaking the intended earning mechanism.

**Proof of Concept:**\
Add the following after the `TestSnowmanAirdrop` test suite:

```solidity
function testOnlyFirstCanEarnSnow() public {
    vm.warp(block.timestamp + 1 weeks);

    vm.prank(alice);
    snow.earnSnow(); // Alice earns successfully

    vm.expectRevert(Snow.S__Timer.selector);
    vm.prank(bob);
    snow.earnSnow(); // Bob is blocked for one week
}
```

**Recommended Mitigation:**\
Track the earn timer per user (e.g., with a mapping: `mapping(address => uint256) s_earnTimer;`) so each user has their own cooldown timer.