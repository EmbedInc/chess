{   Module of routines that read in various information from externally.
}
module chess_read;
define chess_read_pos;
%include 'chess2.ins.pas';
{
********************************************************************************
*
*   Subroutine CHESS_READ_POS (CONN, POS, STAT)
*
*   Read a chess position from a text input stream.
*
*   The position description in the input stream provides sortof a "picture" of
*   the board position.  The stream must contain lines of 8 tokens each,
*   separated by spaces.  Each token specifies the contents of one chess square.
*   The "picture" is from white's point of view.  The lines therefore represent
*   the rows from black's back row to white's back row.  The tokens accross the
*   line are for the squares of that row from white's left to white's right.
*   The input stream is case-insensitive.
*
*   The allowable tokens are:
*
*     BP  -  black pawn
*     B2  -  black pawn, just jumped 2 last move
*     BR  -  black rook
*     BN  -  black knight
*     BB  -  black bishop
*     BQ  -  black queen
*     BK  -  black king
*
*     WP  -  white pawn
*     W2  -  white pawn, just jumped 2 last move
*     WR  -  white rook
*     WN  -  white knight
*     WB  -  white bishop
*     WQ  -  white queen
*     WK  -  white king
*
*     OR  -  piece in its original position.
*
*     --  -  empty square
*
*   Unless OR is used, it will be assumed the piece has been moved at least
*   once since the start of the game.  This will effect whether castleing is
*   allowed.
*
*   The B2 and W2 tokens are used to distinguish pawns that just jumped two
*   spaces forward in the previous move.  This will effect whether the opponent
*   may use the en-passant move to capture the pawn.
*
*   As an example, the starting position would look like this, except that the
*   tokens for all non-empty squares should be replaced by OR since all pieces
*   are in their original position.
*
*     BR BN BB BQ BK BB BN BR
*     BP BP BP BP BP BP BP BP
*     -- -- -- -- -- -- -- --
*     -- -- -- -- -- -- -- --
*     -- -- -- -- -- -- -- --
*     -- -- -- -- -- -- -- --
*     WP WP WP WP WP WP WP WP
*     WR WN WB WQ WK WB WN WR
}
procedure chess_read_pos (             {read board position from text stream}
  in out  conn: file_conn_t;           {connection to input stream}
  out     pos: chess_pos_t;            {returned board position}
  out     stat: sys_err_t);            {completion status code}
  val_param;

var
  x, y: sys_int_machine_t;             {coordinates of current square}
  pick: sys_int_machine_t;             {number of token picked from list}
  buf: string_var132_t;                {one line input buffer}
  p: string_index_t;                   {BUF parse index}
  tk: string_var16_t;                  {token parsed from BUF}
  sq: chess_sqr_k_t;                   {ID for what is on this square}
  flags: chess_sqrflg_t;               {modifier flags for current square}

begin
  buf.max := size_char(buf.str);       {init local var strings}
  tk.max := size_char(tk.str);

  for y := 7 downto 0 do begin         {once for each input line}
    file_read_text (conn, buf, stat);  {read text line for this row}
    if sys_error(stat) then return;
    p := 1;                            {init BUF parse index}
    for x := 0 to 7 do begin           {once for each square in this row}
      string_token (buf, p, tk, stat); {get token for this square}
      if sys_error(stat) then begin
        sys_stat_set (chess_subsys_k, chess_stat_tk_miss_k, stat);
        sys_stat_parm_vstr (conn.tnam, stat);
        sys_stat_parm_int (conn.lnum, stat);
        return;
        end;
      string_upcase (tk);              {make upper case for keyword matching}
      string_tkpick80 (tk,
        '-- WP WR WN WB WQ WK BP BR BN BB BQ BK W2 B2 OR',
        pick);
      flags := [];                     {init to no flags apply to this square}
      case pick of
1:      sq := chess_sqr_empty_k;       {empty, no piece on this square}
2:      sq := chess_sqr_wpawn_k;       {white pawn}
3:      sq := chess_sqr_wrook_k;       {white rook}
4:      sq := chess_sqr_wknight_k;     {white knight}
5:      sq := chess_sqr_wbishop_k;     {white bishop}
6:      sq := chess_sqr_wqueen_k;      {white queen}
7:      sq := chess_sqr_wking_k;       {white king}
8:      sq := chess_sqr_bpawn_k;       {black pawn}
9:      sq := chess_sqr_brook_k;       {black rook}
10:     sq := chess_sqr_bknight_k;     {black knight}
11:     sq := chess_sqr_bbishop_k;     {black bishop}
12:     sq := chess_sqr_bqueen_k;      {black queen}
13:     sq := chess_sqr_bking_k;       {black king}

14: begin                              {white pawn, just jumped two}
  sq := chess_sqr_wpawn_k;             {white pawn}
  flags := [chess_sqrflg_pawn2_k];     {pawn just jumped two squares}
  end;

15: begin                              {black pawn, just jumped two}
  sq := chess_sqr_bpawn_k;             {black pawn}
  flags := [chess_sqrflg_pawn2_k];     {pawn just jumped two squares}
  end;

16: begin                              {piece in original position}
  flags := [chess_sqrflg_orig_k];      {piece is in its original position}
  case y of                            {which row is this ?}
0:  begin                              {white's back row}
      case x of                        {which square in back row ?}
0:      sq := chess_sqr_wrook_k;
1:      sq := chess_sqr_wknight_k;
2:      sq := chess_sqr_wbishop_k;
3:      sq := chess_sqr_wqueen_k;
4:      sq := chess_sqr_wking_k;
5:      sq := chess_sqr_wbishop_k;
6:      sq := chess_sqr_wknight_k;
7:      sq := chess_sqr_wrook_k;
        end;
      end;
1:  begin                              {white's pawn row}
      sq := chess_sqr_wpawn_k;
      end;
2, 3, 4, 5: begin                      {empty board area}
      sq := chess_sqr_empty_k;
      end;
6:  begin                              {black's pawn row}
      sq := chess_sqr_bpawn_k;
      end;
7:  begin                              {black's back row}
      case x of                        {which square in back row ?}
0:      sq := chess_sqr_brook_k;
1:      sq := chess_sqr_bknight_k;
2:      sq := chess_sqr_bbishop_k;
3:      sq := chess_sqr_bqueen_k;
4:      sq := chess_sqr_bking_k;
5:      sq := chess_sqr_bbishop_k;
6:      sq := chess_sqr_bknight_k;
7:      sq := chess_sqr_brook_k;
        end;
      end;
    end;                               {end of which row cases}
  end;                                 {end of piece in original position case}

otherwise                              {invalid chess square description token}
        sys_stat_set (chess_subsys_k, chess_stat_tk_bad_k, stat);
        sys_stat_parm_vstr (conn.tnam, stat);
        sys_stat_parm_int (conn.lnum, stat);
        sys_stat_parm_vstr (tk, stat);
        return;
        end;

      pos.sq[y, x].piece := sq;        {fill in the data for this square}
      pos.sq[y, x].flags := flags;
      end;                             {back for next square accross}

    string_token (buf, p, tk, stat);   {try to get another token from this line}
    if not sys_error(stat) then begin  {too many tokens on this line ?}
      sys_stat_set (chess_subsys_k, chess_stat_tk_ovfl_k, stat);
      sys_stat_parm_vstr (conn.tnam, stat);
      sys_stat_parm_int (conn.lnum, stat);
      return;
      end;
    end;                               {back for next row}

  pos.prev_p := nil;                   {no previous position this one derived from}
  pos.nsame := 1;                      {first position with this set of pieces}
  sys_error_none (stat);               {return with no error}
  end;
