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


                l: caller must be a "collector"
                    Collector --> Snow::collectFee()
                        [accumulated fees getted]
                        

                        o: [buyed Snow tokens with ETH]
                        o: [buyed Snow tokens with WETH]
                        o: [earned Snow tokens] 
                            [Snow Tokens owned]


                            p: receiver address (anybody)
                            p: merkle proof
                            p: receiver v
                            p: receiver r
                            p: receiver s
                                User --> SnowmanAirdrop::claimSnowman(params)
                                    [getted Snowman Nfts directly or in representation]