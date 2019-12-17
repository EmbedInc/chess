module chessv_move_comp;
define chessv_move_comp;
%include 'chessv2.ins.pas';
{
*************************************************************************
*
*   Local subroutine THREAD_COMP (ARG)
*
*   This routine is run in a separate thread.  It does the computing for
*   finding the next move, then pushes appropriate events onto the queue
*   and exits.  Computing the move is done in a separate thread since it
*   can take a long time.  The main thread will continue to service events.
}
procedure thread_comp (                {main thread routine for computing a move}
  in      arg: sys_int_adr_t);         {argument, unused}
  val_param;

var
  ev: rend_event_t;                    {RENDlib event descriptor}
  timer: sys_timer_t;                  {evaluate moves stopwatch timer}
{
********************
*
*   Local subroutine FIND_MOVES (WHITE)
*
*   Find all the moves for white when WHITE is TRUE, and for black when
*   false.  The list of moves will be left in LMOVES, with LMOVES_P_AR
*   pointing to the moves in descending value (best move listed first).
*   NLMOVE will be set to the number of moves in the lists, and LMOVE
*   will be set to 1 indicating the most desired move.
*
*   The static fields in the MOVE array must already be initialized.
}
procedure find_moves (                 {find and evaluate moves for a color}
  in      white: boolean);             {do moves for white on TRUE, black on FALSE}
  val_param; internal;

var
  i, j: sys_int_machine_t;             {scratch integers}
  n: sys_int_machine_t;                {total number of legal moves found}
  p: univ_ptr;                         {scratch pointer}
  st: chess_move_t;                    {move generator state}
  opp: boolean;                        {WHITE flag for opponent}

begin
  nlmove := 0;                         {indicate list empty while changing contents}
  chess_move_init (addr(pos), white, st); {init for finding moves}
  opp := not white;                    {make WHITE flag for opponent}
{
*   Build the list of moves in LMOVES.  Init the pointers in LMOVES_P_AR
*   to point to the moves in arbitrary order.
}
  n := 1;                              {LMOVES index to write next move into}

  while chess_move(st, lmoves[n].pos) do begin {once for each move}
    with lmoves[n]: m do begin         {M is abbreviation for this LMOVES entry}
      chess_name_move (st, m.name);    {save name for this move}
      m.fx := st.x;                    {save move source coordinates}
      m.fy := st.y;
      m.tx := st.lx;                   {save move destination coordinates}
      m.ty := st.ly;
      m.val := eval.eval_move_p^ (     {get evaluation of this move}
        addr(eval),                    {address of move generator context}
        m.pos,                         {board position after the move}
        opp);                          {TRUE if it is not white's move}
      if not white then begin          {flip evaluation for black point of view}
        m.val := -m.val;
        end;
      lmoves_p_ar[n] := addr(lmoves[n]); {init pointer to this slot}
      n := n + 1;                      {advance to the next LMOVES entry}
      end;                             {done with M abbreviation}
    end;                               {back for next move}

  n := n - 1;                          {make the total number of moves found}
{
*   Sort the pointers in MOVE_P_AR to point to the moves in order of
*   descending valuation.
}
  for i := 1 to n-1 do begin           {once for each pointer to set}
    for j := i + 1 to n do begin       {once for each entry to compare I entry to}
      if lmoves_p_ar[j]^.val > lmoves_p_ar[i]^.val then begin {found better entry ?}
        p := lmoves_p_ar[i];           {flip I and J entries}
        lmoves_p_ar[i] := lmoves_p_ar[j];
        lmoves_p_ar[j] := p;
        end;
      end;                             {back for next other entry this main ent}
    end;                               {back for next main entry}
{
*   Count the number of identically scored best entries, and randomly pick
*   one.
}
  j := lmoves_p_ar[1]^.val;            {get winning move score}
  i := 1;                              {init number of top entries with same score}
  while (i < n) and then (lmoves_p_ar[i+1]^.val = j) do begin {same score ?}
    i := i + 1;                        {count one more entry with top score}
    end;

  if i > 1 then begin                  {multiple entries with best score ?}
    j := trunc(math_rand_real(rand) * i) + 1; {pick one of the entries ?}
    if j <> 1 then begin               {didn't pick current top of list entry ?}
      p := lmoves_p_ar[1];             {flip with first entry}
      lmoves_p_ar[1] := lmoves_p_ar[j];
      lmoves_p_ar[j] := p;
      end;
    end;

  nlmove := n;                         {set number of legal moves in common block}
  lmove := 1;                          {indicate which move is chosen}
  end;
{
********************
*
*   Start of main routine.
}
begin
  sys_timer_init (timer);              {initialize the stopwatch}
  sys_timer_start (timer);             {start timing move generate/evaluate}
  find_moves (whmove);                 {find and sort all legal moves}
  sys_timer_stop (timer);              {done generating and evaluating moves}

  with lmoves_p_ar[1]^: m do begin     {M is abbreviation for top rated move}
    pos := m.pos;                      {update board position after this move}
    move_fx := m.fx;                   {indicate move source square}
    move_fy := m.fy;
    move_tx := m.tx;                   {indicate move destination square}
    move_ty := m.ty;
    end;                               {done with M abbreviation}

  lastmove := true;                    {there is now info on last move made}
  lmove_sec := sys_timer_sec(timer);   {save time used to generate/evaluate moves}

  ev.dev := rendev;                    {send event for new LMOVES state}
  ev.ev_type := rend_ev_app_k;
  ev.app.i1 := ord(evtype_new_lmoves_k);
  rend_event_push (ev);

  if nlmove <= 0 then return;          {no legal moves, nothing more to do ?}

  chessv_event_nextmove;               {indicate done with this move, on to next}
  end;
{
*************************************************************************
*
*   Subroutine CHESSV_MOVE_COMP
*
*   Calculate the next move in the computer.
}
procedure chessv_move_comp;            {have the computer do the next move}
  val_param;

var
  ev: rend_event_t;
  thid: sys_sys_thread_id_t;           {ID of thread to compute move}
  stat: sys_err_t;

begin
  if whmove
    then chessv_stat_msg ('chessv_prog', 'stat_move_comp_white', nil, 0)
    else chessv_stat_msg ('chessv_prog', 'stat_move_comp_black', nil, 0);

  nlmove := 0;                         {clear contemplated moves list}
  ev.dev := rendev;                    {send event for new LMOVES state}
  ev.ev_type := rend_ev_app_k;
  ev.app.i1 := ord(evtype_new_lmoves_k);
  rend_event_push (ev);

  sys_thread_create (                  {start the thread to compute the move}
    addr(thread_comp),                 {address of thread routine}
    0,                                 {arbitrary app argument, unused}
    thid,                              {returned ID of new thread}
    stat);
  if sys_error(stat) then begin
    discard( gui_message_msg_stat (    {display error message, wait for confirm}
      win_root,                        {parent window for message dialog}
      gui_msgtype_err_k,               {message type}
      stat,
      'chessv_prog', 'err_thread_comp', nil, 0) );
    end;
  end;
