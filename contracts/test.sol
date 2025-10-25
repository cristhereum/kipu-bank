// SPDX-License-Identifier: MIT
pragma solidity > 0.8.7;

/*
 * @title KipuBank
 * @author cristhereum
 * @notice Este contrato es parte del primer proyecto del Ethereum Developer Pack 
 * @custom:security Este es un contrato educativo y no debe ser usado en producción.
*/ 


/*

- Los usuarios pueden depositar tokens nativos (ETH) en una bóveda personal.

funcion externa payable DEPOSIT 

- Los usuarios pueden retirar fondos de su bóveda, pero solo hasta un umbral fijo por transacción, representado por una variable immutable.

funcion externa RETIRAR

if amount > threshold (LIMITE) revert
restarle la suma a currentCap

- El contrato impone un límite global de depósitos (bankCap), definido durante el despliegue.

DEPOSIT tiene que chequear que ( TRANSACCION + currentCap ) sea menor que el bankCap

- Las interacciones internas y externas deben seguir buenas prácticas de seguridad y 
- declaraciones revert con errores personalizados si no se cumplen las condiciones.
- Se deben emitir eventos tanto en depósitos como en retiros exitosos.
- El contrato debe llevar registro del número de depósitos y retiros.
COUNTS
- El contrato debe tener al menos una función external, una private y una view.


*/


contract KipuBank {
    // VARIABLES DE ESTADO. Deben ser siempre lo más restrictivas posibles.

    // @notice Total de depositos del banco.
    uint public totalBanco;
    uint public totalDepositado;
    
    // @notice Balance por usuario
    mapping (address => uint256) public balance;  // en balance se va guardando el saldo de cada usuario

    // @notice Conteo de depósitos y retiros
    uint256 public conteoDeposito;
    uint256 public conteoRetiro;

    // INMUTABLES
    // @notice Límite máximo de retiro por transacción
    uint immutable public umbralRetiros; // Solo se puede setear en el constructor.
    
    // @notice Capacidad máxima total del banco
    uint256 public immutable bankCap;

    // EVENTOS
    // Se deben emitir eventos tanto en depósitos como en retiros exitosos.
    //event paid(address indexed from, uint amount);
    // @notice Se emite cuando hay un depósito exitoso
    event DepositoExitoso(address indexed desde, uint cantidad);
    // @notice Se emite cuando hay un retiro exitoso
    event RetiroExitoso(address indexed desde, uint cantidad);

    // ERRORES CUSTOMIZADOS
    error InvalidValue();
    error RetiroInvalido(bytes motivo);
    error BalanceInsuficiente(bytes motivo);
    error BancoLleno();
    


    // CONSTRUCTOR
    // @param umbralRetiros Máximo que se puede retirar por transacción
    // @param _bankCap Capacidad total de depósitos del banco
    constructor(uint _umbralRetiros, uint _bankCap){
        umbralRetiros = _umbralRetiros;
        bankCap = _bankCap;
        totalBanco = 0; //TODO: Que pasa si no inicializas una variable? Se pone en cero?
    }


    function depositar() external payable {
        if (msg.value + totalBanco > bankCap) revert BancoLleno(); // TODO: esta bien este error personalizado? HACERLO MODIFICADOR!!!
        balance[msg.sender] += msg.value; // LO GUARDO EN EL BALANCE DEL CLIENTE
        totalBanco += msg.value; // LE SUMO AL TOTAL DEL BANCO LO QUE MANDO
        emit DepositoExitoso(msg.sender, msg.value); // Emito el evento
        conteoDeposito++; // HAGO EL CONTADOR
    }

    function retirar (uint cantidad) external {
        // CHEQUEOS
        if (cantidad > umbralRetiros) revert RetiroInvalido("Cantidad mayor al umbral");
        if (cantidad > balance[msg.sender]) revert BalanceInsuficiente("Balance insuficiente"); // No puede sacar más de lo que tiene.
        //EFECTOS
        balance[msg.sender] -= cantidad;
        totalBanco -= cantidad;
        conteoRetiro++;
        // INTERACCIONES
        _transferir(msg.sender, cantidad); //TODO: se pone guion bajo aca?
    }

    function _transferir(address destinatario, uint256 cantidad) private {
        (bool success, ) = destinatario.call{value: cantidad}("");
        require(success, "Fallo la transferencia");
    }

    function getMyBalance() public view returns(uint myBalance) {
        myBalance = balance[msg.sender];

    }

}

