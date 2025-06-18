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

