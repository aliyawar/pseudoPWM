# Generate pseudo PWM output on a non-PWM pin

This code is written for the ATMega32u4, but it can be easily ported to other microcontrollers. The ability to generate PWM output on non-PWM pins can come in handy, specially if you are working with devices where outputs are already hardwired to the microcontroller leaving you with limited freedom to pick pins. In my case, the hardwre is the [Pololu Balboa](https://www.pololu.com/product/3575) robot. In order to use it in Assembly with the [Pololu IR reflectance array](https://www.pololu.com/docs/0J13), I needed to ping a non-PWM pin. 

This code uses Timer/Counter 0 in Fast PWM mode with the `OCR0B` match and `TCNT0` overflow interrupts enabled. When the `OCR0B` interrupt is called, the output on pin D6 (a non PWM pin), goes LOW. When the counter overflows, the output on D6 goes HIGH. By changing the value of the `OCR0B` match, the duty cycle of the output can be changed. The error in the output timing depends on the length of your interrupt service routines. For low timing errors, you can remove saving/restoring the `SREG`, taking care that the commands inside the ISRs do not affect the `SREG`. The frequency of the output wave can be changed by changing clock prescalars for the Timer/Counter using `CS02:0` bits in the `TCCR0B` register.

```mermaid
flowchart LR

timer[TCNT0 \n\n frequency: TCCR0B, CS0 bits \n duty cycle: OCR0B] -->|OCR0B match interrupt| pinlow(ISR: pin D6 LOW)
timer -->|TCNT0 overflow interrupt| pinhigh(ISR: pin D6 HIGH)

```

The following screenshots show the output waveforms at different frequencies and duty cycles. Y axis scale is 2V/div.


## 50% duty ratio, ~ 7.8 kHz
<p align="center">
<img src="/plots/50fast.png" width="600" />
</p>

## 6% duty ratio, ~ 7.8 kHz
<p align="center">
<img src="/plots/6fast.png" width="600" />
</p>

## 6% duty ratio, ~ 61 Hz
<p align="center">
<img src="/plots/6slow.png" width="600" />
</p>

## 50% duty ratio, ~ 61 Hz
<p align="center">
<img src="/plots/50slow.png" width="600" />
</p>

**Acknowledgement**: I learned the basics of microcontroller programming in assembly as a Teaching Assistant for Yale's Mechatronics Course ([MENG 390](https://courses.yale.edu/?details&srcdb=202101&crn=23090)). This code is based on code skeletons originally developed by the course instructor.
