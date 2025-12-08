// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../contracts/BaseRollV2.sol";

contract DeployBaseRollV2 is Script {
    function run() external returns (address proxy, address implementation) {
        address deployer = vm.envAddress("DEPLOYER_ADDRESS");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        implementation = address(new BaseRollV2());

        bytes memory initData = abi.encodeCall(BaseRollV2.initialize, (deployer));

        proxy = address(new ERC1967Proxy(implementation, initData));

        vm.stopBroadcast();

        _logDeployment(proxy, implementation);

        return (proxy, implementation);
    }

    function _logDeployment(address proxy, address implementation) internal view {
        console.log("BaseRoll V2 Deployment");
        console.log("=====================");
        console.log("Network:", block.chainid);
        console.log("Proxy:", proxy);
        console.log("Implementation:", implementation);
        console.log("Deployer:", msg.sender);
    }
}
