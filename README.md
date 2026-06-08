# Informe de Diseño: Sistema de División Entera Secuencial

## Estudiantes:
- Daniel Montero Vargas
- José Guerrero

## Introducción: 
Este proyecto consiste en el diseño e implementación de un sistema digital sincrónico en SystemVerilog para una FPGA Tang Nano 9K. El sistema funciona como una calculadora de división entera secuencial operada mediante un teclado matricial hexadecimal, cuyo procesamiento aritmético se ejecuta de forma iterativa y cuyos resultados intermedios y finales son administrados dinámicamente para ser proyectados en un bloque de displays de 7 segmentos mediante multiplexación temporal.

---
## 1. Abreviaturas
- **FPGA**: Field Programmable Gate Arrays
- **rst**: Reset (Reinicio)
- **clk**: Clock (Reloj)
- **BCD**: Binary-Coded Decimal (Decimal Codificado en Binario)
- **bin**: Binary (Binario Puro)
- **FSM**: Finite State Machine (Máquina de Estados Finitos)
- **FSMD**: Finite State Machine with Datapath (Máquina de Estados con Ruta de Datos)
- **MSB**: Most Significant Bit (Bit Más Significativo)
---
## 1. Descripción General del Funcionamiento del Circuito Completo

El circuito integrado completo funciona como una calculadora de división entera secuencial operada por teclado. La arquitectura está gobernada por el módulo de jerarquía superior (`div_top`), el cual interconecta los bloques de captura, procesamiento aritmético, conversión de formato y multiplexación de visualización.

El flujo de control y datos del circuito sigue el siguiente orden cronológico:
1. **Captura y Composición:** El circuito inicia en un estado de espera. El usuario digita el dividendo mediante el teclado (`key_in`). El sistema detecta los flancos de la señal `valid` para evitar lecturas múltiples y procesa secuencialmente las decenas y unidades. Al presionar la tecla `A`, el dividendo se almacena firmemente de forma interna. Posteriormente, el usuario digita el divisor (limitado por hardware a un máximo de 15 por seguridad) y presiona la tecla `B`.
2. **Cómputo Secuencial:** Al confirmarse el divisor con la tecla `B`, el subsistema de entrada genera un pulso de inicio (`start_calc`). Esto despierta a la unidad aritmética (`divisor`), la cual ejecuta el algoritmo de división por restauraciones sucesivas (*Shift-and-Subtract*) a lo largo de varios ciclos de reloj.
3. **Conversión y Decodificación:** Una vez terminado el cálculo, el divisor activa la señal `done`. El circuito toma inmediatamente el cociente, el residuo y el divisor en binario puro y, mediante bloques lógicos combinacionales, los traduce al formato BCD (separando decenas de unidades).
4. **Navegación de Resultados:** Tras el pulso `done`, la interfaz de pantalla cambia. Deja de mostrar el registro temporal de escritura y bloquea la pantalla en modo "Resultados". A partir de este momento, el usuario puede presionar las teclas de control para inspeccionar los datos finales en los displays: `A` muestra el dividendo, `B` el divisor, `C` el cociente y `D` el residuo.

---

## 3. Diagramas de Bloques del Sistema

A continuación se presentan los diagramas de bloques del sistema modular de división secuencial, divididos en su vista externa (caja negra) y su estructura interna detallada.

### 3.1 Diagrama de Bloques Externo (Entradas y Salidas de `div_top`)
Este diagrama representa la interfaz externa del módulo raíz. Muestra estrictamente los estímulos que recibe el sistema desde el hardware de la FPGA y la salida final que se envía hacia el decodificador físico de los displays.

```mermaid
graph LR
    %% Configuración de Estilos
    classDef hardware fill:#ececff,stroke:#9370db,stroke-width:2px;
    classDef topBlock fill:#ffe4e1,stroke:#cd5c5c,stroke-width:3px,font-weight:bold;

    %% Nodos de Entrada (Externos)
    CLK["clk<br>(Reloj Maestro 27MHz)"]:::hardware
    RST["rst<br>(Reset Asíncrono)"]:::hardware
    KEY["key_in [3:0]<br>(Bus del Teclado)"]:::hardware
    VAL["valid<br>(Strobe de Tecla)"]:::hardware

    %% Nodo Principal
    DIV_TOP["Módulo Raíz:<br>div_top"]:::topBlock

    %% Nodo de Salida (Externo)
    OUT_NUM["num_out [15:0]<br>(Bus de Visualización BCD)"]:::hardware

    %% Conexiones
    CLK --> DIV_TOP
    RST --> DIV_TOP
    KEY --> DIV_TOP
    VAL --> DIV_TOP
    DIV_TOP --> OUT_NUM

### 3.2 Diagrama de Bloques Interno (Arquitectura y Ruteo de Datos)
Este diagrama detalla la organización interna de div_top. Muestra cómo se interconectan los submódulos (input_div, divisor y selector_div), la distribución de los buses de datos y la lógica de conversión combinacional binaria a BCD implementada en el bloque superior.
graph TD
    %% Configuración de Estilos
    classDef external fill:#ececff,stroke:#9370db,stroke-width:2px;
    classDef subModule fill:#fffacd,stroke:#daa520,stroke-width:2px;
    classDef logicBlock fill:#e0ffff,stroke:#20b2aa,stroke-width:2px,stroke-dasharray: 5 5;

    %% Entradas Externas (Fuera del Subgraph)
    EXT_CLK["clk (Reloj)"]:::external
    EXT_RST["rst (Reset)"]:::external
    EXT_KEY["key_in [3:0]"]:::external
    EXT_VAL["valid"]:::external

    %% Caja del Módulo Superior
    subgraph div_top ["Estructura Interna de div_top"]
        %% Submódulos
        U_INPUT["input_div<br>(Captura y Registro)"]:::subModule
        U_DIVISOR["divisor<br>(Procesador Aritmético FSMD)"]:::subModule
        U_SELECTOR["selector_div<br>(Multiplexor de Vistas)"]:::subModule
        
        %% Bloques Lógicos Combinacionales
        LOGIC_BCD["Lógica Combinacional BCD<br>(Conversión en Bloque Superior)"]:::logicBlock

        %% Conexiones Internas
        U_INPUT --> |"dividendo [5:0]<br>divisor [3:0]"| U_DIVISOR
        U_INPUT --> |"start_calc"| U_DIVISOR
        U_INPUT --> |"num_registro [15:0]"| U_SELECTOR
        U_INPUT --> |"decenas [3:0]<br>unidades [3:0]"| U_SELECTOR

        U_DIVISOR --> |"cociente [5:0]<br>residuo [3:0]"| LOGIC_BCD
        U_DIVISOR --> |"done"| U_SELECTOR

        LOGIC_BCD --> |"cociente_bcd [7:0]<br>residuo_bcd [7:0]<br>divisor_bcd [7:0]"| U_SELECTOR
    end

    %% Salida Externa (Fuera del Subgraph)
    EXT_OUT["num_out [15:0]"]:::external

    %% Enrutamiento desde Entradas Externas a Submódulos
    EXT_CLK ----> U_INPUT
    EXT_CLK ----> U_DIVISOR
    EXT_CLK ----> U_SELECTOR
    
    EXT_RST ----> U_INPUT
    EXT_RST ----> U_DIVISOR
    EXT_RST ----> U_SELECTOR

    EXT_KEY --> U_INPUT
    EXT_KEY --> U_SELECTOR
    
    EXT_VAL --> U_INPUT
    EXT_VAL --> U_SELECTOR

    %% Enrutamiento hacia Salida Externa
    U_SELECTOR --> EXT_OUT
