.model tiny
.code
.486
org 100h
of equ offset
p equ push
m1:
MAXX equ 320
MAXY equ 200
p 0a000h
pop es
mov ax,13h
int 10h
mov esi,of xy1
mov ecx,3
cld
go:
p cx
mov esi,of xy1
mov edi,esi
mov eax,3
sub eax,ecx
shl eax,2
add esi,eax
cmp al,8
lodsd
mov edx,eax
lodsd
jne j1
mov esi,edi
lodsd
j1:
mov ecx,eax
;dydx:
sub ecx,edx
p edx
call do_d
mov dx,cx 
rol ecx,16
call do_d
xchg cx,dx
;cx=incX ,dx=incY
mov ax,bp ;dy
mov di,ax
rol ebp,16
mov si,bp 
cmp ax,bp
ja ja1
mov ax,bp
ja1:
mov bx,ax 
;bx=d
;si=dx, di=dy
pop ebp ;pixel Y|X
call pix
mov ax,bx
mov xerr,0
mov yerr,0
go2:
add xerr,si
add yerr,di
cmp xerr,bx
jbe go21
sub xerr,bx
add bp,cx
go21:
cmp yerr,bx
jbe go22
sub yerr,bx
rol ebp,16
add bp,dx
rol ebp,16
go22:
call pix
dec ax
jns go2
pop cx
dec cx
jnz go
xor ax,ax
int 16h
ret
;;;;;;;;;;;
pix proc
pushad
mov bx,bp
rol ebp,16
mov di,bp
shl di,8
shl bp,6
add di,bp
add di,bx
mov al,color
stosb
popad
ret
pix endp

do_d proc
rol ebp,16
mov bp,cx
test cx,cx
jnz jnz1
xor cx,cx
ret
jnz1:
js js1
xor cx,cx
inc cx
ret
js1:
neg cx
mov bp,cx
xor cx,cx
dec cx
ret
do_d endp
;;;;;;;;;;
;(2,3);(100;30);
;(100;30);(70;80);
;(70;80);(10;11);
xy1 dw 2,3
xy2 dw 108,60
xy3 dw 70,100
xerr dw 0
yerr dw 0
color db 0ah




end m1
