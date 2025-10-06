// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title KipuBank - Bóveda personal con límites de retiro y depósito.
/// @author cristhereum
/// @notice Permite a los usuarios depositar y retirar ETH con límites establecidos.
/// @dev Sigue patrones de seguridad de Solidity como CEI, errores personalizados y más.

contract KipuBank {
    // ======= EVENTS =======
    /// @notice Se emite cuando un usuario deposita ETH
    event Deposited(address indexed user, uint256 amount);

    /// @notice Se emite cuando un usuario retira ETH
    event Withdrawn(address indexed user, uint256 amount);

    // ======= CUSTOM ERRORS =======
    error ExceedsPerTxWithdrawLimit(uint256 requested, uint256 max);
    error InsufficientBalance(uint256 available, uint256 requested);
    error BankCapExceeded(uint256 attempted, uint256 remaining);
    error ZeroDeposit();
    error ZeroWithdraw();
    
    // ======= CONSTANTES & IMMUTABLES =======
    /// @notice Límite máximo de retiro por transacción
    uint256 public immutable withdrawLimit;

    /// @notice Capacidad máxima total del banco
    uint256 public immutable bankCap;

    // ======= VARIABLES DE ESTADO =======
    /// @notice Balance por usuario
    mapping(address => uint256) private balances;

    /// @notice Total acumulado depositado en el banco
    uint256 private totalDeposited;

    /// @notice Conteo de depósitos y retiros
    uint256 public depositCount;
    uint256 public withdrawCount;

    // ======= CONSTRUCTOR =======
    /// @param _withdrawLimit Máximo que se puede retirar por transacción
    /// @param _bankCap Capacidad total de depósitos del banco
    constructor(uint256 _withdrawLimit, uint256 _bankCap) {
        require(_withdrawLimit > 0, "Withdraw limit must be > 0");
        require(_bankCap > 0, "Bank cap must be > 0");
        withdrawLimit = _withdrawLimit;
        bankCap = _bankCap;
    }

    // ======= MODIFICADORES =======
    /// @notice Verifica que el depósito no exceda el cap del banco
    modifier withinCap(uint256 amount) {
        if (totalDeposited + amount > bankCap) {
            revert BankCapExceeded(amount, bankCap - totalDeposited);
        }
        _;
    }

    // ======= FUNCIONES =======

    /// @notice Deposita ETH al banco
    /// @dev Sigue el patrón checks-effects-interactions
    /// @custom:error ZeroDeposit, BankCapExceeded
    function deposit() external payable withinCap(msg.value) {
        if (msg.value == 0) {
            revert ZeroDeposit();
        }

        balances[msg.sender] += msg.value;
        totalDeposited += msg.value;
        depositCount++;

        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Retira una cantidad de ETH de la bóveda del usuario
    /// @param amount Cantidad a retirar
    /// @custom:error ExceedsPerTxWithdrawLimit, InsufficientBalance, ZeroWithdraw
    function withdraw(uint256 amount) external {
        if (amount == 0) {
            revert ZeroWithdraw();
        }

        if (amount > withdrawLimit) {
            revert ExceedsPerTxWithdrawLimit(amount, withdrawLimit);
        }

        uint256 userBalance = balances[msg.sender];

        if (amount > userBalance) {
            revert InsufficientBalance(userBalance, amount);
        }

        // Checks-Effects-Interactions
        balances[msg.sender] -= amount;
        totalDeposited -= amount;
        withdrawCount++;

        _safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    /// @notice Consulta el balance actual del usuario
    /// @return balance ETH disponible del usuario
    function getMyBalance() external view returns (uint256 balance) {
        return balances[msg.sender];
    }

    /// @notice Función privada para transferencias seguras
    /// @dev Usa call para manejar reentradas/control de gas
    /// @param to Destinatario
    /// @param amount Monto en wei
    function _safeTransfer(address to, uint256 amount) private {
        (bool success, ) = to.call{value: amount}("");
        require(success, "Transfer failed");
    }
}
