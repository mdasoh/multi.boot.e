
	align		8

header:		dd	0xE85250D6	; multiboot2 kernel-header
		dd	0
		dd	header_fini-header
		dd	0x100000000-0xE85250D6-(header_fini-header)
tag1:		dw	1,0		; info request
		dd	0xc
		dd	4
		dd	0		; align 8
tagn:		dw	0,0		; closing tag
		dd	8
header_fini:

gdt:		dd	0,0
                dw      0xffff,0x0000,0x9a00,0x008f ; code
                dw      0xffff,0x0000,0x9200,0x008f ; data
gdt_fini:
gdtr:		dw	gdt_fini-gdt
		dd	gdt
idtr:		dw	0x3ff
		dd	0

	section		.text
	bits		32
	global		_start
_start:
		call	_init		; 0x104c, 0x10004c
		jmp	_start		; not reached.

	bits		16
springboard_init:
		jmp near springboard	; 0xc000
		jmp near _conditional	; 0xc003 csb conditional springboard
		jmp near _int_		; 0xc006 isb interrupt springboard
		jmp near _div_		; 0xc009
		jmp near stack_ck
		;jmp near anywhere...	; 0xc00c, etc.

%include		"cond.asm"	; springboard code for macros
					; keep below 0:0xffff

stack_ck:				; a32 call dword 0:0xc00c
		push dword 0		; this dword is [esp+4]
		push dword 1		; this dword is [esp].
		push dword 2
		pop dword [esp]
		add	esp,8
	o32	retf

springboard:
		mov	ax,0x0010
		mov	es,ax
		mov	ds,ax
		mov	edi,0xb8000
		mov	ax,0x0730
		mov	[es:edi],ax
		inc	edi
		inc	edi
		mov	edx,cr0
		and	edx,0x7ffffffe
		mov	cr0,edx
		jmp dword 0:0xc000+a1springboard
a_springboard:
a1springboard	equ	a_springboard-springboard_init
	bits		16
		mov	dx,0
		mov	es,dx
		mov	ds,dx
		mov	ss,dx
		mov	esp,0x9ef8
		lidt	[dword idtr]	; idt limit was 0
		sti
b_springboard:				; _main may return here.
b1springboard	equ	b_springboard-springboard_init
		sti			; BIOS interrupts are in place.
		hlt
		push dword 0xc000+b1springboard
		push dword _main
		cli
	o32	ret			; call _main
springboard_fini:

	bits		32
move_springboard:
		mov	esi,springboard_init
		mov	ecx,springboard_fini-springboard_init
		mov	edi,0xc000
	a32	rep	movsb
		ret
_init:
		call	move_springboard
		lgdt	[gdtr]
		call	0x8:0xc000
		jmp	_init		; not reached.
	bits		16
%include		"frmmacro.inc"	; macros for flat-real-mode

pos:            dw      80*2*13,0
byteout:
                push    ebx
                mov     ah,7
                mov     ebx,[dword pos]
                inc word [dword pos]
                inc word [dword pos]
                add     ebx,0xb8000
        a32     mov     [ebx],ax
                pop     ebx
        o32     ret
nybblehexout:
                push    ax
                cmp     al,0xa
                j_b     bcdhexout
                add     al,7
bcdhexout:      add     al,0x30
       a32      call dword byteout
                pop     ax
       o32      ret
bytehexout:
                push    ax
                push    ax
                shr     al,4
       a32      call dword nybblehexout
                pop     ax
                and     al,0x0f
       a32      call dword nybblehexout
                pop     ax
       o32      ret
wordhexout:
                push    ax
                push    ax
                shr     ax,8
       a32      call dword bytehexout
                pop     ax
       a32      call dword bytehexout
                pop     ax
       o32      ret
dwordhexout:
                push    eax
                push    eax
                shr     eax,0x10
        a32     call dword wordhexout
                pop     eax
                and     eax,0x0000ffff
        a32     call dword wordhexout
                pop     eax
        o32     ret
_top_pos:
                mov word [dword pos],0
        o32     ret
_clear:
                push    eax
                push    edi
                push    ecx
                push    es
                mov     ax,0xb800
                mov     es,ax
                cld
                mov     edi,0x000
                mov     eax,0x07200720
                mov     ecx,40*25
	a32	rep     stosd
                pop     es
                pop     ecx
                pop     edi
                pop     eax
        o32     ret
;---------------
term_mb2call:
	o32	ret
command_mb2call:
	o32	ret
bootname_mb2call:
	o32	ret
module_mb2call:
	o32	ret
digits_meminfo_mb2call:
		db	0,0,0,0,0,0,0,0,0,0
		db	0,0,0,0,0,0,0,0,0,0
		db	0,0,0,0,0,0,0,0,0,0
meminfo_mb2call:
		mov	eax,[ebx+esi+8]
		;call dword dwordhexout
		mov	eax,[ebx+esi+0xc]
		mov	[dword memtotal],eax
		add	eax,0x400
		mov	ecx,digits_meminfo_mb2call
loop_meminfo_mb2call:
		xor	edx,edx
		div_	0xa
		mov	[ecx],dl
		inc	ecx
		or	eax,eax
		j_nz	loop_meminfo_mb2call
loop2meminfo_mb2call:
		dec	ecx
		mov	al,[ecx]
		call dword nybblehexout
		cmp	ecx,digits_meminfo_mb2call
		j_ne	loop2meminfo_mb2call
		mov	al,' '
		call dword byteout
		mov	al,'K'
		call dword byteout
		mov	al,'i'
		call dword byteout
		mov	al,'B'
		call dword byteout
	o32	ret
bootdev_mb2call:
	o32	ret
memmap_mb2call:
	o32	ret
fbinfo_mb2call:
	o32	ret
elf32_mb2call:
	o32	ret
apm_mb2call:
	o32	ret
_rdsp_mb2call:
	o32	ret
_ign_mb2call:
	o32	ret

mb2calls	dd	term_mb2call
		dd	command_mb2call
		dd	bootname_mb2call
		dd	module_mb2call
		dd	meminfo_mb2call
		dd	bootdev_mb2call
		dd	memmap_mb2call
		dd	_ign_mb2call
		dd	fbinfo_mb2call
		dd	elf32_mb2call
		dd	apm_mb2call
		dd	_ign_mb2call
		dd	_ign_mb2call
		dd	_ign_mb2call
		dd	_rdsp_mb2call	; acpi rdsp
		dd	_ign_mb2call
		dd	_ign_mb2call
		dd	_ign_mb2call
		dd	_ign_mb2call
		dd	_ign_mb2call
		dd	_ign_mb2call
		dd	_ign_mb2call	; 0x15 or 21
		dd	_ign_mb2call
		dd	_ign_mb2call	; 0x17 or 23
;---------------



__bts:
	lock	bts dword [esp+4],eax
	o32	ret
__btc:					; bit test and clear/reset
	lock	btr dword [esp+4],eax
	o32	ret

_bts:
		push	ebx
		mov	eax,[esp+8+4]
		mov	ebx,[esp+4+4]
	lock	bts dword [ebx],eax
		lahf			; load flags into ah register
		mov	al,ah
		and	eax,1		; isolate carry
		pop	ebx
	o32	ret
_btc:					; bit test and clear/reset
		push	ebx
		mov	eax,[esp+8+4]
		mov	ebx,[esp+4+4]
	lock	btr dword [ebx],eax
		lahf			; load flags into ah register
		mov	al,ah
		and	eax,1		; isolate carry
		pop	ebx
	o32	ret

__inc_bit:
		cmp	cl,7
		j_ne	b_inc_bit
		inc dword [esp+4]
		mov	cl,0
	o32	ret
b__inc_bit:	inc	cl
	o32	ret
__dec_bit:
		cmp	cl,0
		j_ne	b_dec_bit
		dec dword [esp+4]
		mov	cl,7
	o32	ret
b__dec_bit:	dec	cl
	o32	ret

_inc_bit:
		mov	ecx,[esp+8]	; the stack moves in order please! 
		cmp	cl,7		; so push parameters in reverse! F0004
		j_ne	b_inc_bit
		inc dword [esp+4]
		mov	cl,0
		mov	[esp+8],ecx
	o32	ret
b_inc_bit:	inc	cl
		mov	[esp+8],ecx
	o32	ret
_dec_bit:
		mov	ecx,[esp+8]
		cmp	cl,0
		j_ne	b_dec_bit
		dec dword [esp+4]
		mov	cl,7
		mov	[esp+8],ecx
	o32	ret
b_dec_bit:	dec	cl
		mov	[esp+8],ecx
	o32	ret

less_or_eq_bit:				; return ZF if 1,2 <= 3,4
		push	ecx
		mov	ecx,[esp+8]
		cmp	ecx,[esp+0x10]
		j_e	b_less_or_eq_bit
		j_g	n_less_or_eq_bit
		mov	eax,1
		pop	ecx
	o32	ret
n_less_or_eq_bit:
		xor	eax,eax
		pop	ecx
	o32	ret
b_less_or_eq_bit:
		mov	ecx,[esp+0xc]
		cmp	ecx,[esp+0x14]
		j_g	n_less_or_eq_bit
		mov	eax,1
		pop	ecx
	o32	ret

;twogt_bit:				; defunct.  deprecated.  onegt_bit?
;		push dword [esp+0x10]	; b2
;		push dword [esp+0xc+4]	; y2
;		call dword _inc_bit
;		add	esp,8
;		mov	eax,[esp]
;		cmp	eax,[esp+8]
;		j_e	b_twogt_bit
;		j_ng	n_twogt_bit
;		mov	eax,1
;	o32	ret
;n_twogt_bit:	xor	eax,eax
;	o32	ret
;b_twogt_bit:	mov	eax,[esp+4]
;		cmp	eax,[esp+0xc]
;		j_le	n_twogt_bit
;		mov	eax,1
;	o32	ret

onegt_bit:
		push dword [esp+0x10]	; b2
		push dword [esp+0xc+4]	; y2
		call dword _inc_bit
		pop dword [esp+0xc+4]
		pop dword [esp+0x10]
		mov	eax,[esp+4]
		cmp	eax,[esp+0xc]
		j_e	b_onegt_bit
		j_g	n_onegt_bit	; j_ng: no -> don't indicate 1 (?)
		mov	eax,1
	o32	ret
n_onegt_bit:	xor	eax,eax
	o32	ret
b_onegt_bit:	mov	eax,[esp+8]
		cmp	eax,[esp+0x10]
		j_ne	n_onegt_bit
		mov	eax,1
	o32	ret

BITMAP_LOC	equ	4096 - 456

bit_exceeds_limit:			; ( byte* this_byte, byte this_bit
		mov	eax,[esp+4]	; , byte* page )
		sub	eax,4095	; are we at the end of page's bitmap?
		cmp	eax,[esp+0xc]	; page
		j_e	b_bit_exceeds_limit
		j_l	n_bit_exceeds_limit
		mov	eax,1
	o32	ret
n_bit_exceeds_limit:
		xor	eax,eax
	o32	ret
b_bit_exceeds_limit:
		cmp dword [esp+8],1	; 456.1111
		j_b	n_bit_exceeds_limit
		mov	eax,1
	o32	ret

bit_matches_chunk:
		mov	eax,[esp]
		shl	eax,3		; FIXME not pointer-safe math
		add	eax,[esp+4]
		add	eax,[esp+0x10]
		mov	ecx,[esp+8]
		shl	ecx,3
		add	ecx,[esp+0xc]
		cmp	eax,ecx
		j_l	n_bit_matches_chunk
		mov	eax,1
	o32	ret
n_bit_matches_chunk:
		xor	eax,eax
	o32	ret

allocated_bit_byte:			; ( byte* this_byte, byte this_bit
		mov	eax,[esp+4]	; , byte* page ) ; page
		and	eax,0xfff
		sub	eax,BITMAP_LOC	; is now near zero.
		shl	eax,3
		;add	eax,[esp+0xc]	; bit? FIXME
		;shl	eax,3		; *= 8
		add	eax,[esp+8];0xc] ; F0007 we aren't passing page
		and dword [esp+4],0xfffff000
		or	eax,[esp+4]
		mov	[esp+4],eax
	o32	ret

NULL		equ	0
;---------------
_1bitmap_alloc:
		push dword 0
		mov	eax,BITMAP_LOC
		add	eax,[esp+4+4]	; page param
		push	eax
sis_1bitmap_alloc:
		call dword _bts		; bit, byte
		or	al,al
		j_z	sis0_1bitmap_alloc
		call dword _inc_bit	; bit, byte
		push dword [esp+8+4]	; page is a param
		push dword [esp+4+4]
		push dword [esp+4+4]
		call dword bit_exceeds_limit
		add	esp,0xc		; params discard
		or	al,al
		j_z	sis_1bitmap_alloc
exceed_1bitmap_alloc:
		call dword _btc
		add	esp,8
		mov	eax,0
	o32	ret	4+4
sis0_1bitmap_alloc:
		mov	eax,[esp]	; byte
		sub	eax,[esp+4+8]	; page
		sub	eax,BITMAP_LOC
		shl	eax,3
		add	eax,[esp+4]	; bit
		add	eax,[esp+8+8]	; chunk_size
		dec	eax		; - 1
		cmp	eax,BITMAP_LOC
		j_g	exceed_1bitmap_alloc ; clear orig?  clear sis.
		mov	ecx,eax
		and	ecx,7
		shr	eax,3
		add	eax,BITMAP_LOC
		add	eax,[esp+4+8]	; page
		push	ecx
		push	eax		; bit, byte boom = high bitc
		push	ecx
		push	eax		; bit, byte orig = high bitc

		push dword [esp+16+4]	; from sis
		push dword [esp+16+4]
		call dword _inc_bit	; bah
		;pop dword [esp+16+4]
		;pop dword [esp+16+4]
		; need sanity check on top bit?
		;re: { (faz,)bitc _inc_bit (faz,bah)cmp (ne)jg (ret)jl ne: } (boom)bts
		; - (boom_)jnz (boom)_dec_bit (re)jmp boom_: 'clear'.



		;-------
re_boom_1bitmap_alloc:
		push dword [esp+16+4]	; from boom (skip bah)
		push dword [esp+16+4]	; faz
		;call dword _dec_bit	; faz8, bah8, orig8, boom8, sis8, ip4, chunk4, page4
		mov	eax,[esp]	; faz ;bah
		cmp	eax,[esp+8]	; bah ;sis ;boom ;faz
		j_l	ret_1bitmap_alloc
		j_g	ne_1bitmap_alloc ; (true first time around?  new)
		mov	eax,[esp+4]	; faz ;bah
		cmp	eax,[esp+8+4]	; bah ;sis ;boom ;faz
		j_l	ret_1bitmap_alloc
		jmp dword ne_1bitmap_alloc
ret_1bitmap_alloc:
		add	esp,8+8+8+8
		mov	eax,[esp]
		sub	eax,[esp+4+8]
		sub	eax,BITMAP_LOC
		shl	eax,3
		add	eax,[esp+4]
		add	esp,8		; sis
		add	eax,[esp+4]	; page param (new)
	o32	ret	4+4
ne_1bitmap_alloc:
		;pop dword [esp+16+4]
		;pop dword [esp+16+4]	; boom = faz ?
		add	esp,8		; (faz)
		push dword [esp+8+8+4] ; boom
		push dword [esp+8+8+4] ; boom
		call dword _bts
		or	al,al
		j_nz	boom_1bitmap_alloc
		call dword _dec_bit
		pop dword [esp+8+8+4]	; boom = bah - 1 ;faz
		pop dword [esp+8+8+4]
		;add	esp,8		; (bah)
		jmp dword re_boom_1bitmap_alloc
boom_1bitmap_alloc:
		;call dword _inc_bit
		pop dword [esp+8+8+4]	; a delayed step, ;faz
		pop dword [esp+8+8+4]	; boom = bah ;+ 1.
		;add	esp,8		; discard, as boom was set.
		push dword [esp+8+8+8+4]
		push dword [esp+8+8+8+4]
		call dword _btc		; clear bit sis once
		add	esp,8		; (copy of sis)

		mov	eax,[esp+8]	; boom
		cmp	eax,[esp]	; orig
		j_g	cleared_1bitmap_alloc
		j_ne	clear_1bitmap_alloc
		mov	eax,[esp+8+4]
		cmp	eax,[esp+4]
		j_g	cleared_1bitmap_alloc
		j_le	clear_1bitmap_alloc

clear_1bitmap_alloc:
		push dword [esp+8+4]
		push dword [esp+8+4]	; boom
		call dword _btc
		call dword _inc_bit
		add	esp,8
		mov	eax,[esp+8]	; boom
		cmp	eax,[esp]	; orig
		j_ne	clear_1bitmap_alloc
		mov	eax,[esp+8+4]	; boom
		cmp	eax,[esp+4]	; orig
		j_ne	clear_1bitmap_alloc
		;pop dword [esp+8+8+8+4]
		;pop dword [esp+8+8+8+4]
cleared_1bitmap_alloc:
		add	esp,8+8+8
		call dword _inc_bit	; sis
		jmp dword sis_1bitmap_alloc
;---------------
		;pop dword [esp+8+8+8+4]
		;pop dword [esp+8+8+8+4]
		;mov	eax,[esp]
		;mov	[esp+8+8+8],eax
		;mov	eax,[esp+4]
		;mov	[esp+8+8+8+4],eax

		;[esp+4]		; page
		;[esp+8]		; chunk
					; warning: does not preserve ecx.
bitmap_alloc:
		jmp dword _1bitmap_alloc





;--------------SNIP-------------------------------------------------------------
;---------------
bitmap_wipe:				; es = 0, param: page
		push	edi
		push	ecx
		mov	edi,[esp+4+8]
		test	di,0xfff
		j_nz	n_bitmap_wipe
		add	edi,BITMAP_LOC
		mov	ecx,456
l_bitmap_wipe:
		mov byte [edi],0
		inc	edi
		dec	ecx
		j_cxz	b_bitmap_wipe
		jmp dword l_bitmap_wipe
b_bitmap_wipe:
		pop	ecx
		pop	edi
	o32	ret	4		; pop page
n_bitmap_wipe:
		pop	ecx
		pop	edi
	o32	ret	4		; pop page
;---------------
		;[esp+4]=byte
		;[esp+8]=len
bitmap_free:				; clear from param to param+len
		mov	eax,[esp+4]
		and	eax,0xfff
		add	eax,[esp+8]
		;mov	eax,[esp+4]
		;and	eax,0xfff
		;shl	eax,3
		;add	eax,[esp+0xc]
		cmp	eax,BITMAP_LOC	; 4096-456
		j_ng	b_bitmap_free	; jnl here FIXME
		mov	eax,1
	o32	ret	8
b_bitmap_free:
		push	ebx
		push	ecx
		push	edx
		;push dword 0		; eax occupied.
		mov	edx,[esp+4+0xc]
		and	edx,0xfff
		mov	ebx,edx
		and	bx,0x0007
		shr	edx,3
		add	edx,BITMAP_LOC
		;push	ecx
		mov	ecx,eax
		and	cx,0x0007
		shr	eax,3
		add	eax,BITMAP_LOC
		;push	eax
		;push dword [esp+8+4]	; param bit
		push	ebx
		;push dword [esp+4+8]	; param byte
		push	edx
		push	ecx		; param+len bit
		mov	ecx,eax
		mov	eax,[esp+4+0xc+0xc] ; param ; 3? this is ret addr
		and	eax,0xfffff000
		add	[esp+4],eax
		add	eax,ecx
		push	eax		; param+len byte
		;add	esp,4
l_bitmap_free:
		call dword less_or_eq_bit ; 4 <= 3 ?
		or	al,al
		j_nz	done_bitmap_free ; no -> break;
		push dword [esp+0xc]	; top_bite_bit
		push dword [esp+8+4]	; top_bite_byte
		call dword _bts
		or	al,al
		j_z	corrupt_bitmap_free
		call dword _btc
		or	al,al
		j_z	corrupt_bitmap_free
		call dword _inc_bit	; F0004
		pop dword [esp+8+4]	; now what is esp: see stack_ck
		pop dword [esp+0xc]
		jmp dword l_bitmap_free
corrupt_bitmap_free:
		add	esp,8+0x10
		pop	edx
		pop	ecx
		pop	ebx
		mov	eax,2
	o32	ret	8
done_bitmap_free:
		add	esp,0x10
		pop	edx
		pop	ecx
		pop	ebx
		xor	eax,eax
	o32	ret	8
;---------------
;--------------SNIP-------------------------------------------------------------









;---------------

kbhit:
		push	eax
		xor	eax,eax
		int_	0x16
		pop	eax
	o32	ret
;---------------

init_main	dd	0

alloc_addr	dd	0

memtotal	dd	0
mmtrunk		dd	0

_main:					; here <- 0xc205
		cmp dword [dword init_main],1
		j_e	cont_main
		inc dword [dword init_main] ; 0x101b3c today
		push	eax
		mov	esi,8
cont_init_main:
		mov	eax,[ebx+esi]
		;call dword dwordhexout	; want to see the tags?
		call dword [mb2calls+eax*4]
		add	esi,[ebx+esi+4]
		test	si,0x0007
		j_z	even_init_main
		and	si,0xfff8
		add	esi,8
even_init_main:
		cmp	esi,[ebx]	; 0x248
		j_ne	cont_init_main

		add	esi,ebx		; now I just use this one location.
		or	si,0x0fff
		j_z	even_alloc_main
		and	si,0xf000
		add	esi,0x1000
even_alloc_main:
		mov	[dword alloc_addr],esi ; 0x100ae8 or proper comment?

;--------------SNIP-------------------------------------------------------------
		;mov	eax,edi
		;call dword dwordhexout

		call dword kbhit

; calls: leaves_init_alloc, bitmap_alloc 5 times, fmtrunk_alloc, kbhit.

		jmp dword sktest_even_alloc_main
		push dword 6
		push dword [dword alloc_addr] ; first usable page
		call dword bitmap_alloc	; sp = 0x9ee4
		call dword dwordhexout
		;call dword kbhit

		push dword 9
		push dword [dword alloc_addr]
		call dword bitmap_alloc
		call dword dwordhexout
		;
		push dword 0x11
		push dword [dword alloc_addr]
		call dword bitmap_alloc
		call dword dwordhexout

		push dword 2
		push	eax
		call dword bitmap_free	; old test code, SNIP ouch.
		call dword dwordhexout

		push dword 3
		push dword [dword alloc_addr]
		call dword bitmap_alloc
		call dword dwordhexout

		push dword 2
		push dword [dword alloc_addr]
		call dword bitmap_alloc
		call dword dwordhexout

sktest_even_alloc_main:
		pop	eax
cont_main:
		inc	eax
		cmp	al,0x3a
		j_ne	counting_main	; example conditional
		sub	al,0x0a
		;int_	8		; example int call
counting_main:
		mov	[es:edi],ax
		inc	edi
		inc	edi
	o32	ret
