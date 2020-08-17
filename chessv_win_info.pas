module chessv_win_info;
define chessv_win_info_init;
%include 'chessv2.ins.pas';
{
*************************************************************************
*
*   Local subroutine NMOVE_Y (N, Y1, Y2)
*
*   Find the lower (Y1) and upper (Y2) limits of the text line describing
*   contemplated move N.
}
procedure nmove_y (                    {find Y coor of comtemplated move}
  in      n: sys_int_machine_t;        {1-N contemplated move number}
  out     y1, y2: real);               {bottom/top Y of text line}
  val_param; internal;

begin
  y1 := win_info.rect.dy - thigh * 2.0; {title line baseline}
  y1 := y1 - lspace - thigh;           {account for ENDORG of title line}
  y1 := y1 - thigh;                    {account for space before first move line}
  y1 := y1 - lspace * 0.5;             {half way down to next line}
  y1 := y1 - (thigh + lspace) * (n - 1); {once for each additional line down}
  y2 := y1 + lspace + thigh;           {half way to next line up}
  end;
{
*************************************************************************
*
*   Local subroutine YMOVE_N (Y, N)
*
*   Find the contemplated move N from the window Y coordinate Y.  N will
*   be out of the 1 to NLMOVE range if Y is above or below the list of moves.
}
procedure ymove_n (                    {find move number from moves list Y coor}
  in      y: real;                     {window Y coordinate}
  out     n: sys_int_machine_t);       {1-NLMOVE move number when Y within list}
  val_param; internal;

var
  y1, y2: real;                        {bottom and top Y for move 1}
  dy: real;                            {height of each list entry line}

begin
  nmove_y (1, y1, y2);                 {get bottom and top Y for first list entry}
  dy := y2 - y1;                       {make height of each line}
  n := trunc((y2 - y) / dy + 1.0);
  end;
{
*************************************************************************
*
*   Local subroutine LMOVE_SET (N)
*
*   Set the last move to the last moves list entry N.
}
procedure lmove_set (                  {select a move from the LMOVES list}
  in      n: sys_int_machine_t);       {1-NLMOVE move num, ignored if out of range}
  val_param; internal;

var
  oldn: sys_int_machine_t;             {number of previously selected move}
  y1, y2: real;                        {Y coor range of move line in INFO window}

begin
  if (n < 0) or (n > nlmove) then return; {new move number is out of range ?}
  if lmove = n then return;            {this move is already selected ?}
  oldn := lmove;                       {save number of old selected move}
  lmove := n;                          {indicate new selected move}

  with lmoves_p_ar[n]^: m do begin     {M is abbreviation for the new move}
    pos := m.pos;                      {update new chess position}
    move_fx := m.fx;                   {update new move from/to}
    move_fy := m.fy;
    move_tx := m.tx;
    move_ty := m.ty;
    lastmove := true;
    end;                               {done with M abbreviation}
  chessv_hist_set;                     {update curr history entry to new position}

  if info_disp = info_compeval_k then begin {need to updated display ?}
    nmove_y (oldn, y1, y2);            {get location of old move line}
    gui_win_draw (win_info, 0.0, win_info.rect.dx, y1, y2); {redraw old move line}
    nmove_y (lmove, y1, y2);           {get location of new move line}
    gui_win_draw (win_info, 0.0, win_info.rect.dx, y1, y2); {redraw new move line}
    end;

  chessv_event_newpos;                 {indicate chess position in POS has changed}
  chessv_setmode (mode_pause_k);       {temporarily suspend play}
  chessv_event_move;                   {cause player to move, if appropriate}
  end;
{
*************************************************************************
*
*   Subroutine CHESSV_WIN_INFO_DRAW (WIN, APP_P)
}
procedure chessv_win_info_draw (       {drawing routine for info window}
  in out  win: gui_win_t;              {window to draw}
  in      app_p: univ_ptr);            {pointer to arbitrary application data}
  val_param; internal;

const
  max_msg_parms = 2;                   {max parameters we can pass to a message}

var
  i: sys_int_machine_t;                {loop counter}
  buf: string_var80_t;                 {scratch string}
  tk: string_var80_t;                  {scratch token}
  lx, ly: real;                        {X,Y for next text line}
  xw, xb: real;                        {left X for history column text}
  xcw, xcb: real;                      {left X for raw history columns}
  dxcol: real;                         {width of whole history column}
  y1, y2: real;                        {scratch Y coordinates}
  r: real;                             {scratch real number}
  hent_p: hist_ent_p_t;                {pointer to history list entry}
  tp: rend_text_parms_t;               {local copy of text control parameters}
  st: chess_move_t;                    {info about a chess move}
  white: boolean;                      {flag for which opponent}
  msg_parm:                            {parameter references for messages}
    array[1..max_msg_parms] of sys_parm_msg_t;

begin
  buf.max := size_char(buf.str);       {init local var strings}
  tk.max := size_char(tk.str);

  rend_set.rgb^ (0.85, 0.85, 0.85);    {clear to background}
  rend_prim.clear_cwind^;
  rend_set.rgb^ (0.0, 0.0, 0.0);       {set foreground color}
  case info_disp of                    {what is supposed to be displayed here ?}
{
********************
*
*   Display the history list.
}
info_hist_k: begin
  tp := tparm;                         {make local copy of text control parameters}
  tp.start_org := rend_torg_ll_k;      {set text anchor point}
  rend_set.text_parms^ (tp);
  xcw := twide * 0.7;                  {set left X for white moves column}
  xcb := win.rect.dx * 0.5 + xcw;      {set left X for black moves column}
  dxcol := xcb - xcw - twide;          {width of a full column}
  xw := xcw + twide * 0.5;             {left X for white column text}
  xb := xcb + twide * 0.5;             {left X for black column text}
  ly := win.rect.dy - thigh * 2.0;     {set Y for first text line}
{
*   Draw the heading line.
}
  rend_set.cpnt_2d^ (xcw, ly);         {go to white heading}
  rend_prim.text^ ('WHITE', 5);        {draw it}
  rend_set.cpnt_2d^ (xcb, ly);         {go to black heading}
  rend_prim.text^ ('BLACK', 5);        {draw it}

  ly := ly - lspace;                   {draw lines under headings}
  rend_set.cpnt_2d^ (xcw, ly);
  rend_prim.vect_2d^ (xcw + dxcol, ly); {draw line under white heading}
  rend_set.cpnt_2d^ (xcb, ly);
  rend_prim.vect_2d^ (xcb + dxcol, ly); {draw line under black heading}

  ly := ly - lspace - thigh;           {set Y for first history line}
{
*   Draw the history lines.
}
  hent_p := hist_start_p;              {point to first entry in history list}
  while hent_p <> nil do begin         {once for each history list entry}
    white := not hent_p^.whmove;       {TRUE if draw in white column}
    if                                 {draw this entry one line down ?}
        (hent_p^.prev_p <> nil) and    {there is a previous entry}
        white                          {going into white column ?}
        then begin
      ly := ly - lspace - thigh;       {go one line down}
      end;

    if hent_p = hist_p then begin      {this is the selected history entry ?}
      if white                         {get left X of column}
        then lx := xcw
        else lx := xcb;
      rend_set.rgb^ (0.15, 0.15, 0.6); {clear background to highlighted color}
      rend_set.cpnt_2d^ (lx, ly - lspace * 0.5);
      rend_prim.rect_2d^ (dxcol, thigh + lspace);
      rend_set.rgb^ (1.0, 1.0, 1.0);   {set foreground color for highlighted entry}
      end;

    if white                           {get left X for text start}
      then lx := xw
      else lx := xb;
    rend_set.cpnt_2d^ (lx, ly);        {go to start of this move description}
    if hent_p^.lastmove
      then begin                       {there is a move to show}
        if hent_p^.prev_p = nil
          then begin                   {board position prior to move not available}
            st.pos := hent_p^.pos;     {init starting position to ending position}
            st.pos.sq[hent_p^.ty, hent_p^.tx].piece := chess_sqr_empty_k;
            st.pos.sq[hent_p^.ty, hent_p^.tx].flags := [];
            end
          else begin                   {previous board position available directly}
            st.pos := hent_p^.prev_p^.pos;
            end
          ;
        st.x := hent_p^.fx;            {set move source square}
        st.y := hent_p^.fy;
        st.lx := hent_p^.tx;           {set move destination square}
        st.ly := hent_p^.ty;
        st.piece := hent_p^.pos.sq[st.ly, st.lx].piece; {set type of piece moved}
        st.white := white;             {indicate who moved}
        chess_name_move (st, buf);     {make move name in BUF}
        end
      else begin                       {there is no move to show}
        string_vstring (buf, '-- start --'(0), -1);
        end
      ;
    rend_prim.text^ (buf.str, buf.len); {draw the string for this move}

    if hent_p = hist_p then begin      {this is the selected history entry ?}
      rend_set.rgb^ (0.0, 0.0, 0.0);   {back to normal foreground color}
      end;
    hent_p := hent_p^.next_p;          {advance to next history list entry}
    end;                               {back to draw this new history list entry}
  end;                                 {end of display history list case}
{
********************
*
*   Display the evaluations for the last computer move, if any.
}
info_compeval_k: begin
  tparm.start_org := rend_torg_ll_k;   {set text control parameters}
  rend_set.text_parms^ (tparm);
  lx := twide * 0.7;                   {init location for first text line start}
  ly := win.rect.dy - thigh * 2.0;
  rend_set.cpnt_2d^ (lx, ly);

  if nlmove > 0 then begin             {there are moves to show ?}
{
*   Show the number of contemplated moves and elapsed time.
}
    sys_msg_parm_int (msg_parm[1], nlmove);
    r := lmove_sec / 60.0;
    sys_msg_parm_real (msg_parm[2], r);
    string_f_message (buf, 'chessv_prog', 'info_nmoves_time', msg_parm, 2);
    rend_prim.text^ (buf.str, buf.len); {write the message to the window}

    rend_set.rcpnt_2d^ (0.0, -thigh);  {leave vertical space after heading}
{
*   Clear background of selected move to different color.
}
    nmove_y (lmove, y1, y2);           {find top/bottom of text for selected line}
    rend_set.rgb^ (0.15, 0.15, 0.6);   {background color for selected line}
    rend_set.cpnt_2d^ (0.0, y1);
    rend_prim.rect_2d^ (win.rect.dx, y2 - y1); {clear to selected background}
    end;                               {end of there are moves to show case}
{
*   Show each of the moves in the list.
}
  tparm.start_org := rend_torg_ml_k;   {anchor text at middle left to current point}
  rend_set.text_parms^ (tparm);

  for i := 1 to nlmove do begin        {once for each contemplated move}
    with lmoves_p_ar[i]^: m do begin   {M is abbreviation for this move}
      string_f_int (buf, m.val);       {make string for move valuation}
      string_appends (buf, ': '(0));
      string_append (buf, m.name);     {append move name string}
      if i = lmove
        then begin                     {this is the selected move}
          rend_set.rgb^ (1.0, 1.0, 1.0);
          end
        else begin                     {this is not the selected move}
          rend_set.rgb^ (0.0, 0.0, 0.0);
          end
        ;
      nmove_y (i, y1, y2);             {find bottom/top Y for this move text line}
      rend_set.cpnt_2d^ (lx, (y1 + y2) / 2.0); {go to left center of text line}
      rend_prim.text^ (buf.str, buf.len); {write info for this move}
      end;                             {done with M abbreviation}
    end;                               {back for next move in list}
  end;                                 {end of display computer evaluation case}

    end;                               {end of what to display cases}
  end;
{
*************************************************************************
*
*   Local function CHESSV_WIN_INFO_EVHAN (WIN, APP_P)
*
*   Handle events for the INFO window.
}
function chessv_win_info_evhan (       {INFO window event handler}
  in      win: gui_win_t;              {window handling events for}
  in      app_p: univ_ptr)             {application-specific pointer, unused}
  :gui_evhan_k_t;                      {event handler completion code}
  val_param;

var
  ev: rend_event_t;                    {one RENDlib event}
  modk: rend_key_mod_t;                {set of modifier keys}
  wx, wy: real;                        {coordinate in window space}
  n: sys_int_machine_t;                {scratch integer}

label
  did_event, notus;

begin
  rend_event_get (ev);                 {get the next event from the event queue}
  case ev.ev_type of                   {what kind of event is it ?}
{
**********
*
*   A key was pressed or released.
}
rend_ev_key_k: begin                   {a key was pressed or released}
  discard( rend_event_key_multiple(ev) ); {discard immediately following repeated events}
  modk := ev.key.modk;                 {make local copy of modifier keys}
  modk := modk - [rend_key_mod_shiftlock_k]; {SHIFTLOCK modifier will be ignored}
  case gui_key_k_t(ev.key.key_p^.id_user) of {which key is it ?}
{
*****
*
*   Left mouse button.
}
gui_key_mouse_left_k: begin            {left mouse key was pressed or released}
  if modk <> [] then goto notus;       {ignore on unexpected modifiers}
  wx := ev.key.x - win.pos.x;          {make pointer coordinate in window space}
  wy := win.pos.y + win.rect.dy - ev.key.y;
  if                                   {pointer coordinate outside our window ?}
      (wx < 0.0) or (wx > win.rect.dx) or
      (wy < 0.0) or (wy > win.rect.dy)
    then goto notus;
  if not ev.key.down then goto did_event; {key was released, not pressed ?}
  if info_disp <> info_compeval_k      {ignore unless displaying move evaluations}
    then goto did_event;

  ymove_n (wy, n);                     {get number of move from list selected}
  if (n < 1) or (n > nlmove)           {ignore if not selected valid list item}
    then goto did_event;

  lmove_set (n);                       {select the new move}
  end;                                 {end of left mouse button key}
{
*****
*
*   Up arrow key.
}
gui_key_arrow_up_k: begin
  if modk <> [] then goto notus;       {ignore on unexpected modifiers}
  if not ev.key.down then goto did_event; {key was released, not pressed ?}
  if info_disp <> info_compeval_k      {ignore unless displaying move evaluations}
    then goto did_event;
  n := max(1, min(nlmove, lmove - 1)); {make new list entry number of selected move}
  lmove_set (n);                       {select the new move}
  end;
{
*****
*
*   Down arrow key.
}
gui_key_arrow_down_k: begin
  if modk <> [] then goto notus;       {ignore on unexpected modifiers}
  if not ev.key.down then goto did_event; {key was released, not pressed ?}
  if info_disp <> info_compeval_k      {ignore unless displaying move evaluations}
    then goto did_event;
  n := max(1, min(nlmove, lmove + 1)); {make new list entry number of selected move}
  lmove_set (n);                       {select the new move}
  end;
{
*****
*
*   The left arrow key.
}
gui_key_arrow_left_k: begin
  if modk <> [] then goto notus;       {ignore on unexpected modifiers}
  if not ev.key.down then goto did_event; {key was released, not pressed ?}
  info_disp := info_hist_k;            {definitely display the history list}
  if hist_p^.prev_p = nil then goto did_event; {ignore if no previous history entry}

  hist_p := hist_p^.prev_p;            {go to previous history entry}
  chessv_event_hist;                   {update to at new history entry}
  end;
{
*****
*
*   The right arrow key.
}
gui_key_arrow_right_k: begin
  if modk <> [] then goto notus;       {ignore on unexpected modifiers}
  if not ev.key.down then goto did_event; {key was released, not pressed ?}
  info_disp := info_hist_k;            {definitely display the history list}
  if hist_p^.next_p = nil then goto did_event; {ignore if no subsequent hist entry}

  hist_p := hist_p^.next_p;            {go to new history list entry}
  chessv_event_hist;                   {update to at new history entry}
  end;
{
*****
*
*   A character key.
}
gui_key_char_k: begin
  modk := modk - [rend_key_mod_ctrl_k]; {remove modifiers we handle here}
  if modk <> [] then goto notus;       {unexpected modifiers ?}
  if not (rend_key_mod_ctrl_k in ev.key.modk) {CTRL modifier not present ?}
    then goto notus;
  case ev.key.key_p^.val_p^.str[1] of  {what character is this key ?}

'e': begin                             {view computer move evaluations}
      if info_disp <> info_compeval_k then begin {not already set this way ?}
        info_disp := info_compeval_k;
        gui_win_draw_all (win_info);
        end;
      end;

'h': begin                             {view the history list}
      if info_disp <> info_hist_k then begin {not already set this way ?}
        info_disp := info_hist_k;
        gui_win_draw_all (win_info);
        end;
      end;

'p': begin                             {enter pause mode}
      if mode = mode_play_k then begin {currently in active play mode ?}
        chessv_setmode (mode_pause_k);
        end;
      end;

otherwise                              {event is key not handled here}
    goto notus;
    end;                               {end of which control char cases}
  end;
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
*   Event is a type not handled by this window.
}
otherwise                              {any other RENDlib event type}
    goto notus;                        {this event is not for us}
    end;                               {end of RENDlib event type cases}
{
*   Assume the event was processed.
}
did_event:
  chessv_win_info_evhan := gui_evhan_did_k; {we processed at least one event}
  return;
{
*   The event was not handled.  EV is pushed onto the event queue if it
*   contains an event.
}
notus:                                 {jump here if event is not for this window}
  if ev.ev_type <> rend_ev_none_k then begin {an event was taken but not handled ?}
    rend_event_push (ev);              {put event back onto queue}
    end;
  chessv_win_info_evhan := gui_evhan_notme_k; {there was an event but not for us}
  end;
{
*************************************************************************
*
*   Subroutine CHESSV_WIN_INFO_INIT
*
*   Initialize the contents of the info window, WIN_INFO.  The
*   window has already been created.
}
procedure chessv_win_info_init;        {init contents of info area window}

begin
  gui_win_set_draw (                   {set drawing routine for this window}
    win_info, univ_ptr(addr(chessv_win_info_draw)));
  gui_win_set_evhan (                  {set event handler routine for this window}
    win_info, univ_ptr(addr(chessv_win_info_evhan)));
  end;
