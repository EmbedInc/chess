{   Program TEST_CHPOS <fnam>
*
*   Read in the chess position file and write out all possible moves for
*   both sides.
}
program test_chpos;
%include 'base.ins.pas';
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
  x, y: sys_int_machine_t;             {scratch chess square coordinate}
  i: sys_int_machine_t;                {scratch integer}
  move:                                {array of possible moves}
    array[1..maxmoves_k] of move_t;
  move_p_ar:                           {pointers to moves in sorted order}
    array[1..maxmoves_k] of move_p_t;
  nmove: sys_int_machine_t;            {number of moves in MOVE and MOVE_P_AR}
  wcov, bcov: chess_covlist_t;         {lists of pieces covering a square}
  eval: chess_eval_t;                  {move generator context}
  stat: sys_err_t;                     {completion status code}
{
*************************************************************************
*
*   Local subroutine FIND_MOVES (WHITE)
*
*   Find all the moves for white when WHITE is TRUE, and for black when
*   false.  The list of moves will be left in MOVE, with MOVE_P_AR pointing
*   to the moves in descending value (best move listed first).  NMOVE
*   will be set to the number of moves in the lists.
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
    if not white then begin            {make valuation from black's point of view ?}
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
*************************************************************************
*
*   Start of main routine.
}
begin
  fnam.max := size_char(fnam.str);     {init local var strings}
  name.max := size_char(name.str);

  string_cmline_init;                  {init for reading the command line}
  string_cmline_token (fnam, stat);    {get the input file name}
  string_cmline_req_check (stat);      {input file name is required}
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
*   Generate all the legal moves for white.
}
  writeln ('White moves:');
  find_moves (true);                   {find and sort all legal moves}
  for i := 1 to nmove do begin         {once for each move in the list}
    writeln (move_p_ar[i]^.val:8,
      '   ', move_p_ar[i]^.name.str:move_p_ar[i]^.name.len);
    end;
  writeln ('  ', nmove, ' white moves total');

  writeln;
  writeln ('Black moves:');
  find_moves (false);                  {find and sort all legal moves}
  for i := 1 to nmove do begin         {once for each move in the list}
    writeln (move_p_ar[i]^.val:8,
      '   ', move_p_ar[i]^.name.str:move_p_ar[i]^.name.len);
    end;
  writeln ('  ', nmove, ' black moves total');
{
*   Show all the squares covered by each color
}
  writeln;
  writeln ('Squares covered by white:');
  for y := 7 downto 0 do begin
    write (' ');
    for x := 0 to 7 do begin
      chess_cover_list (pos, x, y, wcov, bcov); {find pieces covering this square}
      if wcov.n = 0
        then write (' -')
        else write (wcov.n:2);
      end;                             {back for next square in this row}
    writeln;
    end;                               {back for next row}

  writeln;
  writeln ('Squares covered by black:');
  for y := 7 downto 0 do begin
    write (' ');
    for x := 0 to 7 do begin
      chess_cover_list (pos, x, y, wcov, bcov); {find pieces covering this square}
      if bcov.n = 0
        then write (' -')
        else write (bcov.n:2);
      end;
    writeln;
    end;                               {back for next row}
  end.
