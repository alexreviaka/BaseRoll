// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Script.sol";
import "../contracts/BaseRollV2.sol";
import "../contracts/BaseRollV1.sol";

interface IProxy {
    function upgradeToAndCall(address newImplementation, bytes memory data) external;
}

contract UpgradeBaseRollV2 is Script {
    function run() external returns (address newImplementation) {
        address proxyAddress = vm.envAddress("PROXY_ADDRESS");
        address admin = vm.envAddress("ADMIN_ADDRESS");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        newImplementation = address(new BaseRollV2());

        bytes memory upgradeCall = abi.encodeWithSignature("upgradeToAndCall(address,bytes)", newImplementation, "");

        (bool success,) = proxyAddress.call(upgradeCall);
        require(success, "Upgrade failed");

        vm.stopBroadcast();

        _logUpgrade(proxyAddress, newImplementation);

        return newImplementation;
    }

    function _logUpgrade(address proxy, address newImplementation) internal view {
        console.log("BaseRoll V2 Upgrade");
        console.log("===================");
        console.log("Network:", block.chainid);
        console.log("Proxy:", proxy);
        console.log("New Implementation:", newImplementation);
        console.log("Upgrader:", msg.sender);
    }
}
