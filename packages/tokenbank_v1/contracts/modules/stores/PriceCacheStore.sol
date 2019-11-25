/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
pragma solidity ^0.5.11;

import "../../lib/MathUint.sol";

import "../../iface/PriceOracle.sol";

import "../../base/DataStore.sol";


/// @title PriceCacheStore
contract PriceCacheStore is DataStore, PriceOracle
{
    using MathUint for uint;
    uint expiry;

    event PriceCached (
        address indexed token,
        uint            amount,
        uint            value,
        uint            timestamp
    );

    struct TokenPrice
    {
        uint amount;
        uint value;
        uint timestmap;
    }

    mapping (address => TokenPrice) prices;

    constructor(uint _expiry)
        public
        DataStore()
    {
        expiry = _expiry;
    }

    function getValue(address token, uint amount)
        public
        view
        returns (uint)
    {
        TokenPrice storage tp = prices[token];
        if (tp.timestmap > 0 && now < tp.timestmap + expiry) {
            return tp.value.mul(amount) / tp.amount;
        } else {
            return 0;
        }
    }

    function cachePrice(address token, uint amount, uint value)
        external
    {
        prices[token].amount = amount;
        prices[token].value = value;
        prices[token].timestmap = now;
        emit PriceCached(token, amount, value, now);
    }
}