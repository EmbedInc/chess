module chessv_run;
define chessv_run;
%include 'chessv2.ins.pas';
{
*************************************************************************
*
*   Subroutine CHESSV_RUN
*
*   This is the program main routine after all one-time initialization has
*   been performed.
}
procedure chessv_run;                  {run program after one-time initialization}

var
  ev: rend_event_t;                    {one RENDlib event}
  player: player_k_t;                  {ID of player to make next move}
  st: chess_move_t;                    {legal move generator state}
  pos2: chess_pos_t;                   {position after move}
  hent_p: hist_ent_p_t;                {pointer to history list entry}
  i: sys_int_machine_t;                {scratch integer and loop counter}
  other: boolean;                      {WHITE flag for non-moving player}

label
  redraw, loop_event, new_player, do_move, done_event, leave;

begin
redraw:
  gui_win_draw_all (win_root);         {explicitly draw everything}

loop_event:                            {back here to handle the next RENDlib event}
  discard( gui_win_evhan (win_root, true) ); {handle all window events possible}
  rend_event_get (ev);                 {get the next event}
  case ev.ev_type of                   {what kind of event is this ?}
{
**********
*
*   The drawing device has been closed.
}
rend_ev_close_k: begin                 {drawing device has been closed}
  goto leave;
  end;
{
**********
*
*   The user has requested that the drawing device be closed.
}
rend_ev_close_user_k: begin            {user wants to close device}
  goto leave;
  end;
{
**********
*
*   A rectangle of pixels was wiped out and can now be re-drawn.
}
rend_ev_wiped_rect_k: begin            {rectangular region needs redraw}
  gui_win_draw (                       {redraw a region}
    win_root,                          {window to draw}
    ev.wiped_rect.x,                   {left X}
    ev.wiped_rect.x + ev.wiped_rect.dx, {right X}
    win_root.rect.dy - ev.wiped_rect.y - ev.wiped_rect.dy, {bottom Y}
    win_root.rect.dy - ev.wiped_rect.y); {top Y}
  end;
{
**********
*
*   The size of the drawing device has changed.
}
rend_ev_wiped_resize_k: begin          {drawing device size changed}
  chessv_resize;                       {adjust to new drawing area size}
  goto redraw;                         {redraw everything with new size}
  end;
{
**********
*
*   Private application event.  Some other part of this program deliberately
*   created this event.
}
rend_ev_app_k: begin
  case evtype_k_t(ev.app.i1) of        {which private event is this ?}
{
*****
*
*   It is now white's move.
}
evtype_move_white_k: begin             {it is now white's move}
  whmove := true;
  player := playerw;
  goto new_player;
  end;
{
*****
*
*   It is now black's move.
}
evtype_move_black_k: begin             {it is now black's move}
  whmove := false;
  player := playerb;
{
*   It is a new player's turn.  WHMOVE has been updated.
*   PLAYER is set to the player ID of the player who's move it is now.
}
new_player:
  chessv_hist_add;                     {add current position to the history list}
  goto do_move;
  end;
{
*****
*
*   Have the current player do a move.
}
evtype_move_k: begin
  if whmove
    then player := playerw
    else player := playerb;
{
*   The board position, WHMOVE and the local variable PLAYER are all set.
*   Now have this player do a move or update message to the user as appropriate.
}
do_move:                               {jump here from explicit white/black move}
  umove := false;                      {init to the user is not moving now}
  if                                   {automatically switch to PLAY mode ?}
      (player = player_user_k) and     {move coming from the user interactively ?}
      (mode = mode_pause_k)            {in PAUSE mode ?}
      then begin
    mode := mode_play_k;               {silently switch to PLAY mode}
    end;

  case mode of                         {what is overall program mode ?}
mode_play_k: ;                         {actively playing the game}
mode_pause_k: begin                    {the game is paused}
      chessv_stat_msg ('chessv_prog', 'stat_restart', nil, 0);
      goto done_event;
      end;
otherwise                              {any other overall program mode}
    goto done_event;                   {there is no "move" to make}
    end;
{
*   Handle the case where the new player has no legal moves.  This means
*   the game is over with a stalemate or the new player loosing, depending
*   on whether the new player's king is in check.
}
  chess_move_init (addr(pos), whmove, st); {init move generator}
  if not chess_move (st, pos2) then begin {new player has no legal moves ?}
    other := not whmove;
    if chess_cover(pos, st.kx, st.ky, other) then begin {moving king is in check ?}
      if whmove
        then chessv_stat_msg ('chessv_prog', 'stat_won_black', nil, 0)
        else chessv_stat_msg ('chessv_prog', 'stat_won_white', nil, 0);
      goto loop_event;
      end;
    chessv_stat_msg ('chessv_prog', 'stat_stalemate', nil, 0);
    goto loop_event;
    end;
{
*   Check for stalemate due to no change in the set of pieces for 50 moves.
}
  if hist_p^.pos.nsame >= 50 then begin
    chessv_stat_msg ('chessv_prog', 'stat_stalemate', nil, 0);
    goto loop_event;
    end;
{
*   Check for stalemate due to the same position occurring 3 times.
}
  i := 1;                              {init number of times this position occurred}
  hent_p := hist_p^.prev_p;            {init to previous move in history list}
  while hent_p <> nil do begin         {loop until start of history list}
    if chessv_pos_same (pos, hent_p^.pos) then begin {same position as now ?}
      i := i + 1;                      {count one more repetition of this position}
      if i >= 3 then begin             {stalemate due to repeating position ?}
        chessv_stat_msg ('chessv_prog', 'stat_stalemate', nil, 0);
        goto loop_event;
        end;
      end;
    hent_p := hent_p^.prev_p;          {go one more move back}
    end;                               {back to check this new move}
{
*   Have the new player make his move.
}
  case player of                       {where are player's moves coming from ?}
player_user_k: begin                   {user is moving for this player}
      chessv_move_user;
      end;
player_comp_k: begin                   {computer is moving for this player}
      chessv_move_comp;
      end;
player_server_k: begin                 {moves come from client to our server}
      chessv_move_server;
      end;
player_client_k: begin                 {moves come from server we are client to}
      chessv_move_client;
      end;
    end;
  end;                                 {end of do move event case}
{
*****
*
*   There is a new chess position in POS.
}
evtype_new_pos_k: begin                {there is a new position in POS}
  gui_win_draw_all (win_play);         {redraw the play area}
  end;
{
*****
*
*   The list of contemplated moves has changed.
}
evtype_new_lmoves_k: begin
  if info_disp = info_compeval_k then begin {displaying move evaluations ?}
    gui_win_draw_all (win_info);
    end;
  end;
{
*****
*
*   The history list has changed.
}
evtype_new_hist_k: begin
  if info_disp = info_hist_k then begin {displaying the history list ?}
    gui_win_draw_all (win_info);
    end;
  end;
{
*****
*
*   HIST_P has been changed and now points to a different history list
*   entry.
}
evtype_hist_k: begin
  chessv_hist_get;                     {get board position from new hist list entry}
  if info_disp = info_hist_k then begin {displaying the history list ?}
    gui_win_draw_all (win_info);
    end;
  case mode of                         {what is current program mode ?}
mode_play_k: begin                     {actively playing the game}
      chessv_setmode (mode_pause_k);   {pause the game at this new position}
      end;
    end;
  chessv_event_move;                   {have curr player make move if appropriate}
  end;
{
*****
}
    end;                               {end of application event type cases}
  end;                                 {end of application event case}
{
**********
*
*   All other events are discarded.
}
    end;                               {end of event type cases}
done_event:                            {all done handling this event}
  goto loop_event;                     {back and wait for next event}

leave:
  chess_eval_close (eval);             {close this use of the move evaluator}
  gui_win_delete (win_root);           {deallocate all GUI resources}
  rend_end;                            {shut down RENDlib}
  end;
