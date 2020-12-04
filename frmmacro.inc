;
csb		equ	0xc003
isb		equ	0xc006
dsb		equ	0xc009
;csb		equ	0xc00e
        %macro          j_b 1
                push dword %1
                push word 0
        a32     call dword 0x0:csb
        %endmacro
        %macro          j_nae 1
                push dword %1
                push word 0
        a32     call dword 0x0:csb
        %endmacro
        %macro          j_c 1
                push dword %1
                push word 0
        a32     call dword 0x0:csb
        %endmacro
;
        %macro          j_nb 1
                push dword %1
                push word 1
        a32     call dword 0x0:csb
        %endmacro
        %macro          j_ae 1
                push dword %1
                push word 1
        a32     call dword 0x0:csb
        %endmacro
        %macro          j_nc 1
                push dword %1
                push word 1
        a32     call dword 0x0:csb
        %endmacro
;
        %macro          j_e 1
                push dword %1
                push word 2
        a32     call dword 0x0:csb
        %endmacro
        %macro          j_z 1
                push dword %1
                push word 2
        a32     call dword 0x0:csb
        %endmacro
;
        %macro          j_ne 1
                push dword %1
                push word 3
        a32     call dword 0x0:csb
        %endmacro
        %macro          j_nz 1
                push dword %1
                push word 3
        a32     call dword 0x0:csb
        %endmacro
;
        %macro          j_be 1
                push dword %1
                push word 4
        a32     call dword 0x0:csb
        %endmacro
        %macro          j_na 1
                push dword %1
                push word 4
        a32     call dword 0x0:csb
        %endmacro
;
        %macro          j_a 1
                push dword %1
                push word 5
        a32     call dword 0x0:csb
        %endmacro
        %macro          j_nbe 1
                push dword %1
                push word 5
        a32     call dword 0x0:csb
        %endmacro
;
        %macro          j_g 1
                push dword %1
                push word 6
        a32     call dword 0x0:csb
        %endmacro
        %macro          j_nle 1
                push dword %1
                push word 6
        a32     call dword 0x0:csb
        %endmacro
;
        %macro          j_l 1
                push dword %1
                push word 7
        a32     call dword 0x0:csb
        %endmacro
        %macro          j_nge 1
                push dword %1
                push word 7
        a32     call dword 0x0:csb
        %endmacro
;
        %macro          j_ge 1
                push dword %1
                push word 8
        a32     call dword 0x0:csb
        %endmacro
        %macro          j_nl 1
                push dword %1
                push word 8
        a32     call dword 0x0:csb
        %endmacro
;
        %macro          j_le 1
                push dword %1
                push word 9
        a32     call dword 0x0:csb
        %endmacro
        %macro          j_ng 1
                push dword %1
                push word 9
        a32     call dword 0x0:csb
        %endmacro
;
        %macro          j_o 1
                push dword %1
                push word 10
        a32     call dword 0x0:csb
        %endmacro
        %macro          j_no 1
                push dword %1
                push word 11
        a32     call dword 0x0:csb
        %endmacro
;
        %macro          j_s 1
                push dword %1
                push word 12
        a32     call dword 0x0:csb
        %endmacro
        %macro          j_ns 1
                push dword %1
                push word 13
        a32     call dword 0x0:csb
        %endmacro
;
        %macro          j_cxz 1
                push dword %1
                push word 14
        a32     call dword 0x0:csb
        %endmacro
;
        %macro          j_ecxz 1
                push dword %1
                push word 15
        a32     call dword 0x0:csb
        %endmacro
;
        %macro          j_p 1
                push dword %1
                push word 16
        a32     call dword 0x0:csb
        %endmacro
        %macro          j_pe 1
                push dword %1
                push word 17
        a32     call dword 0x0:csb
        %endmacro
;
        %macro          j_po 1
                push dword %1
                push word 18
        a32     call dword 0x0:csb
        %endmacro
        %macro          j_np 1
                push dword %1
                push word 19
        a32     call dword 0x0:csb
        %endmacro
;
        %macro          int_ 1
                push word %1
        a32     call dword 0x0:isb
        %endmacro
;
	%macro		div_ 1
		push dword %1
	a32	call dword 0x0:dsb
	%endmacro
