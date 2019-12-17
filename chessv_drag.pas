module chessv_drag;
define chessv_drag;
%include 'chessv2.ins.pas';
{
*************************************************************************
*
*   Function CHESSV_DRAG (STARTX, STARTY, ENDX, ENDY)
*
*   Perform a rubber band drag operation.  STARTX,STARTY are the RENDlib
*   coordinates for the drag starting location.  ENDX,ENDY will be set
*   to the RENDlib coordinates of the drag end location confirmed by the
*   user.  The function returns TRUE if the user confirmed the drag end,
*   and FALSE if the drag operation was cancelled for whatever reason.
*   ENDX and ENDY are undefined if the function returns FALSE.
*
*   It is assumed that the drag operation was initiated by a press of the
*   left mouse button, and that this mouse button is still pressed.  The
*   drag will be ended and confirmed when this mouse button is released.
*   Any event not related to a normal drag cancells the drag, in which case
*   the unexpected event is pushed back onto the event queue.
}
function chessv_drag (                 {perform a pointer rubber band drag operation}
  in      startx, starty: real;        {RENDlib coordinates of drag start}
  out     endx, endy: real)            {final RENDlib end of drag coordinates}
  :boolean;                            {TRUE if drag confirmed, not cancelled}
  val_param;

var
  sx, sy: sys_int_machine_t;           {2DIMI pixel coordinate of drag start}
  ix, iy: sys_int_machine_t;           {2DIMI pixel coordinate of current drag end}
  ev: rend_event_t;                    {one RENDlib event}
  modk: rend_key_mod_t;                {set of modifier keys}

label
  loop_event, cancell;
{
********************
*
*   Internal subroutine LINE
*
*   Draw the rubber band line once from SX,SY to IX,IY.  It is assumed that
*   XOR mode is in effect, so drawing the line a second time will erase it.
}
procedure line;

begin
  rend_set.cpnt_2dim^ (sx + 0.5, sy + 0.5);
  rend_prim.vect_2dim^ (ix + 0.5, iy + 0.5);
  end;
{
********************
*
*   Internal subroutine NEWLINE (X, Y)
*
*   Update the rubber band line to the new end point X,Y.
}
procedure newline (
  in      x, y: sys_int_machine_t);

begin
  line;                                {erase old line by drawing again in XOR mode}
  ix := x;                             {update drag end point}
  iy := y;
  line;                                {draw line in new position}
  end;
{
********************
*
*   Internal subroutine UNDRAG
*
*   Erase the drag line and restore the drawing state.
}
procedure undrag;

begin
  line;                                {erase old line by drawing again in XOR mode}
  rend_set.iterp_pixfun^ (rend_iterp_red_k, rend_pixfun_insert_k);
  rend_set.iterp_pixfun^ (rend_iterp_grn_k, rend_pixfun_insert_k);
  rend_set.iterp_pixfun^ (rend_iterp_blu_k, rend_pixfun_insert_k);
  end;
{
********************
*
*   Start of main routine.
}
begin
  sx := trunc(startx);                 {save 2DIMI coordinate of drag start}
  sy := trunc(starty);
  discard( rend_get.pointer^ (ix, iy) ); {init current end of drag}
  rend_set.iterp_pixfun^ (rend_iterp_red_k, rend_pixfun_xor_k);
  rend_set.iterp_pixfun^ (rend_iterp_grn_k, rend_pixfun_xor_k);
  rend_set.iterp_pixfun^ (rend_iterp_blu_k, rend_pixfun_xor_k);
  rend_set.rgb^ (0.5, 0.5, 0.5);       {set value to XOR against existing pixels}
  line;                                {draw initial rubber band line}

loop_event:                            {back here to get each new event}
  rend_event_get (ev);                 {get the next event from the event queue}
  case ev.ev_type of                   {what kind of event is it ?}
{
*   A key was pressed or released.
}
rend_ev_key_k: begin                   {a key was pressed or released}
      if ev.key.down then goto cancell; {a key was pressed, not released ?}
      modk := ev.key.modk;             {get set of modifier keys}
      modk := modk - [                 {remove modifiers that are OK}
        rend_key_mod_shiftlock_k];
      if modk <> [] then goto cancell; {punt on any other modifier keys}
      if gui_key_k_t(ev.key.key_p^.id_user) <> gui_key_mouse_left_k
        then goto cancell;             {not left mouse button ?}

      undrag;                          {exit drag mode}
      endx := ix + 0.5;                {return final drag end coordinates}
      endy := iy + 0.5;
      chessv_drag := true;             {indicate drag confirmed}
      return;
      end;
{
*   The pointer moved.
}
rend_ev_pnt_move_k: begin
      newline (ev.pnt_move.x, ev.pnt_move.y);
      end;
{
*   The pointer entered the drawing area.
}
rend_ev_pnt_enter_k: ;                 {ignore this}
{
*   The pointer left the drawing area.
}
rend_ev_pnt_exit_k: ;                  {ignore this}
{
*   Event that is not part of the drag operation.  This cancells the drag.
}
otherwise
    goto cancell;
    end;
  goto loop_event;                     {back to get and process the next event}
{
*   Cancel the drag operation.  The event in EV will be pushed back onto
*   the event queue.
}
cancell:
  undrag;                              {exit drag mode}
  rend_event_push (ev);                {push unexpected event back onto the queue}
  chessv_drag := false;                {indicate the drag operation was cancelled}
  end;
