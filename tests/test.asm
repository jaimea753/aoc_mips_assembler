        .data
        @10 10
        @20 -5
        .text
init:   NOP
        add r1, r1, r2
        lw r1, 78(r0)
        sw r1, 0(r10)
        sub r1, r1, r2
        beq r0, r0, 1
        beq r0, r0, -3
        beq r0, r0, init
        beq r0, r0, hola
        jal r0, 5
        jal r0, -1
hOla:   ret r1
adios:  ret r1
        NOP
