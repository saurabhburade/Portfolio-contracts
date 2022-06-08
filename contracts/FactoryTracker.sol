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
    mapping(uint256 => PairData[]) public lpsMap;

    struct TokenWithLpsData {
        address _tokenAddress;
        string name;
        string symbol;
        uint256 totalSupply;
        uint256 balance;
        // PairData[] _lp0Data;
        // PairData[] _lp1Data;
        // PairData[] _lp2Data;
        // PairData[] _lp3Data;
        // mapping(uint256 => PairData) _lp0Data;
        // mapping(uint256 => PairData) _lp1Data;
        // mapping(uint256 => PairData) _lp2Data;
        // mapping(uint256 => PairData) _lp3Data;
    }

    function getPair(address _pairAddress)
        public
        view
        returns (PairData memory)
    {
        PairData memory newPairData;
        IUniswapV2Pair newPair = IUniswapV2Pair(_pairAddress);
        newPairData.token0 = newPair.token0();
        newPairData.token1 = newPair.token1();

        (uint112 reserve0, uint112 reserve1, uint256 _x) = newPair
            .getReserves();
        // uint112 reserve0 = newPair.getReserves();
        // uint256 reserve1 = newPair.getReserves()[1];

        newPairData.name = newPair.name();
        newPairData.symbol = newPair.symbol();
        IERC20 _token0 = IERC20(newPairData.token0);
        IERC20 _token1 = IERC20(newPairData.token1);
        newPairData.token0Symbol = _token0.symbol();
        newPairData.token1Symbol = _token1.symbol();
        newPairData.token0Decimals = _token0.decimals();
        newPairData.token1Decimals = _token1.decimals();
        newPairData.totalSupply = newPair.totalSupply();
        newPairData.balance = 0;
        newPairData.reserve0 = reserve0;
        newPairData.reserve1 = reserve1;

        return newPairData;
    }

    function getPairWithBalanceOf(address _pairAddress, address _account)
        public
        view
        returns (PairData memory)
    {
        PairData memory newPairData;

        IUniswapV2Pair newPair = IUniswapV2Pair(_pairAddress);
        newPairData.token0 = newPair.token0();
        newPairData.token1 = newPair.token1();

        (uint112 reserve0, uint112 reserve1, uint256 _x) = newPair
            .getReserves();

        newPairData.name = newPair.name();
        newPairData.symbol = newPair.symbol();
        IERC20 _token0 = IERC20(newPairData.token0);
        IERC20 _token1 = IERC20(newPairData.token1);
        newPairData.token0Symbol = _token0.symbol();
        newPairData.token1Symbol = _token1.symbol();
        newPairData.token0Decimals = _token0.decimals();
        newPairData.token1Decimals = _token1.decimals();
        newPairData.totalSupply = newPair.totalSupply();
        newPairData.balance = newPair.balanceOf(_account);
        newPairData.reserve0 = reserve0;
        newPairData.reserve1 = reserve1;

        return newPairData;
    }

    function getToken(address _tokenAddress)
        public
        view
        returns (TokenData memory)
    {
        TokenData memory newTokenData;
        IERC20 newToken = IERC20(_tokenAddress);
        newTokenData.totalSupply = newToken.totalSupply();
        newTokenData.balance = 0;
        newTokenData.name = newToken.name();
        newTokenData.symbol = newToken.symbol();
        newTokenData._tokenAddress = _tokenAddress;

        return newTokenData;
    }

    function getTokenWithBalanceOf(address _tokenAddress, address _account)
        public
        view
        returns (TokenData memory)
    {
        TokenData memory newTokenData;
        IERC20 newToken = IERC20(_tokenAddress);
        newTokenData.totalSupply = newToken.totalSupply();
        newTokenData.balance = newToken.balanceOf(_account);
        newTokenData.name = newToken.name();
        newTokenData.symbol = newToken.symbol();
        newTokenData._tokenAddress = _tokenAddress;

        return newTokenData;
    }


    function getTokenWithBalanceOfAndLps(
        address _tokenAddress,
        address _account,
        address[] memory _factories,
        address[] memory _quoteTokens
    )
        public
        view
        returns (
            TokenData memory _tokenData,
            PairData[] memory _pair0,
            PairData[] memory _pair1,
            PairData[] memory _pair2,
            PairData[] memory _pair3
        )
    {
        // address[]  _lp0Data;
        PairData[] memory _lp0Data = new PairData[](_factories.length);
        // TokenWithLpsData memory newTokenData;
        TokenData memory newTokenData = getTokenWithBalanceOf(
            _tokenAddress,
            _account
        );
        // newTokenData.totalSupply = newToken.totalSupply();
        // newTokenData.balance = newToken.balanceOf(_account);
        // newTokenData.name = newToken.name();
        // newTokenData.symbol = newToken.symbol();
        // newTokenData._tokenAddress = _tokenAddress;
        PairData[] memory _lp1Data = new PairData[](_factories.length);
        PairData[] memory _lp2Data = new PairData[](_factories.length);
        PairData[] memory _lp3Data = new PairData[](_factories.length);

        address[] memory quoteTokenAddresses = _quoteTokens;
        address[] memory factoriesAddresses = _factories;
        address uniFactoryAddress;
        IUniswapV2Factory iUniFactory;
        address _lp;
        PairData memory newPairData;
        for (uint256 index = 0; index < quoteTokenAddresses.length; index++) {
            for (
                uint256 index2 = 0;
                index2 < factoriesAddresses.length;
                index2++
            ) {
                uniFactoryAddress = factoriesAddresses[index2];
                iUniFactory = IUniswapV2Factory(uniFactoryAddress);
                _lp = iUniFactory.getPair(
                    newTokenData._tokenAddress,
                    quoteTokenAddresses[index]
                );
                // newPairData = getPair(_lp);
                // _lp0Data[index2] = newPairData;

                // _lp0Data.push();
                // lpsMap[index][index2]=newPairData;

                //  if (index == 0) {
                // _lp0Data[index2] = _lp;
                // }
                if (_lp != address(0)) {
                    newPairData = getPair(_lp);
                    if (index == 0) {
                        _lp0Data[index2] = newPairData;
                    }
                    if (index == 1) {
                        _lp1Data[index2] = newPairData;
                    }
                    if (index == 2) {
                        _lp2Data[index2] = newPairData;
                    }
                    if (index == 3) {
                        _lp3Data[index2] = newPairData;
                    }
                }
            }
        }

        return (newTokenData, _lp0Data, _lp1Data, _lp2Data, _lp3Data);
    }
}
