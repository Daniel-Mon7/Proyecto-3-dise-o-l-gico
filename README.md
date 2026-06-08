# Informe de Diseño: Sistema de División Entera Secuencial

## Estudiantes:
- Daniel Montero Vargas
- José Guerrero

## Introducción
Este proyecto consiste en el diseño e implementación de un sistema digital sincrónico en SystemVerilog para una FPGA Tang Nano 9K. El sistema funciona como una calculadora de división entera secuencial operada mediante un teclado matricial hexadecimal, cuyo procesamiento aritmético se ejecuta de forma iterativa y cuyos resultados intermedios y finales son administrados dinámicamente para ser proyectados en un bloque de displays de 7 segmentos mediante multiplexación temporal.

---

## 1. Abreviaturas
- **FPGA**: Field Programmable Gate Arrays
- **rst**: Reset (Reinicio Asíncrono)
- **clk**: Clock (Reloj de Sistema)
- **BCD**: Binary-Coded Decimal (Decimal Codificado en Binario)
- **HDL**: Hardware Description Language (Lenguaje de Descripción de Hardware)
- **FSMD**: Finite State Machine with Datapath (Máquina de Estados con Ruta de Datos)
- **MSB**: Most Significant Bit (Bit Más Significativo)

---

## 2. Descripción General del Funcionamiento del Circuito Completo

El circuito integrado completo funciona como una calculadora de división entera secuencial operada por teclado. La arquitectura está gobernada por el módulo de jerarquía superior (`div_top`), el cual interconecta los bloques de captura, procesamiento aritmético, conversión de formato y multiplexación de visualización.

El flujo de control y datos del circuito sigue el siguiente orden cronológico:

1. **Captura y Composición:** El circuito inicia en un estado de espera. El usuario digita el dividendo mediante el teclado (`key_in`). El sistema detecta los flancos de la señal `valid` para evitar lecturas múltiples y procesa secuencialmente las decenas y unidades. Al presionar la tecla `A`, el dividendo se almacena firmemente de forma interna. Posteriormente, el usuario digita el divisor (limitado por hardware a un máximo de 15 por seguridad arquitectónica) y presiona la tecla `B`.
2. **Cómputo Secuencial:** Al confirmarse el divisor con la tecla `B`, el subsistema de entrada genera un pulso de inicio (`start_calc`). Esto despierta a la unidad aritmética (`divisor`), la cual ejecuta el algoritmo de división por restauraciones sucesivas (*Shift-and-Subtract*) a lo largo de varios ciclos de reloj.
3. **Conversión y Decodificación:** Una vez terminado el cálculo, el divisor activa la señal `done`. El circuito toma inmediatamente el cociente, el residuo y el divisor en binario puro y, mediante bloques lógicos combinacionales, los traduce al formato BCD (separando decenas de unidades).
4. **Navegación de Resultados:** Tras el pulso `done`, la interfaz de pantalla cambia. Deja de mostrar el registro temporal de escritura y bloquea la pantalla en modo "Resultados". A partir de este momento, el usuario puede presionar las teclas de control para inspeccionar los datos finales en los displays: `A` muestra el dividendo, `B` el divisor, `C` el cociente y `D` el residuo.

---

## 3. Descripciones Técnicas y Código de los Módulos

A continuación se detallan las especificaciones de diseño, funcionamiento de control y el código fuente en SystemVerilog de cada uno de los bloques estructurales que conforman el sistema.

### 3.1 Módulo clk_divider
* **Descripción:** Divisor de frecuencia por conteo binario. Reduce la señal del reloj maestro de la FPGA (27 MHz) para generar una señal de habilitación periódica (`tick`) de baja frecuencia necesaria para la multiplexación temporal de los displays de 7 segmentos sin sobrecargar la conmutación de los transistores.
```systemverilog
module clk_divider (
    input  logic clk,    
    input  logic rst,    
    output logic tick    
);
    logic [13:0] count;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) 
            count <= 14'd0;         
        else     
            count <= count + 1'b1;  
    end

    assign tick = (count == 14'd0);
endmodule
