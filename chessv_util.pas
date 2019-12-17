module chessv_util;
define roundown;
define chessv_pos_start;
define chessv_event_hist;
define chessv_event_lmoves;
define chessv_event_move;
define chessv_event_newhist;
define chessv_event_newpos;
define chessv_event_nextmove;
define chessv_lmove_set;
define chessv_pos_same;
define chessv_setmode;
%include 'chessv2.ins.pas';
{
********************************************************************************
*
*   Function ROUNDOWN (F)
*
*   Returns the first integer that is equal to or less than F.
}
function roundown (                    {round to integer toward minus infinity}
  in      f: real)                     {input value to round}
  :sys_int_machine_t;                  {returned integer}
  val_param;

var
  i: sys_int_machine_t;

begin
  if f >= 0.0
    then begin                         {positive}
      roundown := trunc(f);
      end
    else begin                         {negative}
      i := -trunc(f)  + 1;
      roundown := trunc(f + i) - i;
      end
    ;
  end;
{
********************************************************************************
*
*   Subroutine CHESSV_POS_START (POS)
*
*   Set POS to the starting chess position.
}
procedure chessv_pos_start (           {create starting chess position}
  out     pos: chess_pos_t);           {chess position to initialize}
  val_param;

var
  x, y: sys_int_machine_t;             {chess square coordinate}

begin
  for y := 0 to 7 do begin             {init all flags}
    for x := 0 to 7 do begin
      pos.sq[y, x].flags := [chess_sqrflg_orig_k];
      end;
    end;

  pos.sq[0, 0].piece := chess_sqr_wrook_k; {white's back row}
  pos.sq[0, 1].piece := chess_sqr_wknight_k;
  pos.sq[0, 2].piece := chess_sqr_wbishop_k;
  pos.sq[0, 3].piece := chess_sqr_wqueen_k;
  pos.sq[0, 4].piece := chess_sqr_wking_k;
  pos.sq[0, 5].piece := chess_sqr_wbishop_k;
  pos.sq[0, 6].piece := chess_sqr_wknight_k;
  pos.sq[0, 7].piece := chess_sqr_wrook_k;

  for x := 0 to 7 do begin             {white's pawns}
    pos.sq[1, x].piece := chess_sqr_wpawn_k;
    end;

  for y := 2 to 5 do begin             {empty space in the middle}
    for x := 0 to 7 do begin
      pos.sq[y, x].piece := chess_sqr_empty_k;
      pos.sq[y, x].flags := [];
      end;
    end;

  for x := 0 to 7 do begin             {black's pawns}
    pos.sq[6, x].piece := chess_sqr_bpawn_k;
    end;

  pos.sq[7, 0].piece := chess_sqr_brook_k; {black's back row}
  pos.sq[7, 1].piece := chess_sqr_bknight_k;
  pos.sq[7, 2].piece := chess_sqr_bbishop_k;
  pos.sq[7, 3].piece := chess_sqr_bqueen_k;
  pos.sq[7, 4].piece := chess_sqr_bking_k;
  pos.sq[7, 5].piece := chess_sqr_bbishop_k;
  pos.sq[7, 6].piece := chess_sqr_bknight_k;
  pos.sq[7, 7].piece := chess_sqr_brook_k;

  pos.prev_p := nil;                   {no previous position in the game}
  pos.nsame := 1;                      {first position with this set of pieces}
  end;
{
********************************************************************************
*
*   Subroutine CHESSV_EVENT_NEWPOS
*
*   Push an event to the head of the queue that indicates the chess position
*   in POS has changed.
}
procedure chessv_event_newpos;         {generate event for new chess position}
  val_param;

var
  ev: rend_event_t;                    {one RENDlib event}

begin
  if rendev =  rend_dev_none_k then return; {RENDlib not yet started ?}
  ev.dev := rendev;                    {fill in event descriptor}
  ev.ev_type := rend_ev_app_k;
  ev.app.i1 := ord(evtype_new_pos_k);
  rend_event_push (ev);                {put event onto queue}
  end;
{
********************************************************************************
*
*   Subroutine CHESSV_EVENT_NEWMOVE
*
*   Push an event to the head of the queue that causes it to be the other
*   player's move from the one currently moving.
}
procedure chessv_event_newmove;        {generate event for other player's move}
  val_param;

var
  ev: rend_event_t;                    {one RENDlib event}

begin
  if rendev =  rend_dev_none_k then return; {RENDlib not yet started ?}
  ev.dev := rendev;                    {fill in event descriptor}
  ev.ev_type := rend_ev_app_k;
  if whmove
    then ev.app.i1 := ord(evtype_move_black_k)
    else ev.app.i1 := ord(evtype_move_white_k);
  rend_event_push (ev);                {put event onto queue}
  end;
{
********************************************************************************
*
*   Subroutine CHESSV_EVENT_NEXTMOVE
*
*   This routine generates all the necessary events in the proper order for
*   when done with a move and it is now the other player's turn.
*
*   Note that events must be  pushed onto the head of the queue in the
*   reverse order they should be processed.
}
procedure chessv_event_nextmove;       {generate events for done with curr move}
  val_param;

begin
  chessv_event_newmove;                {indicate switch move to other opponent}
  chessv_event_newpos;                 {indicate board position has changed}
  end;
{
********************************************************************************
*
*   Subroutine CHESSV_EVENT_HIST
*
*   Generate event to indicate that HIST_P has been changed to point to
*   a different history list entry.  The current state must be updated
*   to that saved in the new history list entry.
}
procedure chessv_event_hist;           {generate event for at new history entry}

var
  ev: rend_event_t;                    {one RENDlib event}

begin
  if rendev =  rend_dev_none_k then return; {RENDlib not yet started ?}
  ev.dev := rendev;                    {fill in event descriptor}
  ev.ev_type := rend_ev_app_k;
  ev.app.i1 := ord(evtype_hist_k);
  rend_event_push (ev);                {put event onto queue}
  end;
{
********************************************************************************
*
*   Subroutine CHESSV_EVENT_LMOVES
*
*   Generate an event to indicate that the list of computer generated
*   moves has changed.
}
procedure chessv_event_lmoves;         {generate event for new computer moves list}

var
  ev: rend_event_t;                    {one RENDlib event}

begin
  if rendev =  rend_dev_none_k then return; {RENDlib not yet started ?}
  ev.dev := rendev;                    {fill in event descriptor}
  ev.ev_type := rend_ev_app_k;
  ev.app.i1 := ord(evtype_new_lmoves_k);
  rend_event_push (ev);                {put event onto queue}
  end;
{
********************************************************************************
*
*   Subroutine CHESSV_EVENT_MOVE
*
*   Generate an event that will cause the current player to make a move,
*   if appropriate given the current mode and other state.
}
procedure chessv_event_move;           {generate event for curr player to make move}

var
  ev: rend_event_t;                    {one RENDlib event}

begin
  if rendev =  rend_dev_none_k then return; {RENDlib not yet started ?}
  ev.dev := rendev;                    {fill in event descriptor}
  ev.ev_type := rend_ev_app_k;
  ev.app.i1 := ord(evtype_move_k);
  rend_event_push (ev);                {put event onto queue}
  end;
{
********************************************************************************
*
*   Subroutine CHESSV_EVENT_NEWHIST
*
*   Generate an event to indicate that the history list has changed.
}
procedure chessv_event_newhist;        {generate event for change history list}

var
  ev: rend_event_t;                    {one RENDlib event}

begin
  if rendev =  rend_dev_none_k then return; {RENDlib not yet started ?}
  ev.dev := rendev;                    {fill in event descriptor}
  ev.ev_type := rend_ev_app_k;
  ev.app.i1 := ord(evtype_new_hist_k);
  rend_event_push (ev);                {put event onto queue}
  end;
{
********************************************************************************
*
*   Function CHESSV_POS_SAME (POS1, POS2)
*
*   Returns TRUE if both the board positions have the same pieces in the
*   same locations.
}
function chessv_pos_same (             {check board positions for same pieces}
  in      pos1, pos2: chess_pos_t)     {board positions to compare}
  :boolean;                            {TRUE if same pieces in same locations}
  val_param;

var
  x, y: sys_int_machine_t;             {board square coordinate}

begin
  chessv_pos_same := false;            {init to positions are not the same}

  for y := 0 to 7 do begin             {up the rows}
    for x := 0 to 7 do begin           {accross this row}
      if pos2.sq[y, x].piece <> pos1.sq[y, x].piece then return; {found discrepancy ?}
      end;
    end;

  chessv_pos_same := true;             {positions match}
  end;
{
********************************************************************************
*
*   Subroutine CHESSV_SETMODE (NEWMODE)
*
*   Set the overall program operating mode to NEWMODE.  Nothing is done if
*   the mode is already set this way.
}
procedure chessv_setmode (             {set new overall program mode}
  in      newmode: mode_k_t);          {new mode to set to}
  val_param;

begin
  if newmode = mode then return;       {already set this way, nothing to do ?}

  mode := newmode;                     {set to the new program mode}

  case mode of                         {what is new program mode ?}
mode_pause_k: begin
      chessv_stat_msg ('chessv_prog', 'stat_restart', nil, 0);
      end;
mode_play_k: begin
      chessv_event_move;               {have curr player make a move}
      end;
otherwise
    chessv_stat_str (string_v(''(0)));
    end;
  end;
