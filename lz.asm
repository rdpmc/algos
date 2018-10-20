;0:3a/70/44 (16/100000)
.586
.model flat,stdcall
include w_con.inc
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
rd1 macro
pushad
pushf
rdtsc
mov lo_,eax
mov hi_,edx
popf
popad
endm

rd2 macro
local nonzz
pushad
pushf
rdtsc
sub eax,lo_
sub edx,hi_
cmp nzakodir,04000h
jb nonzz
int 3
nonzz:
popf
popad
endm

.data
tag dw 0
fin_dics dd 0
max_str dd 1
num_frase dd 0
dics_top dd 0
len_win dd 15
SZ_DIC dd 60000
window dd 0
f1 db '1.txt',0
f2 db '1_.txt',0
hfd dd 0
hfs dd 0
fex db 0
hmem dd 0
hmemf dd 0 ;байты  исх.файла
hdics dd 0
hpart dd 0
sz_file_s dd 0 ;size of src file
rlo dd 0
rhi dd 0
lo_ dd 0
hi_ dd 0
hdic dd 0
nsrc dd 2 ;номер исх. фразы
nzakodir dd 0 
s db 0 ;symbol after n in zakodir_infe
fin_edi dd 0
fin_dic dd 0 ;ptr eof_dic
num_frases dd 2 ;число просмотренных фраз
extrn OpenFile:proc
;esi=of src_file
;edi=of dst_file
ms1 db '???_Zip(Y)_or_Unzip(N)_???',0
uz db 0
dum1 dd 0
dic_top dd 0
rdtsc macro
db 0fh,31h
endm
.code
m1:
jmp nocmd
extrn GetCommandLineA:proc
call GetCommandLineA
;/len_win,len_dic
mov edi,eax
cld
mov al,','
repne scasb
mov cl,'/'
call conv
p ebp
xor eax,eax
cld
repne scasb
mov cl,','
call conv
mov SZ_DIC,ebp
pop len_win
nocmd:
mov esi,of f1
mov edi,of f2
p MB_YESNO
p of ms1
p [esp]
p0
call MessageBoxA
cmp eax,IDYES
je ggo
mov uz,1
xchg edi,esi
ggo:
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
p eax
mov sz_file_s,eax
p LMEM_ZEROINIT
call LocalAlloc
mov hmemf,eax
dec eax
js  exit
inc eax
xor ebx,ebx
p ebx
mov edx,esp
p ebx
p edx
p sz_file_s ;sz_file
p eax
p hfs
extrn  ReadFile:proc
call  ReadFile 
pop ebx
dec eax
js exit
mov esi,hmemf
cld
lodsd
cmp uz,1
jne nnn
mov sz_file_s,eax
nnn:
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
mov eax,SZ_DIC
shl eax,2
add eax,sz_file_s
mov ebx,len_win
shl ebx,2
add eax,ebx
p eax ;szdic*3+len_win*4+sz
p LMEM_ZEROINIT
call LocalAlloc
mov hmem,eax
add eax,sz_file_s
mov hdic,eax
add eax,SZ_DIC
mov hdics,eax
add eax,SZ_DIC
add eax,SZ_DIC
add eax,SZ_DIC
mov hpart,eax
p hdics
pop [eax]
dec eax
js exit
mov esp,ebp
go:
db 0fh,31h
mov rhi,edx
mov rlo,eax
call lz78 ;GOOOOOOOOOOOOOOOOOOOOOOOOOOO
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
;;;;;;;;;;


conv:
mov esi,edi
dec esi
dec esi
xor eax,eax
xor ebx,ebx
xor ebp,ebp
inc ebx
std
nxc0:
lodsb
cmp al,cl
je nxc
sub al,30h
cmp al,9
jbe nxc1
sub al,7
nxc1:
imul ebx
add ebp,eax
imul ebx,ebx,10
jmp nxc0
nxc:
ret




;;;;;;;;;;;;;;;;;;
lz78:		;в конце исход файла в памяти: 0
;len_max_sovpad_frasa dd 0 ;=rmmx0
;cur_buf dd 0 ;rmmx1
;num_last_sovpad_frase dd 0 ;rmmx2
emms
cmp uz,0
je uz0
call unpack
mov ebp,hmem
add ebp,sz_file_s
jmp exlz
uz0:
p hdics
pop  dics_top
p hdic
pop dic_top
mov eax,hdic
add eax,SZ_DIC
mov fin_dic,eax
add eax,SZ_DIC
add eax,SZ_DIC
add eax,SZ_DIC
mov fin_dics,eax
mov eax,hmemf
add eax,sz_file_s
mov fin_edi,eax
mov ebp,hmem ;dst
p sz_file_s
pop [ebp]
add ebp,4
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
;
mov edi,ebx
cmp esi,fin_edi
jb jne__0
mov ecx,nzakodir
db 0fh,0bdh,0c9h
shr ecx,3
inc ecx
xor eax,eax
xor ebx,ebx
mov edi,ebp
rep stosb
mov ebp,edi
exittt:
jmp exlz
jne__0:
db 0fh,7eh,0ceh ;movd esi,rmmx1
p len_win
pop window
;hdics: dw len;dd off in hdic; dd num_fr
mov ebx,esi
mov fex,0
;;;;;;;;;******************
fnd:
;int 3
;rd1
cmp fex,1
je exittt
p ebp ;hmem
mov ebx,max_str
inc ebx
cmp ebx,window
jbe  jbem
;
mov ebx,window
dec ebx
mov max_str,ebx
inc ebx
jbem:
dec ebx
fgo:
;int 3
mov eax,dic_top
add eax,window
inc eax
inc eax
sub eax,hdic
mov ecx,eax
mov eax,dics_top
add eax,11+1
sub eax,hdics
cmp ecx,SZ_DIC
jb jb999
;int 3
p hdic
pop dic_top
mov max_str,1
db 0fh,73h,0F4h,64h ;psllq rmmx4,64
p hdics
pop dics_top
shr ecx,5
inc ecx
mov edi,hdic
call cls
mov edi,hdics
mov ecx,eax
shr ecx,5
inc ecx
call cls
mov ecx,len_win
shr ecx,3
inc ecx
mov edi,hpart
mov eax,hdics
stosd
call cls
xor ebx,ebx
inc ebx
jb999:
xor edx,edx
mov ecx,ebx
db  0fh,7eh,0ceh ;movd esi,rmmx1
xor ebp,ebp
;int 3
lo1:			;CRC=sum_db
xor eax,eax
lodsb
add dx,ax
rol dx,1
dec ecx
jz lo2
lodsb 
shl eax,8
add dx,ax
rol dx,1
dec ecx
jnz lo1
lo2:
mov tag,dx
mov edx,esi ;eof_window
dec edx
mov esi,ebx
dec esi
shl esi,2
add esi,hpart ;ptr sub-massives
lodsd
mov esi,eax
;rd2
;rd1
;int 3
mov ecx,dics_top
mov edi,esi
mov ax,tag
rol eax,16
mov ax,bx
mov ebp,edi
sc2:
scasd
je sc1
corr:
cmp word ptr [edi-4],ax
jne nxsc
nosc:
add edi,8
cmp edi,dics_top
jb sc2
jmp  fndex_1
nxsc:
dec eax
rol eax,16
sub edi,4
mov ebp,edi; =начало подмассива
	    ; длиной элем.=ax=bx
xor ecx,ecx
ror ax,1
mov cl,byte ptr [edx]	
test ebx,1
jnz ebx0
shl ecx,8
ebx0:
sub ax,cx
mov tag,ax
rol eax,16
dec edx
dec ebx
jnz sc2
jmp fndex_1
sc1:
;;;;;;;;;;;;;;FNDO
ebpnz:
xor ecx,ecx
mov cx,bx
p eax
p edi
mov esi,edi
lodsd
mov edi,eax
lodsd 
mov num_frase,eax
inc edi
inc edi
db 0fh,7eh,0ceh ;movd esi,rmmx1
p ebx
mov ebx,ecx
repe cmpsb
mov eax,esi
pop ecx
pop edi
jz equ_
pop eax
mov ebx,ecx
jmp nosc
;;;;;;+++++++++++
equ_:
;rd2
;rd1
;int 3
pop esi
p eax
;int 3
mov esi,dics_top
mov ecx,esi
sub ecx,ebp
inc ecx
lea edi,[esi+6+4+2]
mov dics_top,edi
sub edi,8
sub esi,8
std
jmp1:
sub ecx,8
js js__
db 0Fh,6Fh,2Eh ;movq rmmx5,[esi]
db 0Fh,7Fh,2Fh ;movq [edi],rmmx5
sub edi,8
sub esi,8
jmp jmp1
js__:
add esi,8
add edi,8
add ecx,8
rep movsb
m1__:
;rd2
;rd1

cld
mov edi,esi
inc edi
mov eax,ebx
inc eax
p eax
stosw
;
p edi
dec eax
mov ecx,eax
shl eax,2
add eax,hpart
xchg edi,eax
dec eax
dec eax
cmp [edi],0
jne ne
stosd
std
scasd
ne:
std
scasd
mov esi,edi
ll1:
lodsd
or eax,eax
jz nx_
add eax,11+1
nx_:
stosd
loop ll1
cld
pop edi
mov dum1,edi
inc edi
inc edi
mov eax,dic_top
stosd
p eax
mov eax,nzakodir
inc eax
inc eax
stosd
pop eax
mov edi,eax
pop eax
stosw
mov ecx,eax
db  0fh,7eh,0ceh ;movd esi,rmmx1
cmp max_str,ecx
jae jaem
mov max_str,ecx
jaem:
dec ecx
rep movsb
mov dx,tag ;add+rol
;eax=new_len
;int 3
mov ecx,eax
xor eax,eax
lodsb 
stosb
test ecx,1
jnz ecx0
shl eax,8
ecx0:
add ax,dx
mov dic_top,edi
mov edi,dum1
rol ax,1
stosw
pop esi
;
inc esi
db 0fh,6eh,0ceh ;movd rmmx1,esi
;обновили cur_buf
mov eax,fin_edi
sub eax,esi
jz full_exit
js full_exit
cmp eax,max_str
jae oke
;
mov max_str,eax
oke:
dec esi
pop ebp
mov edi,ebp
mov eax,num_frase
mov edx,nzakodir
db 0Fh,0BDh,0CAh ;bsr ecx,edx
shr ecx,3
or ecx,ecx
je noecx
;
noecx:
inc nzakodir
wr_n:
stosb
ror eax,8
dec ecx
jns wr_n
movsb
;int 3
mov ebp,edi
;rd2
jmp fnd

full_exit:
mov fex,1
jmp oke

fndex_1:
;rd2
mov edi,dics_top
xor eax,eax
inc eax
p eax
stosw
mov dum1,edi
inc edi
inc edi
mov ecx,eax
mov edx,dic_top
mov eax,edx
stosd
mov eax,nzakodir
add eax,2
inc nzakodir
stosd ;num_frase
mov dics_top,edi
pop eax
mov edi,edx
stosw ;len_dic
xor eax,eax
db  0fh,7eh,0ceh ;movd esi,rmmx1
lodsb
db 0fh,6eh,0ceh ;movd rmmx1,esi
stosb
mov dic_top,edi
mov edi,dum1
p eax
rol ax,1
stosw 	;SUM_db
pop eax
pop edi ;=ebp_old=hmem
mov ah,al
mov al,1
mov edx,nzakodir
db 0Fh,0BDh,0CAh ;bsr ecx,edx
shr ecx,3
jss2:
stosb
dec ecx
js jss
xor al,al
jmp jss2
jss:
mov al,ah
stosb
mov ebp,edi
mov eax,fin_edi
sub eax,esi
jns jns1
mov fex,1
jns1:
jnz io
mov fex,1
jmp oke2
io:
cmp eax,max_str
jae oke2
;
mov max_str,eax
oke2:
jmp fnd


exlz:
p0
p of f1
sub ebp,hmem
p ebp ;sz
p hmem
p hfd
extrn WriteFile:proc
call WriteFile
ret
;;;;;;;;;;;
unpack:   ;0ffffh of frases
p len_win
pop window
mov edi,hmem
mov edx,hdic
mov ebp,edx
xor ebx,ebx ;счетчик кодов
ubk0:
dec ebx
ubk1:
xor eax,eax
inc ebx
mov ecx,4
p ebx
u4:
lodsb
shr ebx,8
or ebx,ebx
jz u3
int 3
ror eax,8
dec ecx
jmp u4
u3:
pop ebx
shl ecx,3
ror eax,cl
dec eax
jns u1
;exit
ret
u1:
jnz u2
inc eax
xchg edi,ebp
stosw
lodsb
stosb
xchg edi,ebp
stosb
jmp ubk2
u2:
p eax
lodsb
mov s,al
pop ecx
p esi
mov esi,edx
xor eax,eax
u6:
lodsw
dec ecx
jz u5
add esi,eax
jmp u6
u5:
mov ecx,eax
p edi
p ecx
mov edi,ebp
inc eax
stosw
mov al,s
p edi
rep movsb
stosb
pop esi
mov ebp,edi
pop ecx
pop edi
inc ecx
rep movsb
pop esi
ubk2:
;int 3
mov ecx,ebp
add ecx,window
inc ecx
inc ecx
sub ecx,hdic
cmp ecx,SZ_DIC
jb ubk1
mov ebp,hdic
pusha
mov edi,edx
shr ecx,5
inc ecx
call cls
popa
xor ebx,ebx
jmp ubk0

cls:
movq [edi],rmmx4
movq [edi+8],rmmx4
movq [edi+8*2],rmmx4
movq [edi+8*3],rmmx4
add edi,32
dec ecx
jnz cls
;int 3
mov nzakodir,0
ret

end m1




