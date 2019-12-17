@echo off
rem
rem   BUILD_LIB [-dbg]
rem
rem   Build the CHESS library.
rem
setlocal
call build_pasinit

call src_insall %srcdir% %libname%

call src_pas %srcdir% %libname%_cover %1
call src_pas %srcdir% %libname%_cover_list %1
call src_pas %srcdir% %libname%_eval %1
call src_pas %srcdir% %libname%_eval_priv %1
call src_pas %srcdir% %libname%_move %1
call src_pas %srcdir% %libname%_name %1
call src_pas %srcdir% %libname%_read %1

call src_lib %srcdir% %libname%
call src_msg %srcdir% %libname%
