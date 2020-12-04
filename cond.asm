_conditional:                           ; all frm conditionals
                pushfd                  ; can be processed here.
                push    eax
                mov     ax,[esp+4+4+4+4]
                cmp     al,0
                jne     _1_conditional
                push dword [esp+4]
                popfd
                jb      _Y1conditional
                jnc     _N1conditional
_1_conditional:
                cmp     al,1
                jne     _2_conditional
                push dword [esp+4]
                popfd
                jnb     _Y1conditional
                jc      _N1conditional
_2_conditional:
                cmp     al,2
                jne     _3_conditional
                push dword [esp+4]
                popfd
                je      _Y1conditional
                jnz     _N1conditional
_3_conditional:
                cmp     al,3
                jne     _4_conditional
                push dword [esp+4]
                popfd
                jne     _Y1conditional
                jz      _N1conditional
_4_conditional:
                cmp     al,4
                jne     _5_conditional
                push dword [esp+4]
                popfd
                jbe     _Y1conditional
                ja      _N1conditional
_Y1conditional:
                pop     eax
                push dword [esp+4+4] ; segment of caller
                push dword [esp+4+4+4+4+2]
        o32     retf    4+4+4+2+4
_N1conditional:
                pop     eax
                popfd
        o32     retf    2+4

_5_conditional:
                cmp     al,5
                jne     _6_conditional
                push dword [esp+4]

                ja      _Y1conditional
                jnbe    _N1conditional
_6_conditional:
                cmp     al,6
                jne     _7_conditional
                push dword [esp+4]
                popfd
                jg      _Y1conditional
                jle     _N1conditional
_7_conditional:
                cmp     al,7
                jne     _8_conditional
                push dword [esp+4]
                popfd
                jl      _Y1conditional
                jge     _N1conditional
_8_conditional:
                cmp     al,8
                jne     _9_conditional
                push dword [esp+4]
                popfd
                jnl     _Y1conditional
                jnge    _N1conditional
_9_conditional:
                cmp     al,9
                jne     _10conditional
                push dword [esp+4]
                popfd
                jng     _Y2conditional
                jnle    _N2conditional
_10conditional:
                cmp     al,10
                jne     _11conditional
                push dword [esp+4]
                popfd
                jo      _Y2conditional
                jno     _N2conditional
_11conditional:
                cmp     al,11
                jne     _12conditional
                push dword [esp+4]
                popfd
                jno     _Y2conditional
                jo      _N2conditional
_12conditional:
                cmp     al,12
                jne     _13conditional
                push dword [esp+4]
                popfd
                js      _Y2conditional
                jns     _N2conditional
_13conditional:
                cmp     al,13
                jne     _14conditional
                push dword [esp+4]
                popfd
                jns     _Y2conditional
                js      _N2conditional
_14conditional:
                cmp     al,14
                jne     _15conditional
                push dword [esp+4]
                popfd
                jcxz    _Y2conditional
                jmp     _N2conditional
_15conditional:
                cmp     al,15
                jne     _16conditional
                push dword [esp+4]
                popfd
                jecxz   _Y2conditional
                jmp     _N2conditional
_Y2conditional:
                pop     eax
                push dword [esp+4+4] ; segment of caller
                push dword [esp+4+4+4+4+2]
        o32     retf    4+4+4+2+4
_N2conditional:
                pop     eax
                popfd
        o32     retf    2+4

_16conditional:
                cmp     al,16
                jne     _16conditional
                push dword [esp+4]
                popfd
                jp      _Y2conditional
                jpo     _N2conditional
_17conditional:
                cmp     al,17
                jne     _E_conditional
                push dword [esp+4]
                popfd
                jnp     _Y2conditional
                jpe     _N2conditional
_E_conditional:
                pop     eax
                popfd
        o32     retf    6

_int_:
_int_num0	equ	springboard_init
_int_num1	equ	_int_num-_int_num0+0xc000
                sti
                push word [esp+4+4]     ; cs:eip
                mov byte [esp+1],0x90
;		sub	esp,2
;		push	ax
;		mov	ax,[esp+2+4+4]
;		mov	ah,0x90
;		mov	[esp+2],ax
;		pop	ax
                pop word [dword cs:_int_num1]
                db      0xcd
_int_num	dw      0x9090
                cli
        o32     retf    2

_div_:
		sti
		div dword [esp+4+4]	; skip cs:eip
		cli
	o32	retf	4

; -------------------------------------------------------------------------
