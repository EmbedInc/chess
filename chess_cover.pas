{   Module of routines that deal with square coverage issues.
}
module chess_cover;
define chess_cover;
%include 'chess2.ins.pas';
{
********************************************************************************
*
*   CHESS_COVER (POS, CX, CY, WHITE)
*
*   Check whether the square CX, CY is being covered by a particular color.  The
*   color to check is white when WHITE is true, and black when false.  A square
*   is covered by a color if any of that color's pieces' possible moves project
*   onto the square.  A piece can project onto a square even if it is pinned or
*   would otherwise result in check for its own king if moved there.  The result
*   of CHESS_COVER for the square a king is on is defined to indicate exactly
*   whether that king is in check or not, if the WHITE value indicates the color
*   opposite of the king.
*
*   This routine works by looking out from the specified square looking for
*   pieces in the particular positions that could attack the square.
}
function chess_cover (                 {check whether square covered at all}
  in      pos: chess_pos_t;            {board position}
  in      cx, cy: sys_int_machine_t;   {coordinates of square to check}
  in      white: boolean)              {color to check for covering the square}
  :boolean;                            {TRUE if square being covered by given color}
  val_param;

var
  x, y: sys_int_machine_t;             {scratch square coordinate}
  adjacent: boolean;                   {TRUE for adjacent square}
  black: boolean;                      {opposite of WHITE}

label
  done_diag1, done_diag2, done_diag3, done_diag4,
  done_flat1, done_flat2, done_flat3, done_flat4,
  covered;

begin
  chess_cover := false;                {init to square not being covered}
  black := not white;                  {save opposite of WHITE}
{
*   Check for covered by pawns.  En-passant is ignored here.
}
  if white
    then begin                         {looking for white pawns}
      y := cy - 1;                     {make row pawns would have to be on}
      if y >= 1 then begin             {pawn could be on this row ?}
        x := cx + 1;                   {make X for pawn to front left}
        if
          (x <= 7) and                 {on the board ?}
          (pos.sq[y, x].piece = chess_sqr_wpawn_k) {a pawn is here ?}
          then goto covered;
        x := cx - 1;                   {make X for pawn to front right}
        if
          (x >= 0) and                 {on the board ?}
          (pos.sq[y, x].piece = chess_sqr_wpawn_k) {a pawn is here ?}
          then goto covered;
        end;
      end
    else begin                         {looking for black pawns}
      y := cy + 1;                     {make row pawns would have to be on}
      if y <= 6 then begin             {pawn could be on this row ?}
        x := cx - 1;                   {make X for pawn to front left}
        if
          (x >= 0) and                 {on the board ?}
          (pos.sq[y, x].piece = chess_sqr_bpawn_k) {a pawn is here ?}
          then goto covered;
        x := cx + 1;                   {make X for pawn to front right}
        if
          (x <= 7) and                 {on the board ?}
          (pos.sq[y, x].piece = chess_sqr_bpawn_k) {a pawn is here ?}
          then goto covered;
        end;
      end
    ;
{
*   Check the diagonals for bishop and queen, and king in immediatly adjacent
*   square.
}
  x := cx + 1;                         {first square in +X +Y direction}
  y := cy + 1;
  adjacent := true;                    {init to this square is adjacent to original}
  while (x <= 7) and (y <= 7) do begin {follow diagonal to edge of board}
    case pos.sq[y, x].piece of         {what piece is on this square ?}
chess_sqr_empty_k: ;                   {empty square}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k: begin              {white queen}
        if white then goto covered;
        goto done_diag1;
        end;
chess_sqr_wking_k: begin               {white king}
        if adjacent and white then goto covered;
        goto done_diag1;
        end;
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k: begin              {black queen}
        if black then goto covered;
        goto done_diag1;
        end;
chess_sqr_bking_k: begin               {black king}
        if adjacent and black then goto covered;
        goto done_diag1;
        end;
otherwise
      goto done_diag1;                 {bumped into non-attacking piece}
      end;
    x := x + 1;                        {make coordinates of next square}
    y := y + 1;
    adjacent := false;                 {no longer adjacent to original square}
    end;                               {back to check out this new square}
done_diag1:

  x := cx - 1;                         {first square in -X +Y direction}
  y := cy + 1;
  adjacent := true;                    {init to this square is adjacent to original}
  while (x >= 0) and (y <= 7) do begin {follow diagonal to edge of board}
    case pos.sq[y, x].piece of         {what piece is on this square ?}
chess_sqr_empty_k: ;                   {empty square}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k: begin              {white queen}
        if white then goto covered;
        goto done_diag2;
        end;
chess_sqr_wking_k: begin               {white king}
        if adjacent and white then goto covered;
        goto done_diag2;
        end;
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k: begin              {black queen}
        if black then goto covered;
        goto done_diag2;
        end;
chess_sqr_bking_k: begin               {black king}
        if adjacent and black then goto covered;
        goto done_diag2;
        end;
otherwise
      goto done_diag2;                 {bumped into non-attacking piece}
      end;
    x := x - 1;                        {make coordinates of next square}
    y := y + 1;
    adjacent := false;                 {no longer adjacent to original square}
    end;                               {back to check out this new square}
done_diag2:

  x := cx - 1;                         {first square in -X -Y direction}
  y := cy - 1;
  adjacent := true;                    {init to this square is adjacent to original}
  while (x >= 0) and (y >= 0) do begin {follow diagonal to edge of board}
    case pos.sq[y, x].piece of         {what piece is on this square ?}
chess_sqr_empty_k: ;                   {empty square}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k: begin              {white queen}
        if white then goto covered;
        goto done_diag3;
        end;
chess_sqr_wking_k: begin               {white king}
        if adjacent and white then goto covered;
        goto done_diag3;
        end;
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k: begin              {black queen}
        if black then goto covered;
        goto done_diag3;
        end;
chess_sqr_bking_k: begin               {black king}
        if adjacent and black then goto covered;
        goto done_diag3;
        end;
otherwise
      goto done_diag3;                 {bumped into non-attacking piece}
      end;
    x := x - 1;                        {make coordinates of next square}
    y := y - 1;
    adjacent := false;                 {no longer adjacent to original square}
    end;                               {back to check out this new square}
done_diag3:

  x := cx + 1;                         {first square in +X -Y direction}
  y := cy - 1;
  adjacent := true;                    {init to this square is adjacent to original}
  while (x <= 7) and (y >= 0) do begin {follow diagonal to edge of board}
    case pos.sq[y, x].piece of         {what piece is on this square ?}
chess_sqr_empty_k: ;                   {empty square}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k: begin              {white queen}
        if white then goto covered;
        goto done_diag4;
        end;
chess_sqr_wking_k: begin               {white king}
        if adjacent and white then goto covered;
        goto done_diag4;
        end;
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k: begin              {black queen}
        if black then goto covered;
        goto done_diag4;
        end;
chess_sqr_bking_k: begin               {black king}
        if adjacent and black then goto covered;
        goto done_diag4;
        end;
otherwise
      goto done_diag4;                 {bumped into non-attacking piece}
      end;
    x := x + 1;                        {make coordinates of next square}
    y := y - 1;
    adjacent := false;                 {no longer adjacent to original square}
    end;                               {back to check out this new square}
done_diag4:
{
*   Check for covered along flat sides for rook and queen, and king in
*   immediately adjacent square.
}
  x := cx + 1;                         {first square in +X direction}
  adjacent := true;                    {init to this square is adjacent to original}
  while x <= 7 do begin                {follow row to edge of board}
    case pos.sq[cy, x].piece of        {what piece is on this square ?}
chess_sqr_empty_k: ;                   {empty square}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wqueen_k: begin              {white queen}
        if white then goto covered;
        goto done_flat1;
        end;
chess_sqr_wking_k: begin               {white king}
        if adjacent and white then goto covered;
        goto done_flat1;
        end;
chess_sqr_brook_k,                     {black rook}
chess_sqr_bqueen_k: begin              {black queen}
        if black then goto covered;
        goto done_flat1;
        end;
chess_sqr_bking_k: begin               {black king}
        if adjacent and black then goto covered;
        goto done_flat1;
        end;
otherwise
      goto done_flat1;                 {bumped into non-attacking piece}
      end;
    x := x + 1;                        {make coordinates of next square}
    adjacent := false;                 {no longer adjacent to original square}
    end;                               {back to check out this new square}
done_flat1:

  y := cy + 1;                         {first square in +Y direction}
  adjacent := true;                    {init to this square is adjacent to original}
  while y <= 7 do begin                {follow column to edge of board}
    case pos.sq[y, cx].piece of        {what piece is on this square ?}
chess_sqr_empty_k: ;                   {empty square}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wqueen_k: begin              {white queen}
        if white then goto covered;
        goto done_flat2;
        end;
chess_sqr_wking_k: begin               {white king}
        if adjacent and white then goto covered;
        goto done_flat2;
        end;
chess_sqr_brook_k,                     {black rook}
chess_sqr_bqueen_k: begin              {black queen}
        if black then goto covered;
        goto done_flat2;
        end;
chess_sqr_bking_k: begin               {black king}
        if adjacent and black then goto covered;
        goto done_flat2;
        end;
otherwise
      goto done_flat2;                 {bumped into non-attacking piece}
      end;
    y := y + 1;                        {make coordinates of next square}
    adjacent := false;                 {no longer adjacent to original square}
    end;                               {back to check out this new square}
done_flat2:

  x := cx - 1;                         {first square in -X direction}
  adjacent := true;                    {init to this square is adjacent to original}
  while x >= 0 do begin                {follow row to edge of board}
    case pos.sq[cy, x].piece of        {what piece is on this square ?}
chess_sqr_empty_k: ;                   {empty square}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wqueen_k: begin              {white queen}
        if white then goto covered;
        goto done_flat3;
        end;
chess_sqr_wking_k: begin               {white king}
        if adjacent and white then goto covered;
        goto done_flat3;
        end;
chess_sqr_brook_k,                     {black rook}
chess_sqr_bqueen_k: begin              {black queen}
        if black then goto covered;
        goto done_flat3;
        end;
chess_sqr_bking_k: begin               {black king}
        if adjacent and black then goto covered;
        goto done_flat3;
        end;
otherwise
      goto done_flat3;                 {bumped into non-attacking piece}
      end;
    x := x - 1;                        {make coordinates of next square}
    adjacent := false;                 {no longer adjacent to original square}
    end;                               {back to check out this new square}
done_flat3:

  y := cy - 1;                         {first square in -Y direction}
  adjacent := true;                    {init to this square is adjacent to original}
  while y >= 0 do begin                {follow column to edge of board}
    case pos.sq[y, cx].piece of        {what piece is on this square ?}
chess_sqr_empty_k: ;                   {empty square}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wqueen_k: begin              {white queen}
        if white then goto covered;
        goto done_flat4;
        end;
chess_sqr_wking_k: begin               {white king}
        if adjacent and white then goto covered;
        goto done_flat4;
        end;
chess_sqr_brook_k,                     {black rook}
chess_sqr_bqueen_k: begin              {black queen}
        if black then goto covered;
        goto done_flat4;
        end;
chess_sqr_bking_k: begin               {black king}
        if adjacent and black then goto covered;
        goto done_flat4;
        end;
otherwise
      goto done_flat4;                 {bumped into non-attacking piece}
      end;
    y := y - 1;                        {make coordinates of next square}
    adjacent := false;                 {no longer adjacent to original square}
    end;                               {back to check out this new square}
done_flat4:
{
*   Check for a knight in any of the places a knight could attack from.
}
  if white
    then begin                         {looking for a white knight}
      x := cx + 2;
      y := cy + 1;
      if
        (x <= 7) and (y <= 7) and then
        (pos.sq[y, x].piece = chess_sqr_wknight_k)
        then goto covered;
      x := cx + 1;
      y := cy + 2;
      if
        (x <= 7) and (y <= 7) and then
        (pos.sq[y, x].piece = chess_sqr_wknight_k)
        then goto covered;
      x := cx - 1;
      y := cy + 2;
      if
        (x >= 0) and (y <= 7) and then
        (pos.sq[y, x].piece = chess_sqr_wknight_k)
        then goto covered;
      x := cx - 2;
      y := cy + 1;
      if
        (x >= 0) and (y <= 7) and then
        (pos.sq[y, x].piece = chess_sqr_wknight_k)
        then goto covered;
      x := cx - 2;
      y := cy - 1;
      if
        (x >= 0) and (y >= 0) and then
        (pos.sq[y, x].piece = chess_sqr_wknight_k)
        then goto covered;
      x := cx - 1;
      y := cy - 2;
      if
        (x >= 0) and (y >= 0) and then
        (pos.sq[y, x].piece = chess_sqr_wknight_k)
        then goto covered;
      x := cx + 1;
      y := cy - 2;
      if
        (x <= 7) and (y >= 0) and then
        (pos.sq[y, x].piece = chess_sqr_wknight_k)
        then goto covered;
      x := cx + 2;
      y := cy - 1;
      if
        (x <= 7) and (y >= 0) and then
        (pos.sq[y, x].piece = chess_sqr_wknight_k)
        then goto covered;
      end
    else begin                         {looking for a black knight}
      x := cx + 2;
      y := cy + 1;
      if
        (x <= 7) and (y <= 7) and then
        (pos.sq[y, x].piece = chess_sqr_bknight_k)
        then goto covered;
      x := cx + 1;
      y := cy + 2;
      if
        (x <= 7) and (y <= 7) and then
        (pos.sq[y, x].piece = chess_sqr_bknight_k)
        then goto covered;
      x := cx - 1;
      y := cy + 2;
      if
        (x >= 0) and (y <= 7) and then
        (pos.sq[y, x].piece = chess_sqr_bknight_k)
        then goto covered;
      x := cx - 2;
      y := cy + 1;
      if
        (x >= 0) and (y <= 7) and then
        (pos.sq[y, x].piece = chess_sqr_bknight_k)
        then goto covered;
      x := cx - 2;
      y := cy - 1;
      if
        (x >= 0) and (y >= 0) and then
        (pos.sq[y, x].piece = chess_sqr_bknight_k)
        then goto covered;
      x := cx - 1;
      y := cy - 2;
      if
        (x >= 0) and (y >= 0) and then
        (pos.sq[y, x].piece = chess_sqr_bknight_k)
        then goto covered;
      x := cx + 1;
      y := cy - 2;
      if
        (x <= 7) and (y >= 0) and then
        (pos.sq[y, x].piece = chess_sqr_bknight_k)
        then goto covered;
      x := cx + 2;
      y := cy - 1;
      if
        (x <= 7) and (y >= 0) and then
        (pos.sq[y, x].piece = chess_sqr_bknight_k)
        then goto covered;
      end
    ;
{
*   Attacks from all possible directions have been checked, and this square
*   is not covered.
}
  return;
{
*   This square is being covered.
}
covered:
  chess_cover := true;
  end;
