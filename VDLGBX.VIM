if(!exists("*s:RunTest"))

let s:Lnum=0

:function! s:ADD(Text)
let s:Lnum=s:Lnum+1
call append(s:Lnum,a:Text)
endfun

:function! s:RunTest()
let Param=
      \"$E:testfil:Please enter the name of an (empty) testfile=TESTBOX.TXT\n"
let Z1=libcall("VDLGBX","BOX",Param)
exec Z1
if(VDLGBXRETURN!="OK")
  return
endif
exec ":n " . VDLGBX_testfil
" The parameter is a chain of "\n"-terminated statements
" The general format is:
" $x:name:label=content\n
" where:
"  x is the kind of the dialogelement (see below)
"  name is the suffix of the returned VDLGBX_var
"  label (optional) is the prompt (default: the name)
"  content is default-text, listbox-entries etc. depending on x (see below)
let Param="$E:SomeInput=\"Foo\"\n" . 
      \"$E:a2:Some arbitrary text=\\Bar\\\n" 
"$E:name:Label=Default
" Enter an arbitrary text. Note the resulting quoting of " and \ !
let Param=Param."$S:q1:Deactivate this switch=1\n" .
      \"$S:q2:Activate this switch=0\n" 
"$S:name:Label=Default
" A switch. Any default not equal to 0 does pre-activate. Returns 0 or 1
let Param=Param."$L:List1:Choose one=/1=Eins/22=Zwei/_333=Drei/4444=Vier/Viel=Und noch mehr/\n" 
"$L:name:Label=/ret1=choose1/_default/../choosex/
" A Listbox with predefined, unchangeable entries. You con preselect an entry
" by "_" and translate your return by "="
let Param=Param."$C:List2:Choose or enter something other=/AAA/_BBB/CCC/DDD/EEE/\n"
"$C:name:Label=/text1/_default2/../Textn/
" A Combobox with predefined and preselectable entries, but you cannot
" translate the return and the user can enter arbitrary text.
let Z1=libcall("VDLGBX","BOX",Param)
" Z1 contains a executable chain of "let VDLGBX_xxx=yyy".
" The first statement ever is "let VDLGBXRETURN=xxx", where xxx is "OK",
" "CANCEL" or a error-message.
" The following "exec" makes the values available to you
exec Z1
" echo Z1
if(VDLGBXRETURN!="OK")
  echo VDLGBXRETURN
  return
endif
call s:ADD("--- VDLGBX-String ---")
while(Z1!="")
  " Must cut Z1 at each "\n" because append cannot handle strings with "\n" in
  let i1=stridx(Z1,"\n")
  if(i1>=0)
    call s:ADD(strpart(Z1,0,i1))
    let Z1=strpart(Z1,i1+1)
  else
    call s:ADD(Z1)
    let Z1=""
  endif
endwhile
call s:ADD("")
call s:ADD("*** The Results ***")
call s:ADD("The 1st string was: ".VDLGBX_SomeInput)
call s:ADD("The 2nd string was: ".VDLGBX_a2)
call s:ADD("The switche were: ".VDLGBX_q1." and ".VDLGBX_q2)
call s:ADD("The 1st choosing: ".VDLGBX_List1)
call s:ADD("The 2nd choosing: ".VDLGBX_List2)

" Now the goodies...
" !TITLE=new title of the dialogbox
" !FONT="fontname",points   
" !PREF=prefix    replaces l:VDLGBX_ (usefull if you want to have some sets of
" entered values)
let Param="!TITLE=Now let's rock...\n" .
      \"!FONT=\"Arial\",8\n" .
      \"!PREF=l:MYfooBAR_\n" .
      \"$E:image:Complete path to some image (GIF,JPG,PNG,BMP)=\n"
let Z1=libcall("VDLGBX","BOX",Param)
exec Z1
if(VDLGBXRETURN!="OK")
  echo VDLGBXRETURN
  return
endif
" Function IMAGE returns WIDTH and HEIGHT of GIF, JPG, PNG and BMPs
let Z2=libcall("VDLGBX","IMAGE",MYfooBAR_image)
call s:ADD("")
call s:ADD("*** And now for dealing with HTML ***")
if(strpart(Z2,0,3)!="*NO")
  call s:ADD("<IMG SRC=\"".MYfooBAR_image."\" ".Z2."/>")
else
  call s:ADD("The file \"".MYfooBAR_image."\" returned ".Z2)
endif
:endfun

:endif

call s:RunTest()
