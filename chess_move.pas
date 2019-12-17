{   Chess move generator.  The routines in this module deal with generating
*   legal moves from a given board position.  This contains no policies or
*   judgements.  Moves are generated strictly in accordance with the rules of
*   chess.
}
module chess_move;
define chess_move_init;
define chess_move;
%include 'chess2.ins.pas';

type
  res_k_t = int8u_t (                  {move generator restart conditions}
    res_next_square_k,                 {start at next square after X,Y}
    res_wpawnp_k,
    res_wpawn1_k,
    res_wpawn2_k,
    res_wpawnp2_k,
    res_wpawn3_k,
    res_wpawnp3_k,
    res_wpawn4_k,
    res_wpawn5_k,
    res_bpawnp_k,
    res_bpawn1_k,
    res_bpawn2_k,
    res_bpawnp2_k,
    res_bpawn3_k,
    res_bpawnp3_k,
    res_bpawn4_k,
    res_bpawn5_k,
    res_wrook1_k,
    res_wrook2_k,
    res_wrook3_k,
    res_wrook4_k,
    res_wrook5_k,
    res_wrook6_k,
    res_wrook7_k,
    res_wrook8_k,
    res_brook1_k,
    res_brook2_k,
    res_brook3_k,
    res_brook4_k,
    res_brook5_k,
    res_brook6_k,
    res_brook7_k,
    res_brook8_k,
    res_wknight1_k,
    res_wknight2_k,
    res_wknight3_k,
    res_wknight4_k,
    res_wknight5_k,
    res_wknight6_k,
    res_wknight7_k,
    res_bknight1_k,
    res_bknight2_k,
    res_bknight3_k,
    res_bknight4_k,
    res_bknight5_k,
    res_bknight6_k,
    res_bknight7_k,
    res_wbish1_k,
    res_wbish2_k,
    res_wbish3_k,
    res_wbish4_k,
    res_wbish5_k,
    res_wbish6_k,
    res_wbish7_k,
    res_wbish8_k,
    res_bbish1_k,
    res_bbish2_k,
    res_bbish3_k,
    res_bbish4_k,
    res_bbish5_k,
    res_bbish6_k,
    res_bbish7_k,
    res_bbish8_k,
    res_wking1_k,
    res_wking2_k,
    res_wking3_k,
    res_wking4_k,
    res_wking5_k,
    res_wking6_k,
    res_wking7_k,
    res_wking8_k,
    res_wking9_k,
    res_bking1_k,
    res_bking2_k,
    res_bking3_k,
    res_bking4_k,
    res_bking5_k,
    res_bking6_k,
    res_bking7_k,
    res_bking8_k,
    res_bking9_k);
{
********************************************************************************
*
*   CHESS_MOVE_INIT (POS, WHITE, ST)
*
*   Initialize for generating moves from the board position POS.  WHITE TRUE
*   indicates that white is moving, and FALSE indicates black.  ST is returned
*   the initialized move generator state.  ST must be passed to the move
*   generator to generate successive moves.
}
procedure chess_move_init (            {initialize for generating moves from pos}
  in      pos_p: chess_pos_p_t;        {points to position to generated moves from}
  in      white: boolean;              {TRUE for white moving, FALSE for black}
  out     st: chess_move_t);           {returned initialized move generator state}
  val_param;

var
  x, y: sys_int_machine_t;             {board square coordinates}

label
  found_king;

begin
  st.pos := pos_p^;                    {save starting board position}
  st.pos.prev_p := pos_p;              {save pointer to original position descriptor}
  st.pos.nsame := pos_p^.nsame + 1;    {init template for no piece changes}
  st.x := -1;                          {init coordinates of current source square}
  st.y := 0;
  st.next := ord(res_next_square_k);   {start at next square after current X,Y}
  st.lx := 0;                          {init extra private state}
  st.ly := 0;
  st.piece := chess_sqr_empty_k;
  st.white := white;                   {save whether white/black move flag}
{
*   Look for moving color's king.
}
  if white
    then begin                         {looking for white king}
      for y := 0 to 7 do begin
        for x := 7 downto 0 do begin
          if st.pos.sq[y, x].piece = chess_sqr_wking_k
            then goto found_king;
          end;
        end;
      end
    else begin                         {looking for black king}
      for y := 7 downto 0 do begin
        for x := 7 downto 0 do begin
          if st.pos.sq[y, x].piece = chess_sqr_bking_k
            then goto found_king;
          end;
        end;
      end
    ;
  st.king := false;                    {indicate moving color has no king}
  st.kx := 0;
  st.ky := 0;
  return;

found_king:                            {X,Y is coor of moving color's king}
  st.king := true;                     {indicate moving color has a king}
  st.kx := x;                          {save starting king coordinate}
  st.ky := y;
  end;
{
********************************************************************************
*
*   Function CHESS_MOVE (ST, POS)
*
*   Generate the next move given the move generator state ST.  ST will be
*   updated so that successive calls return all remaining moves not previously
*   returned.
*
*   The function returns TRUE is a move is returned.  The function returns
*   FALSE if all moves for this board position have been returned.  In that case
*   POS is undefined.
}
function chess_move (                  {generate next move from move gen state}
  in out  st: chess_move_t;            {move generator state}
  out     pos: chess_pos_t)            {board position after move}
  :boolean;                            {TRUE move generated, FALSE no move left}
  val_param;

var
  x, y: sys_int_machine_t;             {move target square coordinates}
  tx, ty: sys_int_machine_t;           {temporary square coordinates}
  kx, ky: sys_int_machine_t;           {coordinates of moving color's king}
  enp_x, enp_y: sys_int_machine_t;     {coor of captured en-passant pawn}
  cas_xs, cas_ys: sys_int_machine_t;   {coor of casteling rook source}
  cas_xd, cas_yd: sys_int_machine_t;   {coor of casteling rook destination}
  flags: chess_sqrflg_t;               {new flags for target square}
  rest: res_k_t;                       {restart condition after current move}
  enpassant: boolean;                  {move is en-passant capture}
  castle: boolean;                     {move is to castle}
  other: boolean;                      {white true/false flag for non-moving color}

label
{
*   Labels used with restart conditions.
}
  next_square,
  wpawnp,
  wpawn1,
  wpawn2,
  wpawnp2,
  wpawn3,
  wpawnp3,
  wpawn4,
  wpawn5,
  bpawnp,
  bpawn1,
  bpawn2,
  bpawnp2,
  bpawn3,
  bpawnp3,
  bpawn4,
  bpawn5,
  wrook1,
  wrook2,
  wrook3,
  wrook4,
  wrook5,
  wrook6,
  wrook7,
  wrook8,
  brook1,
  brook2,
  brook3,
  brook4,
  brook5,
  brook6,
  brook7,
  brook8,
  wknight1,
  wknight2,
  wknight3,
  wknight4,
  wknight5,
  wknight6,
  wknight7,
  bknight1,
  bknight2,
  bknight3,
  bknight4,
  bknight5,
  bknight6,
  bknight7,
  wbish1,
  wbish2,
  wbish3,
  wbish4,
  wbish5,
  wbish6,
  wbish7,
  wbish8,
  bbish1,
  bbish2,
  bbish3,
  bbish4,
  bbish5,
  bbish6,
  bbish7,
  bbish8,
  wking1,
  wking2,
  wking3,
  wking4,
  wking5,
  wking6,
  wking7,
  wking8,
  wking9,
  bking1,
  bking2,
  bking3,
  bking4,
  bking5,
  bking6,
  bking7,
  bking8,
  bking9,
{
*   Internally used labels.
}
  restart,
  pawn_white,
  pawn_black,
  rook_white,
  rook_black,
  knight_white,
  knight_black,
  bishop_white,
  bishop_black,
  king_white,
  king_black,
  found_move;

begin
  chess_move := true;                  {init to returning with a move}
  x := st.lx;                          {get coordinates of last move destination}
  y := st.ly;
  rest := res_k_t(st.next);            {get restart condition}

restart:                               {jump here after cancelled proposed move}
  kx := st.kx;                         {init moving color's king location}
  ky := st.ky;
  flags := [];                         {init flags for moved piece at dest square}
  enpassant := false;                  {init to move is not en-passant capture}
  castle := false;                     {init to move is not a castle}

  case rest of                         {different code for each restart condition}
res_next_square_k: goto next_square;
res_wpawnp_k: goto wpawnp;
res_wpawn1_k: goto wpawn1;
res_wpawn2_k: goto wpawn2;
res_wpawnp2_k: goto wpawnp2;
res_wpawn3_k: goto wpawn3;
res_wpawnp3_k: goto wpawnp3;
res_wpawn4_k: goto wpawn4;
res_wpawn5_k: goto wpawn5;
res_bpawnp_k: goto bpawnp;
res_bpawn1_k: goto bpawn1;
res_bpawn2_k: goto bpawn2;
res_bpawnp2_k: goto bpawnp2;
res_bpawn3_k: goto bpawn3;
res_bpawnp3_k: goto bpawnp3;
res_bpawn4_k: goto bpawn4;
res_bpawn5_k: goto bpawn5;
res_wrook1_k: goto wrook1;
res_wrook2_k: goto wrook2;
res_wrook3_k: goto wrook3;
res_wrook4_k: goto wrook4;
res_wrook5_k: goto wrook5;
res_wrook6_k: goto wrook6;
res_wrook7_k: goto wrook7;
res_wrook8_k: goto wrook8;
res_brook1_k: goto brook1;
res_brook2_k: goto brook2;
res_brook3_k: goto brook3;
res_brook4_k: goto brook4;
res_brook5_k: goto brook5;
res_brook6_k: goto brook6;
res_brook7_k: goto brook7;
res_brook8_k: goto brook8;
res_wknight1_k: goto wknight1;
res_wknight2_k: goto wknight2;
res_wknight3_k: goto wknight3;
res_wknight4_k: goto wknight4;
res_wknight5_k: goto wknight5;
res_wknight6_k: goto wknight6;
res_wknight7_k: goto wknight7;
res_bknight1_k: goto bknight1;
res_bknight2_k: goto bknight2;
res_bknight3_k: goto bknight3;
res_bknight4_k: goto bknight4;
res_bknight5_k: goto bknight5;
res_bknight6_k: goto bknight6;
res_bknight7_k: goto bknight7;
res_wbish1_k: goto wbish1;
res_wbish2_k: goto wbish2;
res_wbish3_k: goto wbish3;
res_wbish4_k: goto wbish4;
res_wbish5_k: goto wbish5;
res_wbish6_k: goto wbish6;
res_wbish7_k: goto wbish7;
res_wbish8_k: goto wbish8;
res_bbish1_k: goto bbish1;
res_bbish2_k: goto bbish2;
res_bbish3_k: goto bbish3;
res_bbish4_k: goto bbish4;
res_bbish5_k: goto bbish5;
res_bbish6_k: goto bbish6;
res_bbish7_k: goto bbish7;
res_bbish8_k: goto bbish8;
res_wking1_k: goto wking1;
res_wking2_k: goto wking2;
res_wking3_k: goto wking3;
res_wking4_k: goto wking4;
res_wking5_k: goto wking5;
res_wking6_k: goto wking6;
res_wking7_k: goto wking7;
res_wking8_k: goto wking8;
res_wking9_k: goto wking9;
res_bking1_k: goto bking1;
res_bking2_k: goto bking2;
res_bking3_k: goto bking3;
res_bking4_k: goto bking4;
res_bking5_k: goto bking5;
res_bking6_k: goto bking6;
res_bking7_k: goto bking7;
res_bking8_k: goto bking8;
res_bking9_k: goto bking9;
otherwise                              {this should never happen}
    chess_move := false;
    return;
    end;
{
**********
*
*   Start at next square after X,Y.
}
next_square:                           {back here to advance to next source square}
  st.x := st.x + 1;                    {advance one square accross}
  if st.x > 7 then begin               {wrap back to the next row up ?}
    st.x := 0;
    st.y := st.y + 1;
    if st.y > 7 then begin             {finished all the squares ?}
      chess_move := false;             {indicate done with all moves}
      return;
      end;
    end;
{
*   ST.X, ST.Y is the new source square to start looking for moves from.
}
  st.piece := st.pos.sq[st.y, st.x].piece; {get ID of piece on this square}

  if st.white
    then begin                         {white is moving}
      case st.piece of                 {what piece is on this square ?}
chess_sqr_wpawn_k: goto pawn_white;    {white pawn}
chess_sqr_wrook_k: goto rook_white;    {white rook}
chess_sqr_wknight_k: goto knight_white; {white knight}
chess_sqr_wbishop_k: goto bishop_white; {white bishop}
chess_sqr_wqueen_k: goto rook_white;   {white queen}
chess_sqr_wking_k: goto king_white;    {white king}
otherwise
        goto next_square;              {nothing on this square to move}
        end;
      end
    else begin                         {black is moving}
      case st.piece of                 {what piece is on this square ?}
chess_sqr_bpawn_k: goto pawn_black;    {black pawn}
chess_sqr_brook_k: goto rook_black;    {black rook}
chess_sqr_bknight_k: goto knight_black; {black knight}
chess_sqr_bbishop_k: goto bishop_black; {black bishop}
chess_sqr_bqueen_k: goto rook_black;   {black queen}
chess_sqr_bking_k: goto king_black;    {black king}
otherwise
        goto next_square;              {nothing on this square to move}
        end;
      end
    ;
{
**********
*
*   White pawn.
}
pawn_white:
{
*   Single move forwards.
}
  x := st.x;
  y := st.y + 1;
  if y > 7 then goto next_square;      {pawn at last rank (shouldn't happen)}
  if st.pos.sq[y, x].piece <> chess_sqr_empty_k
    then goto wpawn2;                  {can't move 1 or 2 ahead}
  rest := res_wpawn1_k;
  if y <> 7 then goto found_move;      {not pawn pushed to last rank ?}
{
*   Pushed to last rank, handle promotion to either knight or queen.  There
*   is no point in promoting to a rook or bishop, since a queen is a superset
*   of these.
}
  rest := res_wpawnp_k;
  st.piece := chess_sqr_wknight_k;     {promote to knight}
  goto found_move;

wpawnp:
  rest := res_wpawn2_k;
  st.piece := chess_sqr_wqueen_k;      {promote to queen}
  goto found_move;
{
*   Jump two forwards.  It has already been determined that the space
*   immediately in front is open.
}
wpawn1:
  if st.y <> 1 then goto wpawn2;       {not at original row ?}
  y := st.y + 2;
  if st.pos.sq[y, x].piece = chess_sqr_empty_k then begin
    rest := res_wpawn2_k;
    flags := [chess_sqrflg_pawn2_k];
    goto found_move;
    end;
{
*   Attack to left front.
}
wpawn2:
  st.piece := chess_sqr_wpawn_k;       {restore, could be corrupted by promotion}
  x := st.x - 1;
  y := st.y + 1;
  if x < 0 then goto wpawn3;
  rest := res_wpawn3_k;
  case st.pos.sq[y, x].piece of        {what is on this square ?}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k,                    {black queen}
chess_sqr_bking_k: begin               {black king}
      if y <> 7 then goto found_move;  {not arrived at last rank ?}

      rest := res_wpawnp2_k;
      st.piece := chess_sqr_wknight_k; {promote to knight}
      goto found_move;

wpawnp2:
      rest := res_wpawn3_k;
      st.piece := chess_sqr_wqueen_k;  {promote to queen}
      goto found_move;
      end;
    end;
{
*   Attack to right front.
}
wpawn3:
  x := st.x + 1;
  if x > 7 then goto wpawn4;
  rest := res_wpawn4_k;
  case st.pos.sq[y, x].piece of        {what is on this square ?}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k,                    {black queen}
chess_sqr_bking_k: begin               {black king}
      if y <> 7 then goto found_move;  {not arrived at last rank ?}
      rest := res_wpawnp3_k;
      st.piece := chess_sqr_wknight_k; {promote to knight}
      goto found_move;

wpawnp3:
      rest := res_wpawn4_k;
      st.piece := chess_sqr_wqueen_k;  {promote to queen}
      goto found_move;
      end;
    end;
{
*   Capture en-passant to the left.
}
wpawn4:
  if st.y <> 4 then goto next_square;  {not at right row for any en-passant ?}
  x := st.x - 1;
  if x < 0 then goto wpawn5;
  y := 5;
  if                                   {can do en-passant ?}
      (st.pos.sq[5, x].piece = chess_sqr_empty_k) and {square to move into is empty ?}
      (st.pos.sq[4, x].piece = chess_sqr_bpawn_k) and {opposing pawn in right position ?}
      (chess_sqrflg_pawn2_k in st.pos.sq[4, x].flags) {opposing pawn just jumped 2 ?}
      then begin
    rest := res_wpawn5_k;
    enpassant := true;                 {flag that this is en-passant capture}
    enp_x := x;                        {save coordinates of captured piece}
    enp_y := 4;
    goto found_move;
    end;
{
*   Capture en-passant to the right.  It has already been determined that
*   this pawn is at the right row for en-passant to be possible.
}
wpawn5:
  x := st.x + 1;
  if x > 7 then goto next_square;
  if                                   {can do en-passant ?}
      (st.pos.sq[5, x].piece = chess_sqr_empty_k) and {square to move into is empty ?}
      (st.pos.sq[4, x].piece = chess_sqr_bpawn_k) and {opposing pawn in right position ?}
      (chess_sqrflg_pawn2_k in st.pos.sq[4, x].flags) {opposing pawn just jumped 2 ?}
      then begin
    rest := res_next_square_k;
    enpassant := true;                 {flag that this is en-passant capture}
    enp_x := x;                        {save coordinates of captured piece}
    enp_y := 4;
    goto found_move;
    end;

  goto next_square;
{
**********
*
*   Black pawn.
}
pawn_black:
{
*   Single move forwards.
}
  x := st.x;
  y := st.y - 1;
  if y < 0 then goto next_square;      {pawn at last rank (shouldn't happen)}
  if st.pos.sq[y, x].piece <> chess_sqr_empty_k
    then goto bpawn2;                  {can't move 1 or 2 ahead}
  rest := res_bpawn1_k;
  if y <> 0 then goto found_move;      {not pawn pushed to last rank ?}
{
*   Pushed to last rank, handle promotion to either knight or queen.  There
*   is no point in promoting to a rook or bishop, since a queen is a superset
*   of these.
}
  rest := res_bpawnp_k;
  st.piece := chess_sqr_bknight_k;     {promote to knight}
  goto found_move;

bpawnp:
  rest := res_bpawn2_k;
  st.piece := chess_sqr_bqueen_k;      {promote to queen}
  goto found_move;
{
*   Jump two forwards.  It has already been determined that the space
*   immediately in front is open.
}
bpawn1:
  if st.y <> 6 then goto bpawn2;       {not at original row ?}
  y := st.y - 2;
  if st.pos.sq[y, x].piece = chess_sqr_empty_k then begin
    rest := res_bpawn2_k;
    flags := [chess_sqrflg_pawn2_k];
    goto found_move;
    end;
{
*   Attack to left front.
}
bpawn2:
  st.piece := chess_sqr_bpawn_k;       {restore, could be corrupted by promotion}
  x := st.x + 1;
  y := st.y - 1;
  if x > 7 then goto bpawn3;
  rest := res_bpawn3_k;
  case st.pos.sq[y, x].piece of        {what is on this square ?}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k,                    {white queen}
chess_sqr_wking_k: begin               {white king}
      if y <> 0 then goto found_move;  {not arrived at last rank ?}
      rest := res_bpawnp2_k;
      st.piece := chess_sqr_bknight_k; {promote to knight}
      goto found_move;

bpawnp2:
      rest := res_bpawn3_k;
      st.piece := chess_sqr_bqueen_k;  {promote to queen}
      goto found_move;
      end;
    end;
{
*   Attack to right front.
}
bpawn3:
  x := st.x - 1;
  if x < 0 then goto bpawn4;
  rest := res_bpawn4_k;
  case st.pos.sq[y, x].piece of        {what is on this square ?}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k,                    {white queen}
chess_sqr_wking_k: begin               {white king}
      if y <> 0 then goto found_move;  {not arrived at last rank ?}

      rest := res_bpawnp3_k;
      st.piece := chess_sqr_bknight_k; {promote to knight}
      goto found_move;

bpawnp3:
      rest := res_bpawn4_k;
      st.piece := chess_sqr_bqueen_k;  {promote to queen}
      goto found_move;
      end;
    end;
{
*   Capture en-passant to the left.
}
bpawn4:
  if st.y <> 3 then goto next_square;  {not at right row for any en-passant ?}
  x := st.x + 1;
  if x > 7 then goto bpawn5;
  y := 2;
  if                                   {can do en-passant ?}
      (st.pos.sq[2, x].piece = chess_sqr_empty_k) and {square to move into is empty ?}
      (st.pos.sq[3, x].piece = chess_sqr_wpawn_k) and {opposing pawn in right position ?}
      (chess_sqrflg_pawn2_k in st.pos.sq[3, x].flags) {opposing pawn just jumped 2 ?}
      then begin
    rest := res_bpawn5_k;
    enpassant := true;                 {flag that this is en-passant capture}
    enp_x := x;                        {save coordinates of captured piece}
    enp_y := 3;
    goto found_move;
    end;
{
*   Capture en-passant to the right.  It has already been determined that
*   this pawn is at the right row for en-passant to be possible.
}
bpawn5:
  x := st.x - 1;
  if x < 0 then goto next_square;
  if                                   {can do en-passant ?}
      (st.pos.sq[2, x].piece = chess_sqr_empty_k) and {square to move into is empty ?}
      (st.pos.sq[3, x].piece = chess_sqr_wpawn_k) and {opposing pawn in right position ?}
      (chess_sqrflg_pawn2_k in st.pos.sq[3, x].flags) {opposing pawn just jumped 2 ?}
      then begin
    rest := res_next_square_k;
    enpassant := true;                 {flag that this is en-passant capture}
    enp_x := x;                        {save coordinates of captured piece}
    enp_y := 3;
    goto found_move;
    end;

  goto next_square;
{
**********
*
*   White rook.
}
rook_white:
{
*   Check in +X direction.
}
  y := st.y;
  x := st.x;
  rest := res_wrook1_k;
wrook1:
  x := x + 1;
  if x <= 7 then begin                 {still on the board ?}
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k: goto found_move;    {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k,                    {black queen}
chess_sqr_bking_k: begin               {black king}
        rest := res_wrook2_k;
        goto found_move;
        end;
      end;
    end;
wrook2:
{
*   Check in -X direction.
}
  y := st.y;
  x := st.x;
  rest := res_wrook3_k;
wrook3:
  x := x - 1;
  if x >= 0 then begin                 {still on the board ?}
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k: goto found_move;    {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k,                    {black queen}
chess_sqr_bking_k: begin               {black king}
        rest := res_wrook4_k;
        goto found_move;
        end;
      end;
    end;
wrook4:
{
*   Check in +Y direction.
}
  y := st.y;
  x := st.x;
  rest := res_wrook5_k;
wrook5:
  y := y + 1;
  if y <= 7 then begin                 {still on the board ?}
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k: goto found_move;    {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k,                    {black queen}
chess_sqr_bking_k: begin               {black king}
        rest := res_wrook6_k;
        goto found_move;
        end;
      end;
    end;
wrook6:
{
*   Check in -Y direction.
}
  y := st.y;
  x := st.x;
  rest := res_wrook7_k;
wrook7:
  y := y - 1;
  if y >= 0 then begin                 {still on the board ?}
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k: goto found_move;    {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k,                    {black queen}
chess_sqr_bking_k: begin               {black king}
        rest := res_wrook8_k;
        goto found_move;
        end;
      end;
    end;
wrook8:

  if st.piece = chess_sqr_wqueen_k then begin {moving piece is really a queen ?}
    goto bishop_white;                 {check bishop moves also}
    end;
  goto next_square;
{
**********
*
*   Black rook.
}
rook_black:
{
*   Check in +X direction.
}
  y := st.y;
  x := st.x;
  rest := res_brook1_k;
brook1:
  x := x + 1;
  if x <= 7 then begin                 {still on the board ?}
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k: goto found_move;    {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k,                    {white queen}
chess_sqr_wking_k: begin               {white king}
        rest := res_brook2_k;
        goto found_move;
        end;
      end;
    end;
brook2:
{
*   Check in -X direction.
}
  y := st.y;
  x := st.x;
  rest := res_brook3_k;
brook3:
  x := x - 1;
  if x >= 0 then begin                 {still on the board ?}
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k: goto found_move;    {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k,                    {white queen}
chess_sqr_wking_k: begin               {white king}
        rest := res_brook4_k;
        goto found_move;
        end;
      end;
    end;
brook4:
{
*   Check in +Y direction.
}
  y := st.y;
  x := st.x;
  rest := res_brook5_k;
brook5:
  y := y + 1;
  if y <= 7 then begin                 {still on the board ?}
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k: goto found_move;    {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k,                    {white queen}
chess_sqr_wking_k: begin               {white king}
        rest := res_brook6_k;
        goto found_move;
        end;
      end;
    end;
brook6:
{
*   Check in -Y direction.
}
  y := st.y;
  x := st.x;
  rest := res_brook7_k;
brook7:
  y := y - 1;
  if y >= 0 then begin                 {still on the board ?}
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k: goto found_move;    {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k,                    {white queen}
chess_sqr_wking_k: begin               {white king}
        rest := res_brook8_k;
        goto found_move;
        end;
      end;
    end;
brook8:

  if st.piece = chess_sqr_bqueen_k then begin {moving piece is really a queen ?}
    goto bishop_black;                 {check bishop moves also}
    end;
  goto next_square;
{
**********
*
*   White knight.
}
knight_white:
  x := st.x + 2;
  y := st.y + 1;
  if (x <= 7) and (y <= 7) then begin  {target square is on the board ?}
    rest := res_wknight1_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k,                    {black queen}
chess_sqr_bking_k: goto found_move;    {black king}
      end;
    end;

wknight1:
  x := st.x + 1;
  y := st.y + 2;
  if (x <= 7) and (y <= 7) then begin  {target square is on the board ?}
    rest := res_wknight2_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k,                    {black queen}
chess_sqr_bking_k: goto found_move;    {black king}
      end;
    end;

wknight2:
  x := st.x - 1;
  y := st.y + 2;
  if (x >= 0) and (y <= 7) then begin  {target square is on the board ?}
    rest := res_wknight3_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k,                    {black queen}
chess_sqr_bking_k: goto found_move;    {black king}
      end;
    end;

wknight3:
  x := st.x - 2;
  y := st.y + 1;
  if (x >= 0) and (y <= 7) then begin  {target square is on the board ?}
    rest := res_wknight4_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k,                    {black queen}
chess_sqr_bking_k: goto found_move;    {black king}
      end;
    end;

wknight4:
  x := st.x - 2;
  y := st.y - 1;
  if (x >= 0) and (y >= 0) then begin  {target square is on the board ?}
    rest := res_wknight5_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k,                    {black queen}
chess_sqr_bking_k: goto found_move;    {black king}
      end;
    end;

wknight5:
  x := st.x - 1;
  y := st.y - 2;
  if (x >= 0) and (y >= 0) then begin  {target square is on the board ?}
    rest := res_wknight6_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k,                    {black queen}
chess_sqr_bking_k: goto found_move;    {black king}
      end;
    end;

wknight6:
  x := st.x + 1;
  y := st.y - 2;
  if (x <= 7) and (y >= 0) then begin  {target square is on the board ?}
    rest := res_wknight7_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k,                    {black queen}
chess_sqr_bking_k: goto found_move;    {black king}
      end;
    end;

wknight7:
  x := st.x + 2;
  y := st.y - 1;
  if (x <= 7) and (y >= 0) then begin  {target square is on the board ?}
    rest := res_next_square_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k,                    {black queen}
chess_sqr_bking_k: goto found_move;    {black king}
      end;
    end;

  goto next_square;
{
**********
*
*   Black knight.
}
knight_black:
  x := st.x + 2;
  y := st.y + 1;
  if (x <= 7) and (y <= 7) then begin  {target square is on the board ?}
    rest := res_bknight1_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k,                    {white queen}
chess_sqr_wking_k: goto found_move;    {white king}
      end;
    end;

bknight1:
  x := st.x + 1;
  y := st.y + 2;
  if (x <= 7) and (y <= 7) then begin  {target square is on the board ?}
    rest := res_bknight2_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k,                    {white queen}
chess_sqr_wking_k: goto found_move;    {white king}
      end;
    end;

bknight2:
  x := st.x - 1;
  y := st.y + 2;
  if (x >= 0) and (y <= 7) then begin  {target square is on the board ?}
    rest := res_bknight3_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k,                    {white queen}
chess_sqr_wking_k: goto found_move;    {white king}
      end;
    end;

bknight3:
  x := st.x - 2;
  y := st.y + 1;
  if (x >= 0) and (y <= 7) then begin  {target square is on the board ?}
    rest := res_bknight4_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k,                    {white queen}
chess_sqr_wking_k: goto found_move;    {white king}
      end;
    end;

bknight4:
  x := st.x - 2;
  y := st.y - 1;
  if (x >= 0) and (y >= 0) then begin  {target square is on the board ?}
    rest := res_bknight5_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k,                    {white queen}
chess_sqr_wking_k: goto found_move;    {white king}
      end;
    end;

bknight5:
  x := st.x - 1;
  y := st.y - 2;
  if (x >= 0) and (y >= 0) then begin  {target square is on the board ?}
    rest := res_bknight6_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k,                    {white queen}
chess_sqr_wking_k: goto found_move;    {white king}
      end;
    end;

bknight6:
  x := st.x + 1;
  y := st.y - 2;
  if (x <= 7) and (y >= 0) then begin  {target square is on the board ?}
    rest := res_bknight7_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k,                    {white queen}
chess_sqr_wking_k: goto found_move;    {white king}
      end;
    end;

bknight7:
  x := st.x + 2;
  y := st.y - 1;
  if (x <= 7) and (y >= 0) then begin  {target square is on the board ?}
    rest := res_next_square_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k,                    {white queen}
chess_sqr_wking_k: goto found_move;    {white king}
      end;
    end;

  goto next_square;
{
**********
*
*   White bishop.
}
bishop_white:
{
*   Check in +X,+Y direction.
}
  y := st.y;
  x := st.x;
  rest := res_wbish1_k;
wbish1:
  x := x + 1;
  y := y + 1;
  if (x <= 7) and (y <= 7) then begin  {still on the board ?}
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k: goto found_move;    {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k,                    {black queen}
chess_sqr_bking_k: begin               {black king}
        rest := res_wbish2_k;
        goto found_move;
        end;
      end;
    end;
wbish2:
{
*   Check in -X,+Y direction.
}
  y := st.y;
  x := st.x;
  rest := res_wbish3_k;
wbish3:
  x := x - 1;
  y := y + 1;
  if (x >= 0) and (y <= 7) then begin  {still on the board ?}
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k: goto found_move;    {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k,                    {black queen}
chess_sqr_bking_k: begin               {black king}
        rest := res_wbish4_k;
        goto found_move;
        end;
      end;
    end;
wbish4:
{
*   Check in -X,-Y direction.
}
  y := st.y;
  x := st.x;
  rest := res_wbish5_k;
wbish5:
  x := x - 1;
  y := y - 1;
  if (x >= 0) and (y >= 0) then begin  {still on the board ?}
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k: goto found_move;    {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k,                    {black queen}
chess_sqr_bking_k: begin               {black king}
        rest := res_wbish6_k;
        goto found_move;
        end;
      end;
    end;
wbish6:
{
*   Check in +X,-Y direction.
}
  y := st.y;
  x := st.x;
  rest := res_wbish7_k;
wbish7:
  x := x + 1;
  y := y - 1;
  if (x <= 7) and (y >= 0) then begin  {still on the board ?}
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k: goto found_move;    {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k,                    {black queen}
chess_sqr_bking_k: begin               {black king}
        rest := res_wbish8_k;
        goto found_move;
        end;
      end;
    end;
wbish8:

  goto next_square;
{
**********
*
*   Black bishop.
}
bishop_black:
{
*   Check in +X,+Y direction.
}
  y := st.y;
  x := st.x;
  rest := res_bbish1_k;
bbish1:
  x := x + 1;
  y := y + 1;
  if (x <= 7) and (y <= 7) then begin  {still on the board ?}
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k: goto found_move;    {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k,                    {white queen}
chess_sqr_wking_k: begin               {white king}
        rest := res_bbish2_k;
        goto found_move;
        end;
      end;
    end;
bbish2:
{
*   Check in -X,+Y direction.
}
  y := st.y;
  x := st.x;
  rest := res_bbish3_k;
bbish3:
  x := x - 1;
  y := y + 1;
  if (x >= 0) and (y <= 7) then begin  {still on the board ?}
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k: goto found_move;    {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k,                    {white queen}
chess_sqr_wking_k: begin               {white king}
        rest := res_bbish4_k;
        goto found_move;
        end;
      end;
    end;
bbish4:
{
*   Check in -X,-Y direction.
}
  y := st.y;
  x := st.x;
  rest := res_bbish5_k;
bbish5:
  x := x - 1;
  y := y - 1;
  if (x >= 0) and (y >= 0) then begin  {still on the board ?}
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k: goto found_move;    {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k,                    {white queen}
chess_sqr_wking_k: begin               {white king}
        rest := res_bbish6_k;
        goto found_move;
        end;
      end;
    end;
bbish6:
{
*   Check in +X,-Y direction.
}
  y := st.y;
  x := st.x;
  rest := res_bbish7_k;
bbish7:
  x := x + 1;
  y := y - 1;
  if (x <= 7) and (y >= 0) then begin  {still on the board ?}
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k: goto found_move;    {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k,                    {white queen}
chess_sqr_wking_k: begin               {white king}
        rest := res_bbish8_k;
        goto found_move;
        end;
      end;
    end;
bbish8:

  goto next_square;
{
**********
*
*   White king.
}
king_white:
{
*   Check the three moves in the +Y direction.
}
  y := st.y + 1;
  if y <= 7 then begin
    x := st.x;
    rest := res_wking1_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k: begin              {black queen}
        ky := y;
        goto found_move;
        end;
      end;

wking1:
    x := st.x + 1;
    if x <= 7 then begin
      rest := res_wking2_k;
      case st.pos.sq[y, x].piece of    {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k: begin              {black queen}
        kx := x;
        ky := y;
        goto found_move;
        end;
        end;
      end;

wking2:
    x := st.x - 1;
    if x >= 0 then begin
      rest := res_wking3_k;
      case st.pos.sq[y, x].piece of    {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k: begin              {black queen}
        kx := x;
        ky := y;
        goto found_move;
        end;
        end;
      end;
    end;
{
*   Check the two moves at the same Y.
}
wking3:
  y := st.y;
  x := st.x + 1;
  if x <= 7 then begin
    rest := res_wking4_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k: begin              {black queen}
        kx := x;
        goto found_move;
        end;
      end;
    end;

wking4:
  x := st.x - 1;
  if x >= 0 then begin
    rest := res_wking5_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k: begin              {black queen}
        kx := x;
        goto found_move;
        end;
      end;
    end;
{
*   Check the three moves in the -Y direction.
}
wking5:
  y := st.y - 1;
  if y >= 0 then begin
    x := st.x;
    rest := res_wking6_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k: begin              {black queen}
        ky := y;
        goto found_move;
        end;
      end;

wking6:
    x := st.x + 1;
    if x <= 7 then begin
      rest := res_wking7_k;
      case st.pos.sq[y, x].piece of    {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k: begin              {black queen}
        kx := x;
        ky := y;
        goto found_move;
        end;
        end;
      end;

wking7:
    x := st.x - 1;
    if x >= 0 then begin
      rest := res_wking8_k;
      case st.pos.sq[y, x].piece of    {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k: begin              {black queen}
        kx := x;
        ky := y;
        goto found_move;
        end;
        end;
      end;
    end;
{
*   Check for castle moves.
}
wking8:
  if                                   {any castle possible at all ?}
      (st.x = 4) and (st.y = 0) and    {at original king position ?}
      (chess_sqrflg_orig_k in st.pos.sq[0, 4].flags) and then {king never moved ?}
      (not chess_cover(st.pos, 4, 0, false)) {not casteling out of check ?}
      then begin

    if                                 {king side castle available ?}
        (st.pos.sq[0, 5].piece = chess_sqr_empty_k) and {in-between squares are empty ?}
        (st.pos.sq[0, 6].piece = chess_sqr_empty_k) and
        (st.pos.sq[0, 7].piece = chess_sqr_wrook_k) and {rook in right place ?}
        (chess_sqrflg_orig_k in st.pos.sq[0, 7].flags) and then {rook never moved ?}
        (not chess_cover (st.pos, 5, 0, false)) {not moving accross check ?}
        then begin
      rest := res_wking9_k;
      x := 6;                          {set move destination coordinates}
      y := 0;
      kx := 6;                         {update king coordinates}
      ky := 0;
      castle := true;                  {indicate this is a castle move}
      cas_xs := 7;                     {casteling rook source}
      cas_ys := 0;
      cas_xd := 5;                     {casteling rook destination}
      cas_yd := 0;
      goto found_move;
      end;

wking9:
    if                                 {queen side castle available ?}
        (st.pos.sq[0, 3].piece = chess_sqr_empty_k) and {in-between squares are empty ?}
        (st.pos.sq[0, 2].piece = chess_sqr_empty_k) and
        (st.pos.sq[0, 1].piece = chess_sqr_empty_k) and
        (st.pos.sq[0, 0].piece = chess_sqr_wrook_k) and {rook in right place ?}
        (chess_sqrflg_orig_k in st.pos.sq[0, 0].flags) and then {rook never moved ?}
        (not chess_cover (st.pos, 3, 0, false)) {not moving accross check ?}
        then begin
      rest := res_next_square_k;
      x := 2;                          {set move destination coordinates}
      y := 0;
      kx := 2;                         {update king coordinates}
      ky := 0;
      castle := true;                  {indicate this is a castle move}
      cas_xs := 0;                     {casteling rook source}
      cas_ys := 0;
      cas_xd := 3;                     {casteling rook destination}
      cas_yd := 0;
      goto found_move;
      end;
    end;

  goto next_square;
{
**********
*
*   Black king.
}
king_black:
{
*   Check the three moves in the +Y direction.
}
  y := st.y + 1;
  if y <= 7 then begin
    x := st.x;
    rest := res_bking1_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k: begin              {white queen}
        ky := y;
        goto found_move;
        end;
      end;

bking1:
    x := st.x + 1;
    if x <= 7 then begin
      rest := res_bking2_k;
      case st.pos.sq[y, x].piece of    {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k: begin              {white queen}
        kx := x;
        ky := y;
        goto found_move;
        end;
        end;
      end;

bking2:
    x := st.x - 1;
    if x >= 0 then begin
      rest := res_bking3_k;
      case st.pos.sq[y, x].piece of    {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k: begin              {white queen}
        kx := x;
        ky := y;
        goto found_move;
        end;
        end;
      end;
    end;
{
*   Check the two moves at the same Y.
}
bking3:
  y := st.y;
  x := st.x + 1;
  if x <= 7 then begin
    rest := res_bking4_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k: begin              {white queen}
        kx := x;
        goto found_move;
        end;
      end;
    end;

bking4:
  x := st.x - 1;
  if x >= 0 then begin
    rest := res_bking5_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k: begin              {white queen}
        kx := x;
        goto found_move;
        end;
      end;
    end;
{
*   Check the three moves in the -Y direction.
}
bking5:
  y := st.y - 1;
  if y >= 0 then begin
    x := st.x;
    rest := res_bking6_k;
    case st.pos.sq[y, x].piece of      {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k: begin              {white queen}
        ky := y;
        goto found_move;
        end;
      end;

bking6:
    x := st.x + 1;
    if x <= 7 then begin
      rest := res_bking7_k;
      case st.pos.sq[y, x].piece of    {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k: begin              {white queen}
        kx := x;
        ky := y;
        goto found_move;
        end;
        end;
      end;

bking7:
    x := st.x - 1;
    if x >= 0 then begin
      rest := res_bking8_k;
      case st.pos.sq[y, x].piece of    {what is on this square ?}
chess_sqr_empty_k,                     {square is empty}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k: begin              {white queen}
        kx := x;
        ky := y;
        goto found_move;
        end;
        end;
      end;
    end;
{
*   Check for castle moves.
}
bking8:
  if                                   {any castle possible at all ?}
      (st.x = 4) and (st.y = 7) and    {at original king position ?}
      (chess_sqrflg_orig_k in st.pos.sq[7, 4].flags) and then {king never moved ?}
      (not chess_cover(st.pos, 4, 7, true)) {not casteling out of check ?}
      then begin

    if                                 {king side castle available ?}
        (st.pos.sq[7, 5].piece = chess_sqr_empty_k) and {in-between squares are empty ?}
        (st.pos.sq[7, 6].piece = chess_sqr_empty_k) and
        (st.pos.sq[7, 7].piece = chess_sqr_brook_k) and {rook in right place ?}
        (chess_sqrflg_orig_k in st.pos.sq[7, 7].flags) and then {rook never moved ?}
        (not chess_cover (st.pos, 5, 7, true)) {not moving accross check ?}
        then begin
      rest := res_bking9_k;
      x := 6;                          {set move destination coordinates}
      y := 7;
      kx := 6;                         {update king coordinates}
      ky := 7;
      castle := true;                  {indicate this is a castle move}
      cas_xs := 7;                     {casteling rook source}
      cas_ys := 7;
      cas_xd := 5;                     {casteling rook destination}
      cas_yd := 7;
      goto found_move;
      end;

bking9:
    if                                 {queen side castle available ?}
        (st.pos.sq[7, 3].piece = chess_sqr_empty_k) and {in-between squares are empty ?}
        (st.pos.sq[7, 2].piece = chess_sqr_empty_k) and
        (st.pos.sq[7, 1].piece = chess_sqr_empty_k) and
        (st.pos.sq[7, 0].piece = chess_sqr_brook_k) and {rook in right place ?}
        (chess_sqrflg_orig_k in st.pos.sq[7, 0].flags) and then {rook never moved ?}
        (not chess_cover (st.pos, 3, 7, true)) {not moving accross check ?}
        then begin
      rest := res_next_square_k;
      x := 2;                          {set move destination coordinates}
      y := 7;
      kx := 2;                         {update king coordinates}
      ky := 7;
      castle := true;                  {indicate this is a castle move}
      cas_xs := 0;                     {casteling rook source}
      cas_ys := 7;
      cas_xd := 3;                     {casteling rook destination}
      cas_yd := 7;
      goto found_move;
      end;
    end;

  goto next_square;
{
**********
*
*   A candidate move has been found.  This is a final legal move unless
*   the moving color's king is now in check.
*
*   The following state has been set up by the code that jumped here:
*
*     ST.X, ST.Y  -  Source coordinates of moving piece.
*
*     X, Y  -  Destination coordinate of moving piece.
*
*     KX, KY  -  Coordinates of moving color's king after the move.
*
*     FLAGS  -  New flags for the destination square.
*
*     REST  -  Restart condition.  This is used to jump to the appropriate
*       location to generate the next move.
*
*     ENPASSANT  -  TRUE if the move is an en-passant capture.  In that
*       case, ENP_X and ENP_Y are the coordinates of the captured pawn.
*
*     CASTLE  -  TRUE if the move is a castle.  The moving piece is the king.
*       CAS_XS, CAS_YS are the rook's source coordinates, and CAS_XD, CAS_YD
*       are the rook's destination coordinates.
*
*     ST.PIECE indicates the type of piece at the destination.
}
found_move:
  pos := st.pos;                       {init new position from the template}
{
*   Clear the CHESS_SQRFLG_PAWN2_K flag from all pawns.
}
  for ty := 3 to 4 do begin            {all rows that could have pawns that jumped 2}
    for tx := 0 to 7 do begin          {accross this row}
      pos.sq[ty, tx].flags := pos.sq[ty, tx].flags - [chess_sqrflg_pawn2_k];
      end;
    end;
{
*   Check for the set of pieces changed, which can be due to a capture or
*   promotion of a pawn.  In either case, the NSAME counter is reset to 1 to
*   indicate this is the first position with this new set of pieces.
}
  if                                   {check for all reasons pieces can change}
      enpassant or                     {en-passant capture ?}
      (pos.sq[y, x].piece <> chess_sqr_empty_k) or {destination is not empty ?}
      (st.piece <> pos.sq[st.y, st.x].piece) {moving piece changed ?}
      then begin
    pos.nsame := 1;                    {reset to first position with new pieces}
    end;
{
*   Update the contents of the squares to this move.
}
  pos.sq[st.y, st.x].piece := chess_sqr_empty_k; {vacate source square}
  pos.sq[st.y, st.x].flags := [];
  pos.sq[y, x].piece := st.piece;      {move piece into destination square}
  pos.sq[y, x].flags := flags;

  if enpassant then begin              {move is an en-passant capture ?}
    pos.sq[enp_y, enp_x].piece := chess_sqr_empty_k; {vacate square of captured piece}
    pos.sq[enp_y, enp_x].flags := [];
    end;

  if castle then begin                 {move is a castle ?}
    pos.sq[cas_ys, cas_xs].piece := chess_sqr_empty_k; {vacate rook source square}
    pos.sq[cas_ys, cas_xs].flags := [];
    if cas_yd = 0                      {move rook to its destination}
      then pos.sq[cas_yd, cas_xd].piece := chess_sqr_wrook_k
      else pos.sq[cas_yd, cas_xd].piece := chess_sqr_brook_k;
    pos.sq[cas_yd, cas_xd].flags := [];
    end;
{
*   The move is not legal if the moving color's king is now in check.
}
  other := not st.white;               {make white flag for non-moving color}
  if                                   {king is in check after this move ?}
      st.king and then                 {there is a king to worry about ?}
      chess_cover(pos, kx, ky, other)  {king is covered by opponent ?}
      then begin
    goto restart;                      {don't report this move, on to next}
    end;
{
*   The move has passed all the tests.  Return to the caller with this move.
}
  st.lx := x;                          {set move destination coordinates}
  st.ly := y;
  st.next := ord(rest);                {save restart condition}
  end;
