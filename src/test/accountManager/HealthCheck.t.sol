// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {Proxy} from "../../proxy/Proxy.sol";
import {AccountManager} from "../../core/AccountManager.sol";
import {Registry} from "../../core/Registry.sol";
import {ISwapRouterV3} from "controller/uniswap/ISwapRouterV3.sol";
import {RiskEngine} from "../../core/RiskEngine.sol";

import {LToken} from "../../tokens/LToken.sol";
import {console} from "forge-std/console.sol";

interface ITokenList {
    function lTokens(uint index) external view returns (address);
    function lTokens() external view returns (uint);
}

contract CapAssetsArbiIntegrationTest is Test {
    address uniV3Router = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;

    IERC20 WETH = IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
    IERC20 USDC = IERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8);
    IERC20 USDT = IERC20(0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9);
    IERC20 WBTC = IERC20(0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f);
    IERC20 WSTETH = IERC20(0x5979D7b546E38E414F7E9822514be443A4800529);
    IERC20 DAI = IERC20(0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1);
		IERC20 FRAX = IERC20(0x17FC002b466eEc40DaE837Fc4bE5c67993ddBd6F);

    Proxy accountManagerProxy =
        Proxy(payable(0x62c5AA8277E49B3EAd43dC67453ec91DC6826403));
    AccountManager accountManager =
        AccountManager(payable(0x62c5AA8277E49B3EAd43dC67453ec91DC6826403));
    Registry registry = Registry(0x17B07cfBAB33C0024040e7C299f8048F4a49679B);

		RiskEngine riskEngine = RiskEngine(0x622eaDa71B78300d0E6cAb66BE78690a6d041fB3);

    AccountManager newAccountManager;

    address user = 0x884ba7391637BfCE1D0B8C3aF6723477f6541e0e;
    address account = 0x355eA7352DD7502f6B72b217DFEA526DAC0b0F3a;

    function setUp() public {
        // startHoax(0x92f473Ef0Cd07080824F5e6B0859ac49b3AEb215);
				
				// uint i;
				// while (true)
				// 	try registry.lTokens(i++) returns (address lTok) {
				// 		LToken(lTok).togglePause();
				// 	} catch {
				// 		break;
				// 	}
    }

    // function testAccountHealth() public {
    //     console.log(riskEngine.isAccountHealthy(0x7bf10664FB1079D665F83A8c9151b661F11c56d1));
    // }

		function testLiquidation() public {
        console.log(riskEngine.isAccountHealthy(0x7bf10664FB1079D665F83A8c9151b661F11c56d1));

				vm.startPrank(0x6E82554d7C496baCcc8d0bCB104A50B772d22a1F);

				deal(address(WETH), 0x6E82554d7C496baCcc8d0bCB104A50B772d22a1F, 10e18, true);
				deal(address(USDC), 0x6E82554d7C496baCcc8d0bCB104A50B772d22a1F, 100000e8, true);
				deal(address(USDT), 0x6E82554d7C496baCcc8d0bCB104A50B772d22a1F, 100000e8, true);
				deal(address(FRAX), 0x6E82554d7C496baCcc8d0bCB104A50B772d22a1F, 10e18, true);


				console.log("WETH BALANCE: ", WETH.balanceOf(0x6E82554d7C496baCcc8d0bCB104A50B772d22a1F));
				console.log("USDC BALANCE: ", USDC.balanceOf(0x6E82554d7C496baCcc8d0bCB104A50B772d22a1F));
				console.log("USDT BALANCE: ", USDT.balanceOf(0x6E82554d7C496baCcc8d0bCB104A50B772d22a1F));
				console.log("WBTC BALANCE: ", WBTC.balanceOf(0x6E82554d7C496baCcc8d0bCB104A50B772d22a1F));
				console.log("WSTETH BALANCE: ", WSTETH.balanceOf(0x6E82554d7C496baCcc8d0bCB104A50B772d22a1F));
				console.log("DAI BALANCE: ", DAI.balanceOf(0x6E82554d7C496baCcc8d0bCB104A50B772d22a1F));
				// console.log("FRAX BALANCE: ", FRAX.balanceOf(0x6E82554d7C496baCcc8d0bCB104A50B772d22a1F));


				WETH.approve(address(accountManager),type(uint).max);
				USDC.approve(address(accountManager),type(uint).max);
				USDT.approve(address(accountManager),type(uint).max);
				FRAX.approve(address(accountManager),type(uint).max);
				accountManager.liquidate(0x4b3bf8160F5Cb1a18792822707431C28Cbf5d90F);

				console.log("WETH BALANCE: ", WETH.balanceOf(0x6E82554d7C496baCcc8d0bCB104A50B772d22a1F));
				console.log("USDC BALANCE: ", USDC.balanceOf(0x6E82554d7C496baCcc8d0bCB104A50B772d22a1F));
				console.log("USDT BALANCE: ", USDT.balanceOf(0x6E82554d7C496baCcc8d0bCB104A50B772d22a1F));
				console.log("WBTC BALANCE: ", WBTC.balanceOf(0x6E82554d7C496baCcc8d0bCB104A50B772d22a1F));
				console.log("WSTETH BALANCE: ", WSTETH.balanceOf(0x6E82554d7C496baCcc8d0bCB104A50B772d22a1F));
				console.log("DAI BALANCE: ", DAI.balanceOf(0x6E82554d7C496baCcc8d0bCB104A50B772d22a1F)/10**16);
				// console.log("FRAX BALANCE: ", FRAX.balanceOf(0x6E82554d7C496baCcc8d0bCB104A50B772d22a1F));

				vm.stopPrank();
    }

}
