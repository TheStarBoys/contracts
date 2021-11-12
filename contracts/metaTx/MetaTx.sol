// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";

/**
 * This file copy from openzeppelin, and make some changes.
 */

/**
 * @dev Simple minimal forwarder to be used together with an ERC2771 compatible contract. See {ERC2771Context}.
 */
contract MetaTx is MinimalForwarder {
    constructor() MinimalForwarder() {}
}
