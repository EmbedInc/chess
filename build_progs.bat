@echo off
rem
rem   BUILD_PROGS [-dbg]
rem
rem   Build the executable programs from this source directory.
rem
setlocal
call build_pasinit
call src_prog %srcdir% chess %1
call src_prog %srcdir% test_chpos %1
endlocal

call build_prog_chessv
