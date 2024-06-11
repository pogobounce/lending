// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import {Proxy} from "../src/proxy/Proxy.sol";
import {WETH} from "solmate/tokens/WETH.sol";
import {Beacon} from "../src/proxy/Beacon.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {Account} from "../src/core/Account.sol";
import {LEther} from "../src/tokens/LEther.sol";
import {LToken} from "../src/tokens/LToken.sol";
import {IOracle} from "oracle/core/IOracle.sol";
import {Registry} from "../src/core/Registry.sol";
import {RiskEngine} from "../src/core/RiskEngine.sol";
import {WETHOracle} from "oracle/weth/WETHOracle.sol";
import {OracleFacade} from "oracle/core/OracleFacade.sol";
import {AccountManager} from "../src/core/AccountManager.sol";
import {AccountFactory} from "../src/core/AccountFactory.sol";
import {DefaultRateModel} from "../src/core/DefaultRateModel.sol";
import {LinearRateModel} from "../src/core/LinearRateModel.sol";
import {ArbiChainlinkOracle} from "oracle/chainlink/ArbiChainlinkOracle.sol";
import {ControllerFacade} from "controller/core/ControllerFacade.sol";
import {IController} from "controller/core/IController.sol";
import {AggregatorV3Interface} from "oracle/chainlink/AggregatorV3Interface.sol";
import {UniV3Controller} from "controller/uniswap/UniV3Controller.sol";
import {UniV2Controller} from "controller/uniswap/UniV2Controller.sol";
import {IUniV2Factory} from "controller/uniswap/IUniV2Factory.sol";
import {WETHController} from "controller/weth/WETHController.sol";
import {AaveV3Controller} from "controller/aave/AaveV3Controller.sol";
import {AaveEthController} from "controller/aave/AaveEthController.sol";
import {CurveCryptoSwapController} from "controller/curve/CurveCryptoSwapController.sol";
import {StableSwap2PoolController} from "controller/curve/StableSwap2PoolController.sol";
import {ATokenOracle} from "oracle/aave/ATokenOracle.sol";
import {Stable2CurveOracle} from "oracle/curve/Stable2CurveOracle.sol";
import {CurveTriCryptoOracle} from "oracle/curve/CurveTriCryptoOracle.sol";
import {ICurveTriCryptoOracle} from "oracle/curve/CurveTriCryptoOracle.sol";
import {ICurvePool} from "oracle/curve/CurveTriCryptoOracle.sol";
import {UniV2LpOracle} from "oracle/uniswap/UniV2LPOracle.sol";

contract Deploy is Test {
    address constant TREASURY = 0xEe7c97F035cD96DdBE93005c16cb236b5f077243;

    // arbi erc20
    address constant WETH9 = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address constant DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
    address constant WBTC = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;
    address constant USDC = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;
    address constant USDT = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9;

    // chainlink price feed
    address constant SEQUENCER = 0xFdB631F5EE196F0ed6FAa767959853A9F217697D;
    address constant ETHUSD = 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;
    address constant DAIUSD = 0xc5C8E77B397E531B8EC06BFb0048328B30E9eCfB;
    address constant WBTCUSD = 0x6ce185860a4963106506C203335A2910413708e9;
    address constant USDCUSD = 0x50834F3163758fcC1Df9973b6e91f0F0F0434aD3;
    address constant USDTUSD = 0x3f3f5dF88dC9F13eac63DF89EC16ef6e7E25DdE7;

    // Aave
    address constant AAVE_POOL = 0x794a61358D6845594F94dc1DB02A252b5b4814aD;
    address constant WETH_GATEWAY = 0xC09e69E79106861dF5d289dA88349f10e2dc6b5C;
    address constant aWETH = 0xe50fA9b3c56FfB159cB0FCA61F5c9D750e8128c8;
    address constant aWBTC = 0x078f358208685046a11C85e8ad32895DED33A249;
    address constant aDAI = 0x82E64f49Ed5EC1bC6e43DAD4FC8Af9bb3A2312EE;

    // SushiSwap
    address constant FACTORY = 0xc35DADB65012eC5796536bD9864eD8773aBc74C4;
    address constant SUSHI_ROUTER = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;
    address constant SLP = 0x692a0B300366D1042679397e40f3d2cb4b8F7D30;

    // Uniswap
    address constant ROUTER = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;

    // Curve
    address constant TWOPOOL = 0x7f90122BF0700F9E7e1F688fe926940E8839F353;
    address constant TRIPOOL = 0x960ea3e3C7FB317332d990873d354E18d7645590;
    address constant TRICRYPTO = 0x8e0B8c8BB9db49a46697F3a5Bb8A308e744821D2;
    address constant TRICRYPTOPRICE = 0xE76BF7161d362a47863Bf53265A3298cB4199954;

    // Protocol
    Registry registryImpl;
    Registry registry;
    Account account;
    AccountManager accountManagerImpl;
    AccountManager accountManager;
    RiskEngine riskEngine;
    Beacon beacon;
    AccountFactory accountFactory;
    LinearRateModel rateModel;
		LinearRateModel rateModelStable;

    // LTokens
    LEther lEthImpl;
    LEther lEth;
    LToken lToken;
    LToken lDai;
    LToken LWBTC;
    LToken LUSDT;
		LToken LUSDC;

    // Controllers
    ControllerFacade controller;
    UniV3Controller uniSwapController;
    UniV2Controller sushiSwapController;
    AaveEthController aaveEthController;
    AaveV3Controller aaveController;
    CurveCryptoSwapController curveTriCryptoController;
    StableSwap2PoolController curveStableSwapController;
    WETHController wethController;

    // Oracles
    OracleFacade oracle;
    WETHOracle wethOracle;
    ArbiChainlinkOracle chainlinkOracle;
    ATokenOracle aTokenOracle;
    CurveTriCryptoOracle curveTriCryptoOracle;
    Stable2CurveOracle stable2crvOracle;
    UniV2LpOracle SLPOracle;

		// forge script ./scripts/deploy.sol --rpc-url <rpc_url> --broadcast --with-gas-price 13000000 --slow
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
				vm.startBroadcast(deployerPrivateKey);

				// already deployed
				lToken = LToken(0xa7e562479745134dD9AAd79503Eb22bfde5d65F3);
				registryImpl = Registry(0x60Da471bE5814B152fB4F9fc851277eC0b0224eA);
				registry = Registry(0xCD9a1422cee2967C2496706eDb327Cbb27e5EB63);
				account = Account(payable(0x8d6F60e70c6aB0e6e33Cd4263622dab3Cb63c618));
				beacon = Beacon(0x0d16Eb27D1c973fEB2eC22e48D6a3d52C81Da2ee);
				accountManagerImpl = AccountManager(0x2B0b245BD59d52fFA25ba1F80F89F06Fd321C649);
				accountManager = AccountManager(0x6867fc993c257e1242DD5a8DE0194aA57157b03B);
				riskEngine = RiskEngine(0x798Cd87Cb93a3a43a609f440632E7f5E93959625);
				accountFactory = AccountFactory(0x23964FD3F5CE7B80cbC8e0Cd0a73F6fcd32C17Ea);
				rateModel = LinearRateModel(0x433119d09Ca386Dedf8511296928ff3dF8329c67);
				rateModelStable = LinearRateModel(0x62e23371cDbB81f3F2e472007732AfA022de790F);
				controller = ControllerFacade(0x80780c586aCeE4A2FfAEB580A24Db6bbdf0aAcba);
				aaveEthController = AaveEthController(0x4C00dbE2a9Bd26EA649bb8F76713A528767a98f4);
				aaveController = AaveV3Controller(0xec09eAaE94d3F88E0b676a1849EB7f999Fc7347D);
				uniSwapController = UniV3Controller(0x2fF7159aD8b7D5f53bCCD4b46712c0fA6Bb6ad70);
				wethController = WETHController(0x8409B34E4226517Af6ca293B022f12ecdb7528d1);
				curveStableSwapController = StableSwap2PoolController(0xB6AE575f5eAC5f6fc0e0e46a4C8825a4d3717126);


        // // Deploy protocol
        // deployRegistry();
        // deployAccount();
        // deployBeacon();
        // deployAccountManager();
        // deployRiskEngine();
        // deployAccountFactory();
        // deployRateModel();
        // enableCollateral();
        // printProtocol();

        // // Deploy Controllers
        // deployControllerFacade();
        deployControllers();
        printControllers();

        // Deploy Oracles
        deployOracleFacade();
        deployOracles();
        printOracles();

        initDependencies();

        // Deploy LTokens
				// deployLTokenImpl();
        deployLEther();
        deployLWBTC();
        deployLUSDT();
				deployLUSDC();
        printLTokens();

        vm.stopBroadcast();
    }

    function deployRegistry() internal {
        registryImpl = new Registry();
        registry = Registry(address(new Proxy(address(registryImpl))));
        registry.init();
    }

    function deployAccount() internal {
        account = new Account();
        registry.setAddress("ACCOUNT", address(account));
    }

    function deployBeacon() internal {
        beacon = new Beacon(address(account));
        registry.setAddress("ACCOUNT_BEACON", address(beacon));
    }

    function deployAccountManager() internal {
        accountManagerImpl = new AccountManager();
        accountManager = AccountManager(payable(address(new Proxy(address(accountManagerImpl)))));
        registry.setAddress("ACCOUNT_MANAGER", address(accountManager));
        accountManager.init(registry);
    }

    function deployRiskEngine() internal {
				riskEngine = new RiskEngine(registry);
        registry.setAddress("RISK_ENGINE", address(riskEngine));
    }

    function deployAccountFactory() internal {
        accountFactory = new AccountFactory(address(beacon));
        registry.setAddress("ACCOUNT_FACTORY", address(accountFactory));
    }

    function deployRateModel() internal {
        rateModel = new LinearRateModel(0, 40000000000000000, 1100000000000000000, 8e17, 2e17, 31556952 * 1e18); // for eth/wbtc
        registry.setAddress("RATE_MODEL", address(rateModel));
				rateModelStable = new LinearRateModel(0, 80000000000000000, 750000000000000000, 9e17, 1e17, 31556952 * 1e18); // for usdt/usdc
        registry.setAddress("RATE_MODEL_STABLE", address(rateModelStable));
    }

    function deployOracleFacade() internal {
        oracle = new OracleFacade();
        registry.setAddress("ORACLE", address(oracle));
    }

    function deployControllerFacade() internal {
        controller = new ControllerFacade();
        registry.setAddress("CONTROLLER", address(controller));
    }

    function initDependencies() internal {
        accountManager.initDep();
        riskEngine.initDep();
    }

		function deployLTokenImpl() internal {
				lToken = new LToken();
		}

    function deployLEther() internal {
        lEthImpl = new LEther();
        lEth = LEther(payable(address(new Proxy(address(lEthImpl)))));
        lEth.init(ERC20(WETH9), "LEther", "LETH", registry, 1e17, TREASURY, 1e12, 1e18);
        registry.setLToken(WETH9, address(lEth));
        lEth.initDep("RATE_MODEL");
    }

    function deployLWBTC() internal {
        LWBTC = LToken(address(new Proxy(address(lToken))));
        LWBTC.init(ERC20(WBTC), "LWrapped Bitcoin", "LWBTC", registry, 1e17, TREASURY, 100, 1000000); // max supply : 0.01 btc
        registry.setLToken(WBTC, address(LWBTC));
        LWBTC.initDep("RATE_MODEL");
    }

    function deployLUSDT() internal {
        LUSDT = LToken(address(new Proxy(address(lToken))));
        LUSDT.init(ERC20(USDT), "LTether USD", "LUSDT", registry, 1e17, TREASURY, 0, 1000 * 1e6);
        registry.setLToken(USDT, address(LUSDT));
        LUSDT.initDep("RATE_MODEL_STABLE");
    }

		function deployLUSDC() internal {
        LUSDC = LToken(address(new Proxy(address(lToken))));
        LUSDC.init(ERC20(USDC), "LUSDC", "LUSDC", registry, 1e17, TREASURY, 0, 1000 * 1e6);
        registry.setLToken(USDC, address(LUSDC));
        LUSDC.initDep("RATE_MODEL_STABLE");
    }

    function deployWETHOracle() internal {
        wethOracle = new WETHOracle();
        oracle.setOracle(address(0), IOracle(wethOracle));
        oracle.setOracle(WETH9, IOracle(wethOracle));
    }

    function deployChainlinkOracle() internal {
        chainlinkOracle = new ArbiChainlinkOracle(
            AggregatorV3Interface(ETHUSD), AggregatorV3Interface(SEQUENCER)
        );
        configureChainLinkOracle(WBTC, WBTCUSD);
        configureChainLinkOracle(USDC, USDCUSD);
        configureChainLinkOracle(USDT, USDTUSD);
        oracle.setOracle(WBTC, chainlinkOracle);
        oracle.setOracle(USDT, chainlinkOracle);
        oracle.setOracle(USDC, chainlinkOracle);
    }

    function configureChainLinkOracle(address token, address feed) internal {
        chainlinkOracle.setFeed(token, AggregatorV3Interface(feed), 3600);
        oracle.setOracle(token, chainlinkOracle);
    }

    function enableCollateral() internal {
        accountManager.toggleCollateralStatus(WETH9);
        accountManager.toggleCollateralStatus(DAI);
        accountManager.toggleCollateralStatus(USDC);
        accountManager.toggleCollateralStatus(USDT);
        accountManager.toggleCollateralStatus(WBTC);
    }

    function deployControllers() internal {
        // // aave
        // aaveEthController = new AaveEthController(aWETH);
        // aaveController = new AaveV3Controller();
        // controller.updateController(AAVE_POOL, aaveController);
        // controller.updateController(WETH_GATEWAY, aaveEthController);
        // controller.toggleTokenAllowance(aWETH);
        // controller.toggleTokenAllowance(aWBTC);
        // controller.toggleTokenAllowance(aDAI);

        // // uniswap
        // uniSwapController = new UniV3Controller(controller);
        // controller.updateController(ROUTER, uniSwapController);
        // controller.toggleTokenAllowance(WETH9);
        // controller.toggleTokenAllowance(WBTC);
        // controller.toggleTokenAllowance(DAI);

        // // WETH
        // wethController = new WETHController(WETH9);
        // controller.updateController(WETH9, wethController);

        // // curve
        // curveStableSwapController = new StableSwap2PoolController();
        // controller.updateController(TWOPOOL, curveStableSwapController);
        curveTriCryptoController = new CurveCryptoSwapController();
        controller.updateController(TRIPOOL, curveTriCryptoController);
    }

    function deployOracles() internal {
        deployWETHOracle();
        deployChainlinkOracle();

        // Aave
        aTokenOracle = new ATokenOracle(oracle);
        oracle.setOracle(aWETH, aTokenOracle);
        oracle.setOracle(aDAI, aTokenOracle);
        oracle.setOracle(aWBTC, aTokenOracle);

        curveTriCryptoOracle = new CurveTriCryptoOracle(ICurveTriCryptoOracle(TRICRYPTOPRICE), ICurvePool(TRIPOOL));
        oracle.setOracle(TRICRYPTO, curveTriCryptoOracle);

        stable2crvOracle = new Stable2CurveOracle(oracle);
        oracle.setOracle(TWOPOOL, stable2crvOracle);
    }

    function printProtocol() internal view {
        console.log("Registry Impl", address(registryImpl));
        console.log("Registry", address(registry));
        console.log("Account", address(account));
        console.log("Account Manager Impl", address(accountManagerImpl));
        console.log("Account Manager", address(accountManager));
        console.log("Risk Engine", address(riskEngine));
        console.log("Beacon", address(beacon));
        console.log("Account Factory", address(accountFactory));
        console.log("Rate Model", address(rateModel));
    }

    function printOracles() internal view {
        console.log("Oracle Facade", address(oracle));
        console.log("WETH Oracle", address(wethOracle));
        console.log("ChainlinkOracle", address(chainlinkOracle));
        console.log("AToken Oracle", address(aTokenOracle));
        console.log("stable2crvOracle", address(stable2crvOracle));
    }

    function printLTokens() internal view {
        console.log("LEther Impl", address(lEthImpl));
        console.log("LEther", address(lEth));
        console.log("LToken", address(lToken));
        console.log("LWBTC", address(LWBTC));
				console.log("LUSDC", address(LUSDC));
				console.log("LUSDT", address(LUSDT));
    }

    function printControllers() internal view {
        console.log("Controller Facade", address(controller));
        console.log("Uniswap Controller", address(uniSwapController));
        console.log("Aave Controller", address(aaveController));
        console.log("Aave Eth Controller", address(aaveEthController));
        console.log("WETH Controller", address(wethController));
        console.log("Curve Stable Swap Controller", address(curveStableSwapController));
        console.log("Curve Crypto Swap Controller", address(curveTriCryptoController));
    }
}
