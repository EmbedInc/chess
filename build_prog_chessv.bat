@echo off
rem   BUILD_PROG_CHESSV [-dbg]
rem
rem   Build the CHESSV program.
rem
setlocal
call build_pasinit
set prog=chessv

rem
rem   Build the library.
rem
call src_pas %srcdir% %prog%_drag %1
call src_pas %srcdir% %prog%_hist %1
call src_pas %srcdir% %prog%_init %1
call src_pas %srcdir% %prog%_makewins %1
call src_pas %srcdir% %prog%_mmenu %1
call src_pas %srcdir% %prog%_mmenu_action %1
call src_pas %srcdir% %prog%_mmenu_file %1
call src_pas %srcdir% %prog%_mmenu_mveval %1
call src_pas %srcdir% %prog%_mmenu_plrs %1
call src_pas %srcdir% %prog%_mmenu_view %1
call src_pas %srcdir% %prog%_move_client %1
call src_pas %srcdir% %prog%_move_comp %1
call src_pas %srcdir% %prog%_move_server %1
call src_pas %srcdir% %prog%_move_user %1
call src_pas %srcdir% %prog%_piece_draw %1
call src_pas %srcdir% %prog%_resize %1
call src_pas %srcdir% %prog%_run %1
call src_pas %srcdir% %prog%_util %1
call src_pas %srcdir% %prog%_win_board %1
call src_pas %srcdir% %prog%_win_info %1
call src_pas %srcdir% %prog%_win_play %1
call src_pas %srcdir% %prog%_win_root %1
call src_pas %srcdir% %prog%_win_stat %1

call src_lib %srcdir% %prog%_prog private
rem
rem   Compile the top level module.
rem
call src_pas %srcdir% %prog% %1
rem
rem   Build the executable.
rem
set dbg=
if "%1"=="-dbg" set dbg=/debug
call src_link %prog% %prog% %dbg% %prog%_prog.lib
set dbg=

set private=
if "%1"=="-dbg" set private=private
call src_exeput %prog% %private%
