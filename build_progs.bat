@echo off
rem
rem   BUILD_PROGS [-dbg]
rem
rem   Build the executable programs from this source directory.
rem
setlocal
call build_pasinit
call src_prog %srcdir% chess
call src_progl chessv
call src_progl test_chpos
endlocal
