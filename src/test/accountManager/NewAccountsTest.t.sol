// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {Proxy} from "../../proxy/Proxy.sol";
import {Account} from "../../core/Account.sol";
import {AccountChange} from "../../core/AccountChange.sol";
import {AccountManager} from "../../core/AccountManager.sol";
import {Beacon} from "../../proxy/Beacon.sol";
import {Registry} from "../../core/Registry.sol";
import {ISwapRouterV3} from "controller/uniswap/ISwapRouterV3.sol";

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

    Proxy accountManagerProxy =
        Proxy(payable(0x62c5AA8277E49B3EAd43dC67453ec91DC6826403));
    AccountManager accountManager =
        AccountManager(payable(0x62c5AA8277E49B3EAd43dC67453ec91DC6826403));
    Registry registry = Registry(0x17B07cfBAB33C0024040e7C299f8048F4a49679B);
		Beacon beacon = Beacon(0xB7ba3321FC5ACd14395eB2F00f6c4e2E6c122EEe);

    AccountManager newAccountManager;

    address user = 0x884ba7391637BfCE1D0B8C3aF6723477f6541e0e;
    address account = 0x355eA7352DD7502f6B72b217DFEA526DAC0b0F3a;

    function setUp() public {
        newAccountManager = new AccountManager();
        startHoax(0x92f473Ef0Cd07080824F5e6B0859ac49b3AEb215);
        accountManagerProxy.changeImplementation(address(newAccountManager));
        accountManager.setAssetCap(5);
				
				uint i;
				while (true)
					try registry.lTokens(i++) returns (address lTok) {
						LToken(lTok).togglePause();
					} catch {
						break;
					}
    }

    function testDepositOneAsset() public {
        changePrank(user);
        deal(address(WETH), user, 2e18, true);
        WETH.approve(address(accountManager), 2e18);
        accountManager.deposit(account, address(WETH), 1e18);
    }

    function testDepositTwoAssets() public {
        testDepositOneAsset();
        deal(address(USDC), user, 2e10, true);
        USDC.approve(address(accountManager), 2e10);
        accountManager.deposit(account, address(USDC), 1e10);
    }

    function testDepositThreeAssets() public {
        testDepositOneAsset();
        testDepositTwoAssets();
        deal(address(USDT), user, 2e10, true);
        USDT.approve(address(accountManager), 2e10);
        accountManager.deposit(account, address(USDT), 1e10);
    }

    function testBorrowOneAsset() public {
        testDepositOneAsset();
        accountManager.borrow(account, address(WETH), 1e18);
        accountManager.borrow(account, address(WETH), 1e18);
    }

    function testBorrowTwoAssets() public {
        testBorrowOneAsset();
        accountManager.borrow(account, address(USDC), 1e6);
    }

    function testBorrowThreeAssets() public {
        testBorrowTwoAssets();
        accountManager.borrow(account, address(USDT), 1e6);
    }

		// worse for smol arrays so meh
		function testRepayNewAccount() public {
				AccountChange accountImpl = new AccountChange();
				beacon.upgradeTo(address(accountImpl));

				uint gas = gasleft();
				testDepositThreeAssets();
				accountManager.borrow(account, address(WETH), 1e18);
				accountManager.borrow(account, address(USDC), 1e6);
				accountManager.borrow(account, address(USDT), 1e6);
				accountManager.repay(account, address(WETH), type(uint256).max);
				accountManager.repay(account, address(USDC), type(uint256).max);
				accountManager.repay(account, address(USDT), type(uint256).max);
				console.log(gas - gasleft());
		}

		function testRepay() public {
				Account accountImpl = new Account();
				beacon.upgradeTo(address(accountImpl));

				uint gas = gasleft();
				testDepositThreeAssets();
				accountManager.borrow(account, address(WETH), 1e18);
				accountManager.borrow(account, address(USDC), 1e6);
				accountManager.borrow(account, address(USDT), 1e6);
				accountManager.repay(account, address(WETH), type(uint256).max);
				accountManager.repay(account, address(USDC), type(uint256).max);
				accountManager.repay(account, address(USDT), type(uint256).max);
				console.log(gas - gasleft());
		}

}
