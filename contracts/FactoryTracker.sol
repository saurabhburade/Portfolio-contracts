// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

contract FactoryTracker {
    // mapping(string => uint256) myMapping;

    struct PairData {
        address token0;
        address token1;
        uint112 reserve0;
        uint112 reserve1;
        string name;
        string symbol;
        string token0Symbol;
        string token1Symbol;
        uint256 token0Decimals;
        uint256 token1Decimals;
        uint256 totalSupply;
        uint256 balance;
    }
    struct TokenData {
        address _tokenAddress;
        string name;
        string symbol;
        uint256 totalSupply;
        uint256 balance;
    }
    mapping(uint256 => PairData[]) lpsMap;

    struct TokenWithLpsData {
        address _tokenAddress;
        string name;
        string symbol;
        uint256 totalSupply;
        uint256 balance;
        // mapping(uint256 => PairData[]) _lpsMap;
        PairData[] _lp0Data;
        PairData[] _lp1Data;
        PairData[] _lp2Data;
        PairData[] _lp3Data;
    }

    function getPair(address _pairAddress)
        public
        view
        returns (PairData memory)
    {
        IUniswapV2Pair newPair = IUniswapV2Pair(_pairAddress);
        address token0 = newPair.token0();
        address token1 = newPair.token1();

        (uint112 reserve0, uint112 reserve1, uint256 _x) = newPair
            .getReserves();
        // uint112 reserve0 = newPair.getReserves();
        // uint256 reserve1 = newPair.getReserves()[1];

        string memory name = newPair.name();
        string memory symbol = newPair.symbol();
        IERC20 _token0 = IERC20(token0);
        IERC20 _token1 = IERC20(token1);
        string memory token0Symbol = _token0.symbol();
        string memory token1Symbol = _token1.symbol();
        uint256 token0Decimals = _token0.decimals();
        uint256 token1Decimals = _token1.decimals();
        uint256 totalSupply = newPair.totalSupply();
        uint256 balance = 0;

        PairData memory newPairData = PairData(
            token0,
            token1,
            reserve0,
            reserve1,
            name,
            symbol,
            token0Symbol,
            token1Symbol,
            token0Decimals,
            token1Decimals,
            totalSupply,
            balance
        );
        return newPairData;
    }

    function getPairWithBalanceOf(address _pairAddress, address _account)
        public
        view
        returns (PairData memory)
    {
        IUniswapV2Pair newPair = IUniswapV2Pair(_pairAddress);
        address token0 = newPair.token0();
        address token1 = newPair.token1();

        (uint112 reserve0, uint112 reserve1, uint256 _x) = newPair
            .getReserves();
        // uint112 reserve0 = newPair.getReserves();
        // uint256 reserve1 = newPair.getReserves()[1];

        string memory name = newPair.name();
        string memory symbol = newPair.symbol();
        IERC20 _token0 = IERC20(token0);
        IERC20 _token1 = IERC20(token1);
        string memory token0Symbol = _token0.symbol();
        string memory token1Symbol = _token1.symbol();
        uint256 token0Decimals = _token0.decimals();
        uint256 token1Decimals = _token1.decimals();
        uint256 totalSupply = newPair.totalSupply();
        uint256 balance = newPair.balanceOf(_account);

        PairData memory newPairData = PairData(
            token0,
            token1,
            reserve0,
            reserve1,
            name,
            symbol,
            token0Symbol,
            token1Symbol,
            token0Decimals,
            token1Decimals,
            totalSupply,
            balance
        );
        return newPairData;
    }

    function getToken(address _tokenAddress)
        public
        view
        returns (TokenData memory)
    {
        IERC20 newToken = IERC20(_tokenAddress);
        uint256 totalSupply = newToken.totalSupply();
        uint256 balance = 0;
        string memory name = newToken.name();
        string memory symbol = newToken.symbol();
        TokenData memory newTokenData = TokenData(
            _tokenAddress,
            name,
            symbol,
            totalSupply,
            balance
        );

        return newTokenData;
    }

    function getTokenWithBalanceOf(address _tokenAddress, address _account)
        public
        view
        returns (TokenData memory)
    {
        IERC20 newToken = IERC20(_tokenAddress);
        uint256 totalSupply = newToken.totalSupply();
        uint256 balance = newToken.balanceOf(_account);
        string memory name = newToken.name();
        string memory symbol = newToken.symbol();
        TokenData memory newTokenData = TokenData(
            _tokenAddress,
            name,
            symbol,
            totalSupply,
            balance
        );

        return newTokenData;
    }

    function getTokenWithBalanceOfAndLps(
        address _tokenAddress,
        address _account,
        address[] memory _factories,
        address[] memory _quoteTokens
    ) public view returns (TokenWithLpsData memory) {
        IERC20 newToken = IERC20(_tokenAddress);
        uint256 totalSupply = newToken.totalSupply();
        uint256 balance = newToken.balanceOf(_account);
        string memory name = newToken.name();
        string memory symbol = newToken.symbol();
        PairData[] memory lpQuote0;
        PairData[] memory lpQuote1;
        PairData[] memory lpQuote2;
        PairData[] memory lpQuote3;
        // for (uint256 index = 0; index < _factories.length; index++) {
        //     address uniFactoryAddress = _factories[index];
        //     IUniswapV2Factory iUniFactory = IUniswapV2Factory(
        //         uniFactoryAddress
        //     );

        //     for (uint256 index2 = 0; index2 < _quoteTokens.length; index2++) {
        //         address _lp = iUniFactory.getPair(
        //             _tokenAddress,
        //             _quoteTokens[index2]
        //         );
        //         if (index2 == 0) {
        //             lpQuote1[index2] = _lp;
        //         }
        //         // address _lp1 = iUniFactory.getPair(
        //         //     _tokenAddress,
        //         //     _quoteTokens[1]
        //         // );
        //         // lpQuote1[0] = _lp1;
        //         // address _lp2 = iUniFactory.getPair(
        //         //     _tokenAddress,
        //         //     _quoteTokens[2]
        //         // );
        //         // lpQuote2[0] = _lp2;
        //         // address _lp3 = iUniFactory.getPair(
        //         //     _tokenAddress,
        //         //     _quoteTokens[3]
        //         // );
        //         // lpQuote3[0] = _lp3;
        //     }
        // }

        for (uint256 index = 0; index < _quoteTokens.length; index++) {
            for (uint256 index2 = 0; index2 < _factories.length; index2++) {
                address uniFactoryAddress = _factories[index];
                IUniswapV2Factory iUniFactory = IUniswapV2Factory(
                    uniFactoryAddress
                );
                address _lp = iUniFactory.getPair(
                    _tokenAddress,
                    _quoteTokens[index]
                );
                PairData memory newPairData = getPair(_lp);
                if (index == 0) {
                    lpQuote0[index2] = newPairData;
                }
                if (index == 1) {
                    lpQuote1[index2] = newPairData;
                }
                if (index == 2) {
                    lpQuote2[index2] = newPairData;
                }
                if (index == 3) {
                    lpQuote3[index2] = newPairData;
                }
            }
        }
        TokenWithLpsData memory newTokenData = TokenWithLpsData(
            _tokenAddress,
            name,
            symbol,
            totalSupply,
            balance,
            lpQuote0,
            lpQuote1,
            lpQuote2,
            lpQuote3
        );

        return newTokenData;
    }
}
