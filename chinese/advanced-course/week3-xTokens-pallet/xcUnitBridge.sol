// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.0;
import "./xtokens.sol";
import "./ERC20.sol";

contract xcUnitBridge {

    Xtokens public xTokens;
    IERC20 public xcUnit;
    address public constant xtokensPrecompileAddress = 0x0000000000000000000000000000000000000804;
    address public constant xcUnitERC20Address = 0xFfFFfFff1FcaCBd218EDc0EbA20Fc2308C778080;

    constructor() {
        // Initializes the xTokens precompile
        xTokens = Xtokens(xtokensPrecompileAddress);
        xcUnit = IERC20(xcUnitERC20Address);
    }

    function send_tokens(Xtokens.Multilocation memory destination, uint256 amount) external {
        //The user needs to approve the appropriate allowance separately
        xcUnit.transferFrom(msg.sender, address(this), amount);
        xTokens.transfer(xcUnitERC20Address, amount, destination, 4000000000);
    }
    
}
