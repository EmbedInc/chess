/*   Private message file for the CHESSV program.
/*

/*
/*   Status messages related to CHESSV subsystem status codes.
/*
msg err1
  lan english -def
    Error on attempt to parse command name from line %p2i of file
    %p1s.
msg err2
  lan english -def
    Bad command parameter encountered on
    line %p2i of file %p1s.
msg err3
  lan english -def
    Unrecognized command "%p1s" encountered on
    line %p3i of file %p2s.
msg err4
  lan english -def
    Too many command parameters encountered on
    line %p2i of file %p1s.
/*
/*   Error and related messages.
/*
msg err_high_fp
  lan english -def
    Value too high, try again.  The maximum allowed value is %p1f.
msg err_high_int
  lan english -def
    Value too high, try again.  The maximum allowed value is %p1i.
msg err_low_fp
  lan english -def
    Value too low, try again.  The minimum allowed value is %p1f.
msg err_low_int
  lan english -def
    Value too low, try again.  The minimum allowed value is %p1i.
msg err_read_pos_file
  lan english -def
    Error occurred on attempt to read new chess position from the file "%p1s".
msg err_write_pos_file
  lan english -def
    Error occurred on attempt to write the current chess position into
    the file "%p1s".
msg err_thread_comp
  lan english -def
    Error occurred on attempt to launch worker thread to compute the next
    move.
/*
/*   INFO window messages.
/*
msg info_nmoves_time
  lan english -def
    %p1i moves examined in %p2f9.2 minutes:
/*
/*   Messages used for display in the status window.
/*
msg stat_move_bad
  lan english -def
    Illegal move.
msg stat_move_end
  lan english -def
    Release the mouse button on the square to move the piece to.
msg stat_move_opp
  lan english -def
    You can not move your opponent's pieces.
msg stat_move_comp_black
  lan english -def
    Please wait while the computer makes a move for black.
msg stat_move_comp_white
  lan english -def
    Please wait while the computer makes a move for white.
msg stat_move_user_black
  lan english -def
    Please move a black piece.
msg stat_move_user_white
  lan english -def
    Please move a white piece.
msg stat_not_umove
  lan english -def
    It is not your move.
msg stat_off_board
  lan english -def
    The selected location is not on the chess board.
msg stat_promote
  lan english -def
    Select what type of piece to promote the pawn to.
msg stat_restart
  lan english -def
    Play is suspended, hit ENTER to restart.
msg stat_sqempty
  lan english -def
    There is nothing to move.  The selected chess square is empty.
msg stat_stalemate
  lan english -def
    The game has ended in stalemate.
msg stat_won_black
  lan english -def
    Black has won the game.
msg stat_won_white
  lan english -def
    White has won the game.
/*
/*   Messages to prompt the user to enter various information.
/*
msg enter_fnam_load
  lan english -def
    Enter the pathname of the file to load a new chess position from:
msg enter_fnam_saveas
  lan english -def
    Enter the pathname of the file to save the current chess position
    into:
msg enter_move_eval_parm
  lan english -def
    Enter a new value for the move evaluator parameter "%p1s":
/*
/*   Messages for supplying names for menu entries.  The format of these
/*   messages is dictated by the GUI_MSG_MENU_xxx routines.  These messages
/*   are expected to expand into one menu entry per line.  The .NFILL command
/*   must therefore be used at the start of each message to prevent line
/*   wrapping.  Each line read from the message must have the format:
/*
/*     <ID> <name> [<shortcut index>]
/*
/*   ID is the internal number used to identify this menu entry.  Menu
/*   entries are not identified by their position, but only by this ID.
/*   Therefore, the order of menu entries can be re-arranged, and the
/*   program will function normally as long as the IDs are rearranged
/*   along with the entries.
/*
/*   NAME is the menu entry name to display to the user.  This is
/*   parsed as one token, so must be enclosed in quotes ("") or apostrophies
/*   ('') if it contains special characters, like spaces.
/*
/*   SHORTCUT INDEX is the character index into NAME for the shortcut
/*   character for this entry.  The shortcut character is typically
/*   underlined so that the user knows pressing that key will select
/*   that menu entry.  The index of the first character is 1.  The menu
/*   entry will have no shortcut key if this parameter is omitted or
/*   explicitly set to 0.  Note that SHORTCUT INDEX is the index into
/*   NAME as parsed.  This means enclosing quotes aren't counted, since
/*   they are not part of the name displayed to the user.
/*
/*   For example:
/*
/*     3 "Close File" 2
/*
/*   The menu entry will be displayed as:
/*
/*     Close File
/*
/*   with the "l" in "Close" being the shortcut character for this entry.  The
/*   internal program ID for this entry is 3.
/*
msg menu_main
  lan english -def
    .nfill
    0 Exit 2
    1 File 1
    2 View 1
    3 Players 1
    4 Action 1
    5 "Move eval" 6
msg menu_file
  lan english -def
    .nfill
    0 "Save as ..." 6
    1 "Load from ..." 1
    2 "Delete ..." 1
msg menu_view
  lan english -def
    .nfill
    0 "From white side" 6
    1 "From black side" 6
    2 "Moves history (^H)" 7
    3 "Computer move evaluations (^E)" 15
msg menu_players
  lan english -def
    .nfill
    0 "White ..." 1
    1 "Black ..." 1
msg menu_action
  lan english -def
    .nfill
    0 "Play" 2
    1 "Pause (^P)" 1
    2 "Edit" 1
    3 "Restart" 4
    4 "Reset" 1
msg menu_playtype
  lan english -def
    .nfill
    0 User 1
    1 Computer 1
    2 Server 1
    3 Client 2
msg menu_promote
  lan english -def
    .nfill
    0 Queen 1
    1 Rook 1
    2 Bishop 1
    3 Knight 2
