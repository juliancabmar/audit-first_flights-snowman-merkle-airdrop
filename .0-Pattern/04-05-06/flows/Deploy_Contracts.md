[---]deployar los contratos
deploy and initialize Snow contract [A: Deployer / T: Snow::constructor]
deploy and initialize Snowman contract [A: Deployer / T: Snowman::constructor]
    deploy and initialize SnowmanAirDrop contract [A: Deployer / T: SnowAirDrop::constructor]

```solidity
function testDeployContracts() public {
    // common setup
    address deployer = makeAddr("deployer");
    address collector = makeAddr("collector");

    // deploying Snow Token
    MockWETH weth = new MockWETH();
    uint256 fee = 5;
    vm.prank(deployer);
    Snow snow = new Snow(address(weth), fee, collector);

    // deploying Snowman
    string memory snowmanSvg = vm.readFile("./img/snowman.svg");
    vm.prank(deployer);
    Snowman snowman = new Snowman(svgToImageURI(snowmanSvg));

    // deploying SnowmanAirdrop
    vm.prank(deployer);
    bytes32 s_MERKLE_ROOT = 0xc0b6787abae0a5066bc2d09eaec944c58119dc18be796e93de5b2bf9f80ea79a; // Gotten from output.json
    SnowmanAirdrop airdrop = new SnowmanAirdrop(s_MERKLE_ROOT, address(snow), address(snowman));

    console2.log("Snow contract: ", address(snow));
    console2.log("Snowman contract: ", address(snowman));
    console2.log("SnowmanAirdrop contract: ", address(airdrop));
}

function svgToImageURI(string memory svg) public pure returns (string memory) {
    string memory baseURL = "data:image/svg+xml;base64,";
    string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
    return string(abi.encodePacked(baseURL, svgBase64Encoded));
}
```
WETH Deployer--> WETH::constructor(params)
    [WETH token contract deployed]
        p: WETH token address
        p: fee
        p: Collector address
            Deployer--> Snow::constructor(params)
                    [Snow contract deployed]

p: Uri image
    Deployer--> Snowman::constructor(params)
        [Snowman contract deployed]

    p: merkle root hash
[Snow contract deployed]    
    p: Snow token contract address
[Snowman contract deployed]
    p: Snowman Nft contract address
    Deployer--> SnowmanAirdrop::constructor(params)
        [SnowmanAirdrop contract deployed]

[ETH on account]    
    p: {value} enough ETH
    p: quantity to buy
        User--> Snow::buySnow{value}(params)
            [buyed Snow tokens with ETH]

[WETH owned]
    p: quantity to buy
        User--> Snow::buySnow(params)
            [buyed Snow tokens with WETH]

l: be on Farming season
l: a week passed from the last claim
        User--> Snow::earnSnow()
            [earned Snow tokens]

o: [buyed Snow tokens with ETH]
o: [buyed Snow tokens with WETH]
o: [earned Snow tokens] 
    [Snow Tokens owned]


[getted Snowman Nfts directly]