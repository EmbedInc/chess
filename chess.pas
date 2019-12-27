{   Program CHESS <fnam> (B | W)
*
*   Read in the chess position file and suggest the next move for either
*   black or white.
}
program test_chpos;
%include 'sys.ins.pas';
%include 'util.ins.pas';
%include 'string.ins.pas';
%include 'file.ins.pas';
%include 'chess.ins.pas';

const
  maxmoves_k = 150;                    {max moves can store state for}

type
  move_t = record                      {info kept about one move}
    val: sys_int_machine_t;            {evaluation of this move}
    name: string_var16_t;              {name for this move}
    end;
  move_p_t = ^move_t;

var
  fnam: string_treename_t;             {input file name}
  name: string_var80_t;                {chess move name string}
  conn: file_conn_t;                   {connection to input file name}
  pos: chess_pos_t;                    {original chess board position}
  st: chess_move_t;                    {move generator state}
  i: sys_int_machine_t;                {scratch integer}
  r: real;                             {scratch floating point number}
  timer: sys_timer_t;                  {stopwatch}
  move:                                {array of possible moves}
    array[1..maxmoves_k] of move_t;
  move_p_ar:                           {pointers to moves in sorted order}
    array[1..maxmoves_k] of move_p_t;
  nmove: sys_int_machine_t;            {number of moves in MOVE and MOVE_P_AR}
  pick: sys_int_machine_t;             {number of token picked from list}
  eval: chess_eval_t;                  {move generator context}
  white: boolean;                      {TRUE if white is moving}
  stat: sys_err_t;                     {completion status code}
{
********************************************************************************
*
*   Local subroutine FIND_MOVES (WHITE)
*
*   Find all the moves for white when WHITE is TRUE, and for black when false.
*   The list of moves will be left in MOVE, with MOVE_P_AR pointing to the moves
*   in descending value (best move listed first).  NMOVE will be set to the
*   number of moves in the lists.
*
*   The static fields in the MOVE array must already be initialized.
}
procedure find_moves (                 {find and evaluate moves for a color}
  in      white: boolean);             {do moves for white on TRUE, black on FALSE}
  val_param;

var
  i, j: sys_int_machine_t;             {scratch integers}
  pos2: chess_pos_t;                   {board position}
  p: univ_ptr;                         {scratch pointer}
  opp: boolean;                        {WHITE flag for opponent}

begin
  nmove := 0;                          {init number of moves found}
  chess_move_init (addr(pos), white, st); {init for finding moves}
  opp := not white;                    {make WHITE flag for opponent}
{
*   Build the list of moves in MOVE.  Init the pointers in MOVE_P_AR
*   to point to the moves in arbitrary order.
}
  while chess_move(st, pos2) do begin  {once for each move}
    nmove := nmove + 1;                {count one more legal move found}
    chess_name_move (st, move[nmove].name); {save name for this move}
    move[nmove].val :=                 {save evaluation of this move}
      eval.eval_move_p^ (addr(eval), pos2, opp);
    if not white then begin            {flip valuation for black}
      move[nmove].val := -move[nmove].val;
      end;
    move_p_ar[nmove] := addr(move[nmove]); {init pointer to this slot}
    end;                               {back for next move}
{
*   Sort the pointers in MOVE_P_AR to point to the moves in order of
*   descending valuation.
}
  for i := 1 to nmove-1 do begin       {once for each pointer to set}
    for j := i + 1 to nmove do begin   {once for each entry to compare I entry to}
      if move_p_ar[j]^.val > move_p_ar[i]^.val then begin {found better entry ?}
        p := move_p_ar[i];             {flip I and J entries}
        move_p_ar[i] := move_p_ar[j];
        move_p_ar[j] := p;
        end;
      end;                             {back for next other entry this main ent}
    end;                               {back for next main entry}
  end;
{
********************************************************************************
*
*   Start of main routine.
}
begin
  fnam.max := size_char(fnam.str);     {init local var strings}
  name.max := size_char(name.str);

  string_cmline_init;                  {init for reading the command line}
  string_cmline_token (fnam, stat);    {get the input file name}
  string_cmline_req_check (stat);      {input file name is required}

  string_cmline_token (name, stat);    {get B or W token}
  string_cmline_req_check (stat);      {input file name is required}
  string_upcase (name);
  string_tkpick80 (name, 'W B', pick); {pick token from list}
  case pick of
1:  white := true;
2:  white := false;
otherwise
    writeln ('Bad command line argument "', name.str:name.len, '"');
    sys_bomb;
    end;

  string_cmline_end_abort;             {no additional command line arguments allowed}

  file_open_read_text (                {open input file for text read}
    fnam, '.chp ""',                   {input file name and suffix}
    conn,                              {returned connection to the file}
    stat);
  sys_error_abort (stat, '', '', nil, 0);

  chess_read_pos (conn, pos, stat);    {read board position from input file}
  sys_error_abort (stat, '', '', nil, 0);

  file_close (conn);                   {close the input file}
{
*   The input board position is in POS.
*
*   Initialize the MOVE array static values.
}
  for nmove := 1 to maxmoves_k do begin {once for each array element}
    move[nmove].name.max := size_char(move[nmove].name.str); {init var string}
    end;

  chess_eval_init (eval, stat);        {init move generator}
  sys_error_abort (stat, '', '', nil, 0);
{
*   Generate all the legal moves.
}
  sys_timer_init (timer);              {initialize stopwatch}

  sys_timer_start (timer);             {start the stopwatch}
  find_moves (white);                  {find and sort all legal moves}
  sys_timer_stop (timer);              {stop the stopwatch}

  writeln ('Legal moves:');
  for i := 1 to nmove do begin         {once for each move in the list}
    writeln (move_p_ar[i]^.val:8,
      '   ', move_p_ar[i]^.name.str:move_p_ar[i]^.name.len);
    end;
  r := sys_timer_sec(timer) / 60.0;
  writeln ('  ', nmove, ' moves examined in', r:6:2, ' minutes');
  end.
