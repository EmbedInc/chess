{   Program CHESSV
*
*   This module performs all the one-time program initialization, then passes
*   control to CHESSV_RUN.
}
program "gui" chessv;
%include 'chessv2.ins.pas';

var
  i: sys_int_machine_t;                {scratch integer and loop counter}
  stat: sys_err_t;                     {completion status code}

begin
  math_rand_init_clock (rand);         {init random number generator from sys clock}
  mem_p := nil;                        {indicate memory context not created yet}
  rendev := rend_dev_none_k;           {no RENDlib device yet}
{
*   Initialize the chess state.
}
  chessv_pos_start (pos);              {init to the game starting position}

  view_white := true;                  {init to view board from white's side}
  move_fx := 0;
  move_fy := 0;
  move_tx := 0;
  move_ty := 0;
  for i := 1 to maxmoves_k do begin    {once for each array element}
    lmoves[i].name.max := size_char(lmoves[i].name.str); {init var string}
    end;
  nlmove := 0;                         {empty list of contemplated moves}
  playerw := player_user_k;            {the user is playing white}
  playerb := player_comp_k;            {the computer is playing black}
  mode := mode_play_k;                 {init overall program mode}
  info_disp := info_hist_k;            {init to display history list in info window}
  lastmove := false;                   {init to no last move info available}
  whmove := false;                     {init to it is black's move}
  umove := false;                      {init to not user's move}
  hist_start_p := nil;                 {init history list to empty}
  hist_p := nil;
  util_mem_context_get (               {create history list memory context}
    util_top_mem_context, mem_hist_p);

  chess_eval_init (eval, stat);        {init move evaluator}
  sys_error_abort (stat, '', '', nil, 0);
{
*   Set up specific state for debugging.
}


{
*   Initialize the graphics and windows state.
}
  chessv_init;                         {do one-time graphics and window init}
  chessv_resize;                       {adjust to drawing area size}

  chessv_event_newmove;                {it is now other player's turn to move}

  chessv_run;                          {operate the program}
  end.
