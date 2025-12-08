// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IBasePay {
    function initiatePayment(
        address recipient,
        uint256 amount,
        address token,
        bytes calldata metadata
    )
        external
        returns (bytes32 paymentId);

    function getPaymentStatus(bytes32 paymentId) external view returns (uint8 status);
}
