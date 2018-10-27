.586
.model flat,stdcall
include w_con.inc
extrn MessageBoxA:proc
extrn ExitProcess:proc
extrn GetModuleHandleA:proc
extrn DialogBoxParamA:proc
extrn PostQuitMessage:proc
extrn EndDialog:proc
extrn SetScrollPos:proc
extrn EnableScrollBar:proc
extrn GetScrollRange:proc
extrn GetDlgItemTextA:proc
extrn GetWindowRect:proc
extrn ScrollWindowEx:proc
extrn SetDlgItemTextA:proc
extrn UpdateWindow:proc
extrn LocalAlloc:proc
;;;;;;
dwo equ <dword ptr>
include mmx32.inc
p0 macro
xor eax,eax
p eax
endm
.data
freq dd 0
n1 dd 0 ;число разрядов value
value dd 0
n_ label word
nby db 0 ;число байт в вэлью
nbi db 0 ;число бит
q1 dd 0
q3 dd 0
f1 db '1.txt',0
f2 db '1_.txt',0
hfd dd 0
hfs dd 0
hmem dd 0
hmemf dd 0 ;байты  исх.файла
sz_file_s dd 0 ;size of src file
sz_hmem dd 0
n_simb db 0 ;число симв. в алфав.
htab dd 0 ;of table
i_modif dd 0 ;1: реал.размер на 1 меньше
half dd 0 ;50% of file
futurebits db 0
ptroutbyte dd 0
ptroutbit db 0
int_left dd 0 
nbitsz dd 0
eqbits db 0
dest dd 0
db 0
extrn OpenFile:proc
;esi=of src_file
;edi=of dst_file

.code
m1:
mov esi,of f1
mov edi,of f2
mov ebp,esp
sub esp,100h
mov eax,esp
p OF_READ	
p eax
p esi
call OpenFile
mov hfs,eax
inc eax
jnz j1
exit:
mov esp,ebp
exit1:
p hmem
extrn LocalFree:proc
call LocalFree
p hmemf
call LocalFree
p MB_OK
p of f1
p [esp]
p0
extrn MessageBoxA:proc
call MessageBoxA

p0
call ExitProcess
;;;;;
j1:
dec eax
p eax
p esp
p eax
extrn GetFileSize:proc
call GetFileSize
pop ecx
jcxz j2
jmp exit
j2:
mov esi,eax
test eax,1
;jz msp
jmp msp
inc eax
mov i_modif,1
msp:
p eax
mov sz_file_s,eax
shr eax,1
mov half,eax
p LMEM_ZEROINIT
call LocalAlloc
mov hmemf,eax
dec eax
js  exit
p0
p FILE_ATTRIBUTE_NORMAL	
p CREATE_ALWAYS	
p eax
p eax
p GENERIC_WRITE+GENERIC_READ	
p edi
extrn  CreateFileA:proc
call  CreateFileA
mov hfd,eax
inc eax
jz exit
extrn  GetSystemInfo:proc
SZ_DIC=1000000
SZ_COD=100000
p SZ_COD+SZ_DIC
p LMEM_ZEROINIT
call LocalAlloc
mov hmem,eax
add eax,SZ_COD
mov hdic,eax
dec eax
js exit
xor ebx,ebx
mov edi,hmemf
p ebx
mov edx,esp
p ebx
p edx
p esi ;sz_file
p edi
p hfs
extrn  ReadFile:proc
call  ReadFile 
dec eax
js exit
mov esp,ebp
cmp i_modif,1
jne go
add edi,eax
inc edi
xor eax,eax
stosb
go:
db 0fh,31h
mov rhi,edx
mov rlo,eax
call lz78 ;GOOOOOOOOOOOOOOOOOOOOOOOOOOO!!!!!!!!!!!
db 0fh,31h
sub edx,rhi
sub eax,rlo
mov edi,of f1
mov ecx,8
p ecx
xchg eax,edx
call xl1
mov al,':'
stosb
mov eax,edx
pop ecx
call xl1
xor eax,eax
stosb
jmp exit1
xl1:
rol eax,4
p eax
shl ax,4
shr al,4
add al,30h
cmp al,39h
jbe x1
add al,7
x1:
stosb
pop eax
loop xl1
ret
call arifm_mmx_fpu
call unpack
;;;;;;;;;;;;;;;;;;
lz78:		;в конце исход файла в памяти: 0
.data
rlo dd 0
rhi dd 0
hdic dd 0
nsrc dd 2 ;номер исх. фразы
;len_max_sovpad_frasa dd 0 ;=rmmx0
;cur_buf dd 0 ;rmmx1
;num_last_sovpad_frase dd 0 ;rmmx2
nzakodir dd 0 
s db 0 ;symbol after n in zakodir_infe
fin_edi dd 0
fin_dic dd 0 ;ptr eof_dic
num_frases dd 2 ;число просмотренных фраз
.code
emms
mov eax,hdic
add eax,SZ_DIC
mov fin_dic,eax
mov eax,hmemf
add eax,sz_file_s
mov fin_edi,eax
mov ebp,hmem ;dst
mov ebx,hdic ;dic ;dw len_fr|fr...
mov esi,hmemf ;src=buffer
;movd rmmx1,esi
db 0fh,6eh,0ceh
cld
goo:
xor eax,eax
inc eax
;movd rmmx0,eax
db 0fh,6eh,0c0h
inc eax
;movd rmmx2,eax
db 0fh,6eh,0d0h
mov num_frases,2
;
mov edi,ebx
cmp esi,fin_edi
jne jne__0
xor ebx,ebx
mov byte ptr [ebp],0
inc ebp
jmp exlz
jne__0:
fnd_biger_frase:
;movd esi,rmmx1
db db 0fh,7eh,0ceh
xor ecx,ecx
inc ecx
lodsb
p eax
xchg edi,esi
lodsw
or ax,ax
jz end_dic
xor edx,edx
mov dx,ax
pop eax
xchg edi,esi
fnd_frase:
or ebx,ebx ;ebx#0;else ebx=0=flag: EOF
jz fraza_fnd_
scasb
jnz fraza_fnd
cmp esi,fin_edi
jne jne__
xor ebx,ebx
jne__:
lodsb ;next bufer c
inc ecx;len_sovpad
dec edx
jnz fnd_frase
	;найдено полное совпад.
inc num_frases
;movd rmmx2,num_frases
db 0fh,6eh,15h
dd num_frases
;movd eax,rmmx0
db 0fh,7eh,0c0h
;cmova ecx,eax
db 0fh,47h,0c8h
;movd rmmx0,ecx
db 0fh,6eh,0c1h
jmp fnd_biger_frase
fraza_fnd_:
inc edi
	;найдено частич. совпад.
fraza_fnd: 
inc num_frases
add edi,edx ;edi=след. фраза словаря
dec edi
jmp fnd_biger_frase
end_dic:
	;добавить в словарь фразу
;int 3
pop eax
xchg edi,esi
;movd ecx,rmmx0
db 0fh,7eh,0c1h
or ebx,ebx
jnz jnz__
dec ecx
jnz__:
dec edi
dec edi
mov ax,cx
mov edx,edi
add edx,ecx
inc edx
inc edx
cmp edx,fin_dic
jb ok1
mov edi,hdic ;заново заполн. словарь (переполнение)
ok1:
stosw
p ecx
dec esi
rep movsb
dec esi
lodsb
mov s,al
xor eax,eax
stosw
pop ecx
;movd rmmx1,esi
db 0fh,6eh,0ceh
	;закодир. данные: n|c
mov edi,ebp
dec ecx
jnz not1
inc ecx
;movd rmmx2,ecx
db 0fh,6eh,0d1h
not1:
xor ecx,ecx
;movd eax,rmmx2
db 0fh,7eh,0d0h
dec eax
jnz jnzzz
inc eax
jnzzz:
mov edx,nzakodir
notdec:
shr edx,8
or edx,edx
jz decreased
inc ecx ;num байтов для представл. n
jmp notdec
decreased:
inc nzakodir
wr_n:
stosb
dec ecx
js nowr_n
jnz wr_n
nowr_n:
mov al,s
stosb
mov ebp,edi
or ebx,ebx
jnz goo
exlz:
p0
p of f1
sub ebp,hmem
p ebp ;sz
p hmem
p hfd
extrn WriteFile:proc
call WriteFile
int 3
ret


;;;;;;;;;;;;;
unpack: ;arifm
;sz_unp
;nbit
;nbyte
;modif
;htab : sym|n|chast
;li|hi|li`|hi`
;nbyte dup (?) ;zipped infa
;;;;hmemf=^
mov ebp,hmemf
mov eax,[ebp]
db 0FBh,0DCh
mov ecx,eax
p ecx
u1:
shl ecx,1
bts eax,ecx
or ecx,ecx
jnz u1
mov edx,32
pop ebx
sub edx,ebx
mov  n1,edx
p eax
mov eax,edx
mov dl,8
idiv dl
mov nby,al
mov nbi,ah
pop edx ;edx=mask
mov ecx,[ebp+8]
shl ecx,3
add ecx,[ebp+4]
lea esi,[ebp+9*256+4*4*2]
p [ebp]
pop [esi-4] ;hi`
mov [esi-8],0 ;li`
mov [esi-8-4],0
mov [esi-8-8],0
mov edi,hmem
add esi,ptroutbyte
lodsd
mov cl,ptroutbit
shr eax,cl
rol eax,16
mov ebx,eax
lodsb
mov ch,8
sub ch,cl
xchg cl,ch
shl al,cl
shr al,cl
xchg al,ah
or bl,al
rol ebx,16 ;value
;edi=hmem;ebx=value;edx=mask
mov value,ebx
p ebx
mov bx,n_
xor ecx,ecx
mov cl,bh
add ptroutbit,cl
cmp ptroutbit,8
jb ujb1
sub ptroutbit,8
inc bl
ujb1:
mov cl,bl
add ptroutbyte,ecx
pop ebx
lea esi,[ebp+9*256+4*4+2*4]
inc ebx
lodsd ;li`
sub ebx,eax
p ebx 
fild dwo [esp]
fild dwo [ebp] ;sz0
fmul
fld1
fsub
mov ebx,eax
lodsd
sub eax,ebx
inc eax
p eax
fild dwo [esp]
fdiv
fstp dwo [esp]
pop ecx ;freq
pop ebx ;(hi-li+1)
mov freq,ecx
lea esi,[ebp+4*4+9*256-4]
std
fld dwo [esi]
cmpsd
cmpsd
cmpsb
fcom freq
fstsw ax
sahf
;st0>freq jmp ;000
jc go1
jnz nogo1
go1:




nogo1:




;;;;;;;;;;;;;;;;;;;;;
arifm_mmx_fpu proc
cld
p ax
fstcw word ptr [esp]
pop ax
or ah,1100b
p ax
fldcw word ptr [esp]
pop ax
mov ecx,sz_file_s
db 0fh,0bdh,0c9h
mov nbitsz,ecx
mov ebx,hmem
mov esi,hmemf
mov ecx,sz_file_s
xor eax,eax
l1: 		;4
lodsb
inc dwo [ebx+eax*4]
dec ecx
jnz l1
;сортировка выбором
lea edi,[ebx+256*4]
p edi
srl1:
xor ebp,ebp
mov esi,ebx
lodsd
mov edx,eax
p ecx
xor ecx,ecx
inc ecx
sbk1:
lodsd
cmp eax,edx
jbe srt1
mov edx,eax
mov ebp,ecx
srt1:
inc cl
jnz sbk1
pop ecx
mov eax,ebp
stosb
mov dwo [ebx+4*eax],0
mov eax,edx
stosd
p eax
fild dwo [esp]
fild sz_file_s
fdiv
fld int_left
fadd
fst int_left
fstp dwo [esp]
pop eax
stosd
inc cl
jnz srl1
srtok:
pop esi ;table
mov htab,esi
mov [esi-4],0
mov [esi-8],0
mov [esi-4-8],0
p edi
std
scasd
scasd
xor eax,eax
delz1:
scasd
jnz delz0
scasd
scasb
dec cl
jmp delz1
delz0:
;dec ecx
mov n_simb,cl
cld
mov ah,cl
pop edi ;edi=after sorted_table

mov ebp,htab
mov esi,hmemf
mov ecx,sz_file_s
dec ecx
mov [edi+0ch],ecx
inc ecx
p ecx
shr ecx,2
mov q1,ecx
mov eax,ecx
pop ecx
p ecx
shr ecx,1
add eax,ecx
pop ecx
mov q3,eax
;;;;;begin coding
mov ebx,edi
add edi,4*4
mov dest,edi
l_go:
p ecx
lodsb
p edi
mov edi,ebp
_j0:
scasb
jz _j1
scasd
scasd
jmp _j0
_j1:     ;нашли очеред. символ в табл.
p esi
sub edi,1+8 ;edi=N(prev_symb)
lea esi,[ebx+8]
finit
fld dwo [edi+4] ;chast
lodsd  ;li`
p eax
mov edx,eax
lodsd
sub eax,edx
inc eax
p eax    
fild dwo [esp] ;[h(i-1)-l(i-1)+1]
fst st(2)

fmul
fld dwo [edi+9+4]
fmul st(0),st(2)
frndint 
fistp dwo [esp]
pop eax
pop edx
p eax
frndint 
fistp dwo [esp]
add eax,edx
dec eax ;hi
fincstp
xchg edi,esi
std
scasd
scasd
scasd
stosd
pop eax
add eax,edx
stosd
cld
xchg edi,esi
;имеем li,hi
lodsd
lodsd
p ebx
mov edx,eax
lodsd
cmp eax,half
jae jae1
call _out0
jmp exi1
jae1:
cmp edx,half
jb jb01
call _out1
sub eax,half
sub edx,half
jmp exi1
jb01:
cmp edx,q1
jb exi1
cmp eax,q3
jae exi1
inc futurebits
sub eax,q1
sub edx,q1
jmp exi1

_out1 proc
xor ebx,ebx
inc ebx
jmp short jm1
_out0 proc
xor ebx,ebx
jm1:
call wrout
ret
_out0 endp

_out1 endp

exi1:
mov edi,esi
shl eax,1
inc eax
shl edx,1
xchg eax,edx
stosd
mov eax,edx
stosd
pop ebx
pop esi
pop edi
pop ecx
dec ecx
jnz l_go
p i_modif
p ptroutbyte
xor eax,eax
mov al,ptroutbit
p eax
p sz_file_s
mov ebx,esp
p0
p of f1
p 4*4
p ebx
p hfd
extrn WriteFile:proc
call WriteFile
add esp,4*4
p0
p of f1
mov eax,ptroutbyte
add eax,9*256+4*4
inc eax
p eax
p htab
p hfd
extrn WriteFile:proc
call WriteFile
ex0:
p hfd
extrn CloseHandle:proc
call CloseHandle
p hfs
call CloseHandle
jmp exit1



wrout proc        ;in: ebx
p esi
xor ecx,ecx
mov esi,dest
add esi,ptroutbyte
mov edi,esi
mov cl,ptroutbit
mov bh,al
lodsb
btr eax,ecx
dec bl

js p0_
bts eax,ecx
p0_:
inc ebx
stosb
mov al,bh
p eax
inc cl
dec esi
cmp cl,8
jne nx02a
inc esi
xor ecx,ecx
inc ptroutbyte
nx02a:
mov edi,esi
mov ptroutbit,cl
mov bh,bl
xor bh,1
mov bl,futurebits
bk08:
lodsb
bk07:
or bl,bl
je nx05
bts eax,ecx
cmp bh,1
je bh1
btr eax,ecx
bh1:
dec bl
inc cl
cmp cl,8
jne bk07
xor cl,cl
inc ptroutbyte
stosb
jmp bk08
nx05:
stosb
mov ptroutbit,cl
mov futurebits,bl
pop eax
pop esi
ret

wrout endp

arifm_mmx_fpu endp







end m1




