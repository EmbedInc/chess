module chessv_win_stat;
define chessv_win_stat_init;
define chessv_stat_msg;
define chessv_stat_str;
%include 'chessv2.ins.pas';

var
  statm: string_var132_t;              {message to display in the window}
{
*************************************************************************
*
*   Subroutine CHESSV_STAT_STR (STR)
*
*   Set the string STR to be displayed in the status window.
}
procedure chessv_stat_str (            {set string to display in status window}
  in      str: univ string_var_arg_t); {string to be displayed}
  val_param;

begin
  string_copy (str, statm);            {save new status string}
  gui_win_draw_all (win_stat);         {redraw the status window with the new string}
  end;
{
*************************************************************************
*
*   Subroutine CHESSV_STAT_MSG (SUBSYS, MSG, PARMS, N_PARMS)
*
*   Display the string derived from the message in the status windows.
}
procedure chessv_stat_msg (            {set status string from a message}
  in      subsys: string;              {name of subsystem, used to find message file}
  in      msg: string;                 {message name withing subsystem file}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t); {number of parameters in PARMS}
  val_param;

begin
  string_f_message (statm, subsys, msg, parms, n_parms);
  gui_win_draw_all (win_stat);         {redraw the status window with the new string}
  end;
{
*************************************************************************
*
*   Subroutine CHESSV_WIN_STAT_DRAW (WIN, APP_P)
}
procedure chessv_win_stat_draw (       {drawing routine for status bar window}
  in out  win: gui_win_t;              {window to draw}
  in      app_p: univ_ptr);            {pointer to arbitrary application data}
  val_param; internal;

begin
  rend_set.rgb^ (0.8, 0.8, 0.3);       {clear to background color}
  rend_prim.clear_cwind^;

  rend_set.rgb^ (0.0, 0.0, 0.0);       {draw the message string}
  tparm.start_org := rend_torg_ml_k;
  rend_set.text_parms^ (tparm);
  rend_set.cpnt_2d^ (twide * 0.70, win.rect.dy / 2.0);
  rend_prim.text^ (statm.str, statm.len);
  end;
{
*************************************************************************
*
*   Subroutine CHESSV_WIN_STAT_INIT
*
*   Initialize the contents of the status bar window, WIN_STAT.  The
*   window has already been created.
}
procedure chessv_win_stat_init;        {init contents of status bar window}

begin
  statm.max := size_char(statm.str);   {init static var string}

  statm.len := 0;                      {init status message to empty}

  gui_win_set_draw (                   {set drawing routine for this window}
    win_stat, univ_ptr(addr(chessv_win_stat_draw)));
  end;
