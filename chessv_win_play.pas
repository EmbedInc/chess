module chessv_win_play;
define chessv_win_play_init;
%include 'chessv2.ins.pas';

const
  size_taken = 0.60;                   {relative size of taken pieces to regular}

type
  plist_t = record                     {list of chess pieces}
    pawn: sys_int_machine_t;           {number of pawns}
    rook: sys_int_machine_t;           {number of rooks}
    knight: sys_int_machine_t;         {number of knights}
    bishop: sys_int_machine_t;         {number of bishops}
    queen: sys_int_machine_t;          {number of queens}
    king: sys_int_machine_t;           {number of kings}
    total: sys_int_machine_t;          {total number of pieces listed}
    end;

var
  y_board1, y_board2: real;            {bot/top of raw chess board}
  x_board1, x_board2: real;            {lft/rit of raw chess board}
{
*************************************************************************
*
*   Local function CHESSV_WIN_PLAY_EVHAN (WIN, APP_P)
*
*   Handle events for the PLAY area window.
}
function chessv_win_play_evhan (       {PLAY window event handler}
  in      win: gui_win_t;              {window handling events for}
  in      app_p: univ_ptr)             {application-specific pointer, unused}
  :gui_evhan_k_t;                      {event handler completion code}
  val_param;

var
  ev: rend_event_t;                    {one RENDlib event}
  modk: rend_key_mod_t;                {set of modifier keys}
  sqx, sqy: sys_int_machine_t;         {chess square coordinate}
  stx, sty: sys_int_machine_t;         {target chess square coordinate}
  rx, ry: real;                        {scratch RENDlib 2DIM coordinate}
  ex, ey: real;                        {end of drag 2DIM coordinate}
  x, y: real;                          {scratch coordinates}
  st: chess_move_t;                    {move generator state}
  pos2: chess_pos_t;                   {chess position after move}
  tp: rend_text_parms_t;               {local copy of text control parameters}
  menu: gui_menu_t;                    {popup menu object}
  iid: sys_int_machine_t;              {integer menu entry ID}
  sel_p: gui_menent_p_t;               {pointer to selected menu entry}

label
  legal_move, notus, did_event;

begin
  rend_event_get (ev);                 {get the next event from the event queue}
  case ev.ev_type of                   {what kind of event is it ?}
{
**********
*
*   A key was pressed or released.
}
rend_ev_key_k: begin                   {a key was pressed or released}
  modk := ev.key.modk;                 {get set of modifier keys}
  modk := modk - [                     {remove modifiers that are OK}
    rend_key_mod_shiftlock_k];
  if modk <> [] then goto notus;       {punt on any other modifier keys}
  case gui_key_k_t(ev.key.key_p^.id_user) of {which key is it ?}
{
*****
*
*   ENTER.
}
gui_key_enter_k: begin
  if not ev.key.down then goto did_event; {key was released, not pressed ?}

  if mode = mode_pause_k then begin    {play is currently paused ?}
    chessv_setmode (mode_play_k);      {switch to active play mode}
    end;
  end;
{
*****
*
*   The left mouse button.
}
gui_key_mouse_left_k: begin            {left mouse key was pressed}
  if                                   {pointer coordinate outside our window ?}
      (ev.key.x < win.pos.x) or
      (ev.key.x > (win.pos.x + win.rect.dx)) or
      (ev.key.y < win.pos.y) or
      (ev.key.y > (win.pos.y + win.rect.dy))
    then goto notus;
  if not ev.key.down then goto did_event; {key was released, not pressed ?}

  if not umove then begin              {not the user's move ?}
    chessv_stat_msg ('chessv_prog', 'stat_not_umove', nil, 0);
    goto did_event;
    end;

  chessv_coor_sqr (                    {get chess square coordinate from this loc}
    ev.key.x + 0.5, ev.key.y + 0.5,    {2DIM input coordinates}
    sqx, sqy);                         {returned chess square coordinates}

  if (sqx < 0) or (sqx > 7) or (sqy < 0) or (sqy > 7) then begin {off board ?}
    chessv_stat_msg ('chessv_prog', 'stat_off_board', nil, 0);
    goto did_event;
    end;

  case pos.sq[sqy, sqx].piece of       {what is on the selected chess square ?}
chess_sqr_empty_k: begin               {empty, no piece on this square}
      chessv_stat_msg ('chessv_prog', 'stat_sqempty', nil, 0);
      goto did_event;
      end;
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k,                    {white queen}
chess_sqr_wking_k: begin               {white king}
      if not whmove then begin         {trying to move opponent's piece ?}
        chessv_stat_msg ('chessv_prog', 'stat_move_opp', nil, 0);
        goto did_event;
        end;
      end;
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k,                    {black queen}
chess_sqr_bking_k: begin               {black king}
      if whmove then begin             {trying to move opponent's piece ?}
        chessv_stat_msg ('chessv_prog', 'stat_move_opp', nil, 0);
        goto did_event;
        end;
      end;
otherwise
    goto did_event;                    {ignore event on unexpected piece ID}
    end;
{
*   The user can legally move the piece on the selected chess square, which is
*   SQX,SQY.
*
*   Drag to the target square.
}
  chessv_stat_msg ('chessv_prog', 'stat_move_end', nil, 0);

  chessv_sqr_coor (sqx, sqy, rx, ry);  {get RENDlib 2DIM coordinate of square center}
  if not chessv_drag (rx, ry, ex, ey) then begin {drag was cancelled ?}
    ev.ev_type := rend_ev_none_k;      {indicate no event for us to push back}
    goto notus;                        {event that cancelled drag was pushed back}
    end;
{
*   EX,EY is the RENDlib 2DIM coordinate where the user dragged to.
}
  chessv_coor_sqr (ex, ey, stx, sty);  {get target chess square coordinate}
  if                                   {move cancelled by dragging off the board ?}
      (stx < 0) or (stx > 7) or (sty < 0) or (sty > 7) then begin
    chessv_stat_str (string_v(''(0))); {erase status message}
    goto did_event;                    {silently cancell the move}
    end;

  chess_move_init (                    {initialize legal move generator}
    addr(pos),                         {starting board position}
    whmove,                            {TRUE if white moving, FALSE if black}
    st);                               {returned initialized move generator state}

  while chess_move (st, pos2) do begin {loop thru all the legal moves}
    if                                 {this move matches user's move ?}
        (st.x = sqx) and (st.y = sqy) and {same source square ?}
        (st.lx = stx) and (st.ly = sty) {same destination square ?}
      then goto legal_move;
    end;                               {back to check next legal move}
  chessv_stat_msg ('chessv_prog', 'stat_move_bad', nil, 0);
  goto did_event;
{
*   The user's move is a legal move.
}
legal_move:
  move_fx := sqx;                      {save move source square coordinates}
  move_fy := sqy;
  move_tx := stx;                      {save move destination square coordinates}
  move_ty := sty;
  lastmove := true;                    {there is now a last move to show}
  if                                   {piece changed, assume promoted pawn ?}
      pos2.sq[sty, stx].piece <> pos.sq[sqy, sqx].piece
      then begin
    chessv_sqr_coorp (stx, sty, x, y); {set X,Y to center ot move target square}
    x := x - dsquare * 0.5;            {make lower left corner of target square}
    y := y - dsquare * 0.5;

    tp := tparm;                       {make copy of official text control params}
    tp.lspace := 1.0;
    rend_set.text_parms^ (tp);

    chessv_stat_msg ('chessv_prog', 'stat_promote', nil, 0);

    gui_menu_create (menu, win_play);  {create menu}
    gui_menu_ent_add_mmsg (            {create menu entries from message}
      menu, 'chessv_prog', 'menu_promote', nil, 0);
    gui_menu_place (menu, x - 2, y);   {set menu location within parent window}

    if not gui_menu_select (menu, iid, sel_p) then begin {menu cancelled ?}
      chessv_stat_str (string_v(''(0))); {erase status message}
      goto did_event;                  {silently cancell the move}
      end;
    gui_menu_delete (menu);            {delete and erase the menu}
    chessv_stat_str (string_v(''(0))); {erase status message}
    if whmove
      then begin                       {white is moving}
        case iid of                    {what did the user select ?}
0:        pos2.sq[sty, stx].piece := chess_sqr_wqueen_k;
1:        pos2.sq[sty, stx].piece := chess_sqr_wrook_k;
2:        pos2.sq[sty, stx].piece := chess_sqr_wbishop_k;
3:        pos2.sq[sty, stx].piece := chess_sqr_wknight_k;
          end;
        end
      else begin                       {black is moving}
        case iid of                    {what did the user select ?}
0:        pos2.sq[sty, stx].piece := chess_sqr_bqueen_k;
1:        pos2.sq[sty, stx].piece := chess_sqr_brook_k;
2:        pos2.sq[sty, stx].piece := chess_sqr_bbishop_k;
3:        pos2.sq[sty, stx].piece := chess_sqr_bknight_k;
          end;
        end
      ;
    end;                               {done handling promoting of a pawn}

  pos := pos2;                         {update official board position}
  chessv_event_nextmove;
  goto did_event;
  end;                                 {end of left mouse key case}
{
*****
*
*   Event from unexpected key.
}
otherwise
    goto notus;
    end;                               {end of RENDlib KEY event type case}
  end;                                 {end of RENDlib KEY event case}
{
**********
*
*   The pointer moved.
}
rend_ev_pnt_move_k: begin
  if                                   {pointer coordinate outside our window ?}
      (ev.pnt_move.x < win.pos.x) or
      (ev.pnt_move.x > (win.pos.x + win.rect.dx)) or
      (ev.pnt_move.y < win.pos.y) or
      (ev.pnt_move.y > (win.pos.y + win.rect.dy))
    then goto notus;
  end;
{
**********
*
*   These events are taken from the queue but ignored.
}
rend_ev_pnt_enter_k,
rend_ev_pnt_exit_k: ;
{
**********
*
*   Event is a type not handled by this window.
}
otherwise                              {any other RENDlib event type}
    goto notus;                        {this event is not for us}
    end;                               {end of RENDlib event type cases}
{
*   Assume the event was processed.
}
did_event:
  chessv_win_play_evhan := gui_evhan_did_k; {we processed at least one event}
  return;
{
*   The event was not handled.  EV is pushed onto the event queue if it
*   contains an event.
}
notus:                                 {jump here if event is not for this window}
  if ev.ev_type <> rend_ev_none_k then begin {an event was taken but not handled ?}
    rend_event_push (ev);              {put event back onto queue}
    end;
  chessv_win_play_evhan := gui_evhan_notme_k; {there was an event but not for us}
  end;
{
*************************************************************************
*
*   Local subroutine FIND_TAKEN (POS, WHITE, TAKEN)
*
*   Make a list of all the chess pieces taken from a particular color.  POS
*   is the chess position.  WHITE is TRUE to list the pieces taken
*   from white, FALSE for black.  TAKEN is returned indicating the number
*   of pieces of each type that have been taken.
}
procedure find_taken (                 {find chess pieces taken}
  in      pos: chess_pos_t;            {current board position}
  in      white: boolean;              {TRUE to get pieces taken from white}
  out     taken: plist_t);             {list of pieces taken from selected color}
  val_param; internal;

var
  x, y: sys_int_machine_t;             {chess square 0-7 coordinates}

begin
  taken.pawn := 8;                     {init list to full complement of pieces}
  taken.rook := 2;
  taken.knight := 2;
  taken.bishop := 2;
  taken.queen := 1;
  taken.king := 1;

  for y := 0 to 7 do begin             {up the chess board rows}
    for x := 0 to 7 do begin           {accross this row}
      case pos.sq[y, x].piece of       {what is on this square ?}
chess_sqr_wpawn_k: if white then taken.pawn := max(0, taken.pawn - 1); {white pawn}
chess_sqr_wrook_k: if white then taken.rook := max(0, taken.rook - 1); {white rook}
chess_sqr_wknight_k: if white then taken.knight := max(0, taken.knight - 1); {white knight}
chess_sqr_wbishop_k: if white then taken.bishop := max(0, taken.bishop - 1); {white bishop}
chess_sqr_wqueen_k: if white then taken.queen := max(0, taken.queen - 1); {white queen}
chess_sqr_wking_k: if white then taken.king := max(0, taken.king - 1); {white king}
chess_sqr_bpawn_k: if not white then taken.pawn := max(0, taken.pawn - 1); {black pawn}
chess_sqr_brook_k: if not white then taken.rook := max(0, taken.rook - 1); {black rook}
chess_sqr_bknight_k: if not white then taken.knight := max(0, taken.knight - 1); {black knight}
chess_sqr_bbishop_k: if not white then taken.bishop := max(0, taken.bishop - 1); {black bishop}
chess_sqr_bqueen_k: if not white then taken.queen := max(0, taken.queen - 1); {black queen}
chess_sqr_bking_k: if not white then taken.king := max(0, taken.king - 1); {black king}
        end;                           {end of what is on square cases}
      end;                             {back for next square this row}
    end;                               {back for next row}

  taken.total :=                       {make total number of pieces reporting}
    taken.pawn +
    taken.rook +
    taken.knight +
    taken.bishop +
    taken.queen +
    taken.king;
  end;
{
*************************************************************************
*
*   Local subroutine DRAW_TAKEN (WHITE)
*
*   Draw all the pieces taken from the opponent.  The RENDlib current point
*   is in the center of the area to draw the taken pieces in.  WHITE is
*   TRUE if the pieces where taken from white, FALSE for taken from black.
*
*   The RENDlib current point is trashed.
}
procedure draw_taken (                 {draw pieces taken by the opponent}
  in      white: boolean);             {TRUE to draw pieces taken from white}
  val_param; internal;

var
  taken: plist_t;                      {list of pieces taken}
  ds: real;                            {size of square to draw taken pieces in}
  xb, yb, ofs: vect_2d_t;              {2D transform for curr square 0,0 to 1,1}
  xbo, ybo, ofso: vect_2d_t;           {saved original 2D transform}
  x, y: real;                          {saved current point}
{
********************
*
*   Private subroutine PIECES (P, N)
*
*   Draw N copies of the piece P horizontally.
}
procedure pieces (                     {draw all the taken pieces of one type}
  in      p: chess_sqr_k_t;            {type of pieces to draw}
  in      n: sys_int_machine_t);       {number of pieces to draw}
  val_param; internal;

var
  i: sys_int_machine_t;                {loop counter}
  onsq: chess_square_t;                {full chess square description to draw}

begin
  onsq.piece := p;                     {set ID of piece to draw}
  onsq.flags := [];                    {no special flags apply}

  for i := 1 to n do begin             {once for each piece to draw}
    ofs.x := x * xbo.x + y * ybo.x + ofso.x;
    ofs.y := x * xbo.y + y * ybo.y + ofso.y;
    rend_set.xform_2d^ (xb, yb, ofs);  {enter space for this piece}
    chessv_piece_draw (onsq);          {draw one copy of the piece}
    x := x + ds;                       {update lower left corner for next piece}
    end;
  end;
{
********************
*
*   Start of main routine.
}
begin
  find_taken (pos, white, taken);      {make list of taken pieces}
  if taken.total = 0 then return;      {no pieces taken, nothing to do ?}

  ds := dsquare * size_taken;          {make size of square to draw taken pieces in}
  rend_set.rcpnt_2d^ ((-ds * taken.total) / 2.0, -ds / 2.0); {to lower left start}
  rend_get.cpnt_2d^ (x, y);            {save current lower left corner coordinate}

  rend_get.xform_2d^ (xbo, ybo, ofso); {get and save existing 2D transform}
  xb.x := xbo.x * ds;                  {init static values for new transforms}
  xb.y := xbo.y * ds;
  yb.x := ybo.x * ds;
  yb.y := ybo.y * ds;

  if white
    then begin
      pieces (chess_sqr_wking_k, taken.king);
      pieces (chess_sqr_wqueen_k, taken.queen);
      pieces (chess_sqr_wrook_k, taken.rook);
      pieces (chess_sqr_wbishop_k, taken.bishop);
      pieces (chess_sqr_wknight_k, taken.knight);
      pieces (chess_sqr_wpawn_k, taken.pawn);
      end
    else begin
      pieces (chess_sqr_bking_k, taken.king);
      pieces (chess_sqr_bqueen_k, taken.queen);
      pieces (chess_sqr_brook_k, taken.rook);
      pieces (chess_sqr_bbishop_k, taken.bishop);
      pieces (chess_sqr_bknight_k, taken.knight);
      pieces (chess_sqr_bpawn_k, taken.pawn);
      end
    ;

  rend_set.xform_2d^ (xbo, ybo, ofso); {restore RENDlib 2D transform}
  end;
{
*************************************************************************
*
*   Subroutine CHESSV_WIN_PLAY_DRAW (WIN, APP_P)
}
procedure chessv_win_play_draw (       {drawing routine for play window}
  in out  win: gui_win_t;              {window to draw}
  in      app_p: univ_ptr);            {pointer to arbitrary application data}
  val_param; internal;

var
  not_view: boolean;                   {opposite of VIEW_WHITE}

begin
  not_view := not view_white;          {make opposite of VIEW_WHITE flag}

  rend_set.rgb^ (0.65, 0.65, 0.72);

  rend_set.cpnt_2d^ (0.0, 0.0);        {clear area below board}
  rend_prim.rect_2d^ (win_play.rect.dx, y_board1);

  rend_set.cpnt_2d^ (0.0, y_board2);   {clear area above board}
  rend_prim.rect_2d^ (win_play.rect.dx, win_play.rect.dy - y_board2);

  rend_set.cpnt_2d^ (0.0, y_board1);   {clear area left of board}
  rend_prim.rect_2d^ (x_board1, y_board2 - y_board1);

  rend_set.cpnt_2d^ (x_board2, y_board1); {clear area right of board}
  rend_prim.rect_2d^ (win_play.rect.dx - x_board2, y_board2 - y_board1);
{
*   Draw taken pieces above the board.
}
  rend_set.cpnt_2d^ (                  {go to center of area above the board}
    (x_board1 + x_board2) * 0.5,
    (win_play.rect.dy + y_board2) * 0.5);
  draw_taken (view_white);

  rend_set.cpnt_2d^ (                  {go to center of area below the board}
    (x_board1 + x_board2) * 0.5,
    y_board1 * 0.5);
  draw_taken (not_view);
  end;
{
*************************************************************************
*
*   Subroutine CHESSV_WIN_PLAY_INIT
*
*   Initialize the contents of the play window, WIN_PLAY.  The
*   window has already been created.
}
procedure chessv_win_play_init;        {init contents of play area window}

var
  f: real;                             {scratch floating point value}

begin
  gui_win_set_draw (                   {set drawing routine for this window}
    win_play, univ_ptr(addr(chessv_win_play_draw)));
  gui_win_set_evhan (                  {set event handler for this window}
    win_play, univ_ptr(addr(chessv_win_play_evhan)));
{
*   Determine size and placement of chess board.
}
  f := min(win_play.rect.dx, win_play.rect.dy); {make min dimension of play area}
  f := roundown(f / 10.0);             {make size of each chess square}
  dsquare := f;                        {save chess square size}
  f := f * 8.0;                        {make size of chess board}

  x_board1 := round((win_play.rect.dx - f) / 2.0);
  x_board2 := x_board1 + f;
  y_board1 := round((win_play.rect.dy - f) / 2.0);
  y_board2 := y_board1 + f;
{
*   Create chess board window.
}
  gui_win_child (                      {create window for raw chess board}
    win_board,                         {new window}
    win_play,                          {parent window}
    x_board1, y_board1,                {lower left corner within parent window}
    x_board2 - x_board1, y_board2 - y_board1); {displacement to upper right corner}

  chessv_win_board_init;               {initialize chess board window contents}
  end;
