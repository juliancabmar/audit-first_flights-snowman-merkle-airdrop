### [S-#] TITLE (Root Cause + Impact)

**Description:**\

**Impact:**\

**Proof of Concept:**\

**Recommended Mitigation:**\

---------------------------------------------------------------

### [H-#] `Snow::buySnow` function make the earn timer resets

**Description:**\
Calling `Snow::buySnow` function resets the users earn timer, starting the actual earn period over from zero again.

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

### [H-#] Anyone and anytime can mint `Snowman` Nft.

**Description:**\
The `mintSnowman` function in the `Snowman` contract is external and lacks access control.

**Impact:**\
Anyone can mint unlimited Snowman NFTs at any time, breaking scarcity and intended distribution.

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
