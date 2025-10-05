// Una descripción de lo que hace el contrato.

// Instrucciones de despliegue.

// Cómo interactuar con el contrato.

# KIPU BANK 

Este contrato forma parte del TP2 del EDP

## Enunciado:

### Objetivos del examen

- Aplicar conceptos básicos de Solidity aprendidos en clase.
- Seguir patrones de seguridad.
- Usar comentarios y una estructura limpia para mejorar la legibilidad y el mantenimiento del contrato.
- Desplegar un contrato inteligente completamente funcional en una testnet.
- Crear un repositorio de GitHub que documente y muestre tu proyecto.

### Descripción y requisitos de la tarea

Tu tarea es recrear el contrato inteligente KipuBank con funcionalidad completa y documentación, según se describe a continuación.

#### Características de KipuBank:

- Los usuarios pueden depositar tokens nativos (ETH) en una bóveda personal.
- Los usuarios pueden retirar fondos de su bóveda, pero solo hasta un umbral fijo por transacción, representado por una variable inmutable.
- El contrato aplica un límite global de depósitos (bankCap), establecido durante el despliegue.
- Las interacciones internas y externas deben seguir buenas prácticas de seguridad y revertir con errores personalizados claros si no se cumplen las condiciones.
- Se deben emitir eventos tanto en depósitos como en retiros exitosos.
- El contrato debe llevar un registro del número de depósitos y retiros.
- El contrato debe tener al menos una función externa, una privada y una de vista (view).

### Prácticas de seguridad a seguir:

- Usar errores personalizados en lugar de require strings.
- Respetar el patrón checks-effects-interactions y las convenciones de nombres.
- Usar modificadores cuando sea apropiado para validar la lógica.
- Manejar transferencias nativas de forma segura.
- Mantener las variables de estado limpias, legibles y bien comentadas.
- Agregar comentarios NatSpec para cada función, error y variable de estado.
- Aplicar convenciones de nombres adecuadas.

