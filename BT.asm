;Block Transfer program

;********************************************************************

Section .data

msg: db 0x0A
len: equ $-msg

msg1: db "Address			Data",0x0A
len1: equ $-msg1

msg2: db "Enter number of bytes to be overlapped: "
len2: equ $-msg2

msg3:	db "1. Non-overlapped",0x0A
	db "2. Non-overlapped(w/o string)",0x0A
	db "3. Ovelapped Upper Half",0x0A
	db "4. Overlapped Upper Half(w/o string)",0x0A
	db "5. Overlapped Lower Half",0x0A
	db "6. Overlapped Lower Half(w/o string)",0x0A
	db "Enter choice: "
len3:	equ $-msg3

msg4: db "Invalid input."
len4: equ $-msg4

msg5: db "	"
len5: equ $-msg5

;********************************************************************

Section .bss

data: resb 0x05
dest: resb 0x05
chc: resb 0x01
result: resb 0x08
res: resb 0x01
cntb: resb 0x01
cntd: resb 0x01
cnto: resb 0x01

;********************************************************************

%macro print 2				;Macro for print
	mov rax,0x01
	mov rdi,0x01
	mov rsi,%1
	mov rdx,%2
	syscall
%endmacro

;********************************************************************

%macro read 2				;Macro for read
	mov rax,0x00
	mov rdi,0x00
	mov rsi,%1
	mov rdx,%2
	syscall
%endmacro

;********************************************************************

Section .text
Global _start
_start:

init:
	mov byte[data],0x12
	mov byte[data+1],0x34
	mov byte[data+2],0x56
	mov byte[data+3],0x78
	mov byte[data+4],0x9A
	
	print msg1,len1
	mov rsi,data
	mov byte[cntb],0x05
	xor rbx,rbx

	call show			;Display initial data

;********************************************************************
	
menu:
	print msg3,len3
	read chc,0x02	

	cmp byte[chc],0x31
	je non_overlap

	cmp byte[chc],0x32
	je non_overlap

	cmp byte[chc],0x36
	jbe overlap

	print msg4,len4

;********************************************************************

non_overlap:
	mov rsi,data
	mov rdi,dest
	mov r8,rdi
	cld

	xor rcx,rcx

	cmp byte[chc],0x31
	je wostring

	cmp byte[chc],0x32
	je string

;********************************************************************

overlap:
	print msg2,len2
	read cnto,0x02
	
	cmp byte[cnto],0x39		;ASCII to HEX
	jbe digit
	sub byte[cnto],0x07

digit:
	sub byte[cnto],0x30
	
	cmp byte[chc],0x33
	je upper

	cmp byte[chc],0x34
	je upper

	cmp byte[chc],0x35
	je lower

	cmp byte[chc],0x36
	je lower

upper:
	mov rsi,data
	mov rdi,rsi
	
	xor rax,rax		
	mov al,0x05
	
	sub al,byte[cnto]		;To get location to start printing.
	add rdi,rax

	mov r8,rdi			;For display !!!!
	
	add rdi,0x04			;Print from end with decrement as numbers will be lost if increment
	add rsi,0x04

	std				;For string function to print and decrement

	cmp byte[chc],0x33
	je string
	
	cmp byte[chc],0x34
	je upperwostring

;********************************************************************

lower:
	mov rsi,data
	mov rdi,rsi
	
	xor rax,rax
	mov al,0x05
	
	sub al,byte[cnto]
	
	sub rdi,rax
	mov r8,rdi
	
	cld
	xor rcx,rcx
	
	cmp byte[chc],0x35
	je string

	cmp byte[chc],0x36
	je wostring

;********************************************************************
;All Functions: 

string:					;Store Function.
	mov rcx,0x05
	rep movsb

	jmp display	

wostring:				;Store Function.
	xor rcx,rcx
	mov rcx,0x05
	
loop:
	mov al,byte[rsi]
	mov byte[rdi],al
	inc rsi
	inc rdi
	dec rcx
	jnz loop

	jmp display

upperwostring:				;Store function
	xor rcx,rcx
	mov rcx,0x05	

loop1:
	mov al,byte[rsi]
	mov byte[rdi],al
	dec rsi
	dec rdi

	loop loop1			;Automaticaly loops till rcx not zero

	jmp display

;********************************************************************

display:
	print msg1,len1
	mov rdi,r8			;Original address of rdi stored in r8 in respective functions
	mov rsi,rdi
	mov byte[cntb],0x05
	call show			;Display final data

;********************************************************************

exit:
	mov rax,0x3C
	mov rdi,0x00
	syscall

;********************************************************************

disp:					;HEX to ASCII display routine.
	xor rbx,rbx

back:
	rol qword[result],4
	mov bl,byte[result]
	and bl,0FH
	cmp bl,09H
	jbe next
	add bl,07H

next:
	add bl,30H
	mov byte[res],bl
	print res,1
	dec byte[cntd]
	jnz back
	ret

;********************************************************************

show:					;Function to  display address first then number
	mov [result],rsi		;Address taken in result for display
	mov byte[cntd],0x10
	push rsi			;rsi changes in disp function and also when using near/far call therefore store in stack.
	call disp
	
	print msg5,len5
	pop rsi		
	mov cl,byte[rsi]
	mov byte[result+7],cl		;Byte data stored in result+7 for printing
	mov byte[cntd],0x02
	push rsi
	call disp
	
	print msg,len
	pop rsi				
	inc rsi
	dec byte[cntb]
	jnz show
	ret
