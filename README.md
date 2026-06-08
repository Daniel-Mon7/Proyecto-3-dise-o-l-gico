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

## 2. Arquitectura de Subsistemas (Diagrama de Bloques General)

A continuación se presenta el diagrama de bloques que detalla la interconexión estructural y el flujo de buses entre los diferentes componentes del sistema.

```mermaid
graph TD
    %% Entradas Físicas
    INPUT_KEY["key_in [3:0]"]
    INPUT_VAL["valid"]
    
    %% Módulo Superior (div_top)
    subgraph div_top [Módulo Jerárquico: div_top]
        u_input_div["input_div (Captura y Registro)"]
        u_divisor["divisor (FSMD Shift-and-Subtract)"]
        u_selector_div["selector_div (Mux de Vistas)"]
        
        %% Interconexiones internas
        u_input_div --> |"dividendo [5:0]<br>divisor [3:0]<br>start_calc"| u_divisor
        u_input_div --> |"num_registro [15:0]"| u_selector_div
        u_divisor   --> |"cociente [5:0]<br>residuo [3:0]<br>done"| u_selector_div
    end
    
    %% Flujo de Entradas al Sistema
    INPUT_KEY --> u_input_div
    INPUT_VAL --> u_input_div
    INPUT_VAL --> u_selector_div
    
    %% Salida Final
    u_selector_div --> OUTPUT_NUM["num_out [15:0]"] 
