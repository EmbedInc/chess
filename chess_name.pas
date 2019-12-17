{   Module of routines that deal with text names for various chess entities.
}
module chess_name;
define chess_name_square;
define chess_name_piece;
define chess_name_move;
%include 'chess2.ins.pas';
{
********************************************************************************
*
*   Subroutine CHESS_NAME_SQUARE (X, Y, WHITE, NAME)
*
*   Return the next name of a chess square.  X,Y is the square coordinates.  The
*   name will be from white's point of view when WHITE is true, and from black's
*   point of view when false.
}
procedure chess_name_square (          {create the text name of a chess square}
  in      x, y: sys_int_machine_t;     {coordinates of the square}
  in      white: boolean;              {name from white's point of view}
  in out  name: univ string_var_arg_t); {returned name string}
  val_param;

var
  s: string_var4_t;                    {scratch number conversion string}
  cy: sys_int_machine_t;               {Y coordinate from specified color's view}

begin
  s.max := size_char(s.str);           {init local var string}

  name.len := 0;                       {init returned name to empty}

  case x of
0:  string_appends (name, 'QR'(0));
1:  string_appends (name, 'QN'(0));
2:  string_appends (name, 'QB'(0));
3:  string_appends (name, 'Q'(0));
4:  string_appends (name, 'K'(0));
5:  string_appends (name, 'KB'(0));
6:  string_appends (name, 'KN'(0));
7:  string_appends (name, 'KR'(0));
otherwise
    string_appends (name, '?'(0));
    end;

  cy := y + 1;                         {init Y from white's point of view}
  if not white then begin              {name is from black's point of view ?}
    cy := 8 - y;
    end;
  string_f_int (s, cy);                {make Y number string}
  string_append (name, s);             {append Y number string}
  end;
{
********************************************************************************
*
*   Subroutine CHESS_NAME_PIECEA (PIECE, NAME)
*
*   Set NAME to the single letter abbreviation for the chess piece PIECE.
}
procedure chess_name_piecea (          {create chess piece abbreviation letter}
  in      piece: chess_sqr_k_t;        {ID of the chess piece}
  in out  name: univ string_var_arg_t); {returned name string}
  val_param;

begin
  case piece of                        {what piece is moving ?}
chess_sqr_wpawn_k, chess_sqr_bpawn_k: string_vstring (name, 'P', 1);
chess_sqr_wrook_k, chess_sqr_brook_k: string_vstring (name, 'R', 1);
chess_sqr_wknight_k, chess_sqr_bknight_k: string_vstring (name, 'N', 1);
chess_sqr_wbishop_k, chess_sqr_bbishop_k: string_vstring (name, 'B', 1);
chess_sqr_wqueen_k, chess_sqr_bqueen_k: string_vstring (name, 'Q', 1);
chess_sqr_wking_k, chess_sqr_bking_k: string_vstring (name, 'K', 1);
otherwise
    string_vstring (name, '?', 1);
    end;
  end;
{
********************************************************************************
*
*   Subroutine CHESS_NAME_MOVE (ST, NAME)
*
*   Return the name of the move specified in ST.  This routine creates
*   the non-algebraic name.
}
procedure chess_name_move (            {create name string from a chess move}
  in      st: chess_move_t;            {the move}
  in out  name: univ string_var_arg_t); {returned name string}
  val_param;

var
  s: string_var4_t;                    {scratch number conversion string}

begin
  s.max := size_char(s.str);           {init local var string}

  chess_name_square (                  {get name of source square}
    st.x, st.y,                        {source square coordinates}
    st.white,                          {indicates from which side's point of view}
    name);                             {returned string}

  string_append1 (name, ' ');          {add name of piece that is moving}
  chess_name_piecea (st.piece, s);
  string_append (name, s);

  if st.pos.sq[st.ly, st.lx].piece = chess_sqr_empty_k
    then begin                         {moving to an empty square}
      string_append1 (name, '-');
      end
    else begin                         {capturing a piece}
      string_append1 (name, 'x');
      chess_name_piecea (st.pos.sq[st.ly, st.lx].piece, s);
      string_append (name, s);
      string_append1 (name, ' ');
      end
    ;

  chess_name_square (                  {get name of destination square}
    st.lx, st.ly,                      {destination square coordinates}
    st.white,                          {indicates from which side's point of view}
    s);                                {returned string}
  string_append (name, s);
  end;
