Obtener tokens `Snow` comprandolos:


[ETH on account]    
    p: {value} enough ETH
    p: quantity to buy
        User--> Snow::buySnow{value}(params)
            [buyed Snow tokens with ETH]

[WETH owned]
    p: quantity to buy
        User--> Snow::buySnow(params)
            [buyed Snow tokens with WETH]