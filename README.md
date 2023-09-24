# RealTime-Project4: 
The fola of this project is to build a Simple Calculator using PIC assembly and 16F877A PICMicro.
The calculator operates on integer numbers up to 65535 a push button (P), and a 16x2 LCD.

## Specifications:
Upon startup, it displays "Enter Operation" on the first line.
The user incrementally inputs the first number's digits, from ten thousandths to units, using the push button.
After inputting the first number, the user selects a mathematical operation (+, /, %) by clicking the push button.
Then, the user inputs the second number in the same incremental manner.
The calculator performs the selected operation and displays the result after "=" on the second line.
After a brief pause, it asks if the user wants to keep the numbers or start over.
A single click means "Yes," allowing the user to change the operation or recalculate.
A double-click means "No," returning to the initial state for new calculations.
The process repeats, enabling the user to perform multiple calculations and switch operations as needed.

## Approach:
Since the registers in the controllers were only 8 bits and we needed 16 bits to represent the max number.
It was decided to use a register for each individual digit while taking into account not exceeding 9 or going below zero. 
