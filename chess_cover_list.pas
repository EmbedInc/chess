module chess_cover_list;
define chess_cover_list;
%include 'chess2.ins.pas';
{
********************************************************************************
*
*   Subroutine CHESS_COVER_LIST (POS, CX, CY, WLIST, BLIST)
*
*   Find all the pieces covering a chess board square.  POS is the board
*   position.  CX, CY is the coordinate of the square inquiring about.  WLIST
*   and BLIST are returned the list of white pieces and list of black pieces,
*   respectively, covering the square.
}
procedure chess_cover_list (           {make lists of pieces covering a square}
  in      pos: chess_pos_t;            {board position}
  in      cx, cy: sys_int_machine_t;   {coordinates of square to check}
  out     wlist: chess_covlist_t;      {list of white pieces covering the square}
  out     blist: chess_covlist_t);     {list of black pieces covering the square}
  val_param;

var
  x, y: sys_int_machine_t;             {scratch square coordinate}
  adjacent: boolean;                   {TRUE for adjacent square}

begin
  wlist.n := 0;                        {init to no pieces covering the square}
  blist.n := 0;
{
*   Check the diagonals for bishop and queen, and king and pawn in
*   immediately adjacent square.
}
  x := cx + 1;                         {first square in +X +Y direction}
  y := cy + 1;
  adjacent := true;                    {init to this square is adjacent to original}
  while (x <= 7) and (y <= 7) do begin {follow diagonal to edge of board}
    case pos.sq[y, x].piece of         {what piece is on this square ?}
chess_sqr_empty_k: begin               {empty square}
        x := x + 1;                    {make coordinates of next square}
        y := y + 1;
        adjacent := false;             {no longer adjacent to original square}
        next;
        end;
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k: begin              {white queen}
        wlist.n := wlist.n + 1;
        wlist.cov[wlist.n].x := x;
        wlist.cov[wlist.n].y := y;
        end;
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k: begin              {black queen}
        blist.n := blist.n + 1;
        blist.cov[blist.n].x := x;
        blist.cov[blist.n].y := y;
        end;
chess_sqr_wking_k: begin               {white king}
        if adjacent then begin
          wlist.n := wlist.n + 1;
          wlist.cov[wlist.n].x := x;
          wlist.cov[wlist.n].y := y;
          end;
        end;
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_bking_k: begin               {black king}
        if adjacent then begin
          blist.n := blist.n + 1;
          blist.cov[blist.n].x := x;
          blist.cov[blist.n].y := y;
          end;
        end;
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k: ;                 {black knight}
      end;                             {end of which piece cases}
    exit;
    end;                               {back to check out this new square}

  x := cx - 1;                         {first square in -X +Y direction}
  y := cy + 1;
  adjacent := true;                    {init to this square is adjacent to original}
  while (x >= 0) and (y <= 7) do begin {follow diagonal to edge of board}
    case pos.sq[y, x].piece of         {what piece is on this square ?}
chess_sqr_empty_k: begin               {empty square}
        x := x - 1;                    {make coordinates of next square}
        y := y + 1;
        adjacent := false;             {no longer adjacent to original square}
        next;
        end;
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k: begin              {white queen}
        wlist.n := wlist.n + 1;
        wlist.cov[wlist.n].x := x;
        wlist.cov[wlist.n].y := y;
        end;
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k: begin              {black queen}
        blist.n := blist.n + 1;
        blist.cov[blist.n].x := x;
        blist.cov[blist.n].y := y;
        end;
chess_sqr_wking_k: begin               {white king}
        if adjacent then begin
          wlist.n := wlist.n + 1;
          wlist.cov[wlist.n].x := x;
          wlist.cov[wlist.n].y := y;
          end;
        end;
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_bking_k: begin               {black king}
        if adjacent then begin
          blist.n := blist.n + 1;
          blist.cov[blist.n].x := x;
          blist.cov[blist.n].y := y;
          end;
        end;
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k: ;                 {black knight}
      end;                             {end of which piece cases}
    exit;
    end;                               {back to check out this new square}

  x := cx - 1;                         {first square in -X -Y direction}
  y := cy - 1;
  adjacent := true;                    {init to this square is adjacent to original}
  while (x >= 0) and (y >= 0) do begin {follow diagonal to edge of board}
    case pos.sq[y, x].piece of         {what piece is on this square ?}
chess_sqr_empty_k: begin               {empty square}
        x := x - 1;                    {make coordinates of next square}
        y := y - 1;
        adjacent := false;             {no longer adjacent to original square}
        next;
        end;
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k: begin              {white queen}
        wlist.n := wlist.n + 1;
        wlist.cov[wlist.n].x := x;
        wlist.cov[wlist.n].y := y;
        end;
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k: begin              {black queen}
        blist.n := blist.n + 1;
        blist.cov[blist.n].x := x;
        blist.cov[blist.n].y := y;
        end;
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wking_k: begin               {white king}
        if adjacent then begin
          wlist.n := wlist.n + 1;
          wlist.cov[wlist.n].x := x;
          wlist.cov[wlist.n].y := y;
          end;
        end;
chess_sqr_bking_k: begin               {black king}
        if adjacent then begin
          blist.n := blist.n + 1;
          blist.cov[blist.n].x := x;
          blist.cov[blist.n].y := y;
          end;
        end;
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k: ;                 {black knight}
      end;                             {end of which piece cases}
    exit;
    end;                               {back to check out this new square}

  x := cx + 1;                         {first square in +X -Y direction}
  y := cy - 1;
  adjacent := true;                    {init to this square is adjacent to original}
  while (x <= 7) and (y >= 0) do begin {follow diagonal to edge of board}
    case pos.sq[y, x].piece of         {what piece is on this square ?}
chess_sqr_empty_k: begin               {empty square}
        x := x + 1;                    {make coordinates of next square}
        y := y - 1;
        adjacent := false;             {no longer adjacent to original square}
        next;
        end;
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k: begin              {white queen}
        wlist.n := wlist.n + 1;
        wlist.cov[wlist.n].x := x;
        wlist.cov[wlist.n].y := y;
        end;
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k: begin              {black queen}
        blist.n := blist.n + 1;
        blist.cov[blist.n].x := x;
        blist.cov[blist.n].y := y;
        end;
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wking_k: begin               {white king}
        if adjacent then begin
          wlist.n := wlist.n + 1;
          wlist.cov[wlist.n].x := x;
          wlist.cov[wlist.n].y := y;
          end;
        end;
chess_sqr_bking_k: begin               {black king}
        if adjacent then begin
          blist.n := blist.n + 1;
          blist.cov[blist.n].x := x;
          blist.cov[blist.n].y := y;
          end;
        end;
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k: ;                 {black knight}
      end;                             {end of which piece cases}
    exit;
    end;                               {back to check out this new square}
{
*   Check for covered along flat sides for rook and queen, and king in
*   immediately adjacent square.
}
  x := cx + 1;                         {first square in +X direction}
  y := cy;
  adjacent := true;                    {init to this square is adjacent to original}
  while x <= 7 do begin                {follow row to edge of board}
    case pos.sq[y, x].piece of         {what piece is on this square ?}
chess_sqr_empty_k: begin               {empty square}
        x := x + 1;                    {make coordinates of next square}
        adjacent := false;             {no longer adjacent to original square}
        next;
        end;
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wqueen_k: begin              {white queen}
        wlist.n := wlist.n + 1;
        wlist.cov[wlist.n].x := x;
        wlist.cov[wlist.n].y := y;
        end;
chess_sqr_brook_k,                     {black rook}
chess_sqr_bqueen_k: begin              {black queen}
        blist.n := blist.n + 1;
        blist.cov[blist.n].x := x;
        blist.cov[blist.n].y := y;
        end;
chess_sqr_wking_k: begin               {white king}
        if adjacent then begin
          wlist.n := wlist.n + 1;
          wlist.cov[wlist.n].x := x;
          wlist.cov[wlist.n].y := y;
          end;
        end;
chess_sqr_bking_k: begin               {black king}
        if adjacent then begin
          blist.n := blist.n + 1;
          blist.cov[blist.n].x := x;
          blist.cov[blist.n].y := y;
          end;
        end;
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_bknight_k: ;                 {black knight}
      end;                             {end of which piece cases}
    exit;
    end;                               {back to check out this new square}

  x := cx - 1;                         {first square in -X direction}
  y := cy;
  adjacent := true;                    {init to this square is adjacent to original}
  while x >= 0 do begin                {follow row to edge of board}
    case pos.sq[y, x].piece of         {what piece is on this square ?}
chess_sqr_empty_k: begin               {empty square}
        x := x - 1;                    {make coordinates of next square}
        adjacent := false;             {no longer adjacent to original square}
        next;
        end;
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wqueen_k: begin              {white queen}
        wlist.n := wlist.n + 1;
        wlist.cov[wlist.n].x := x;
        wlist.cov[wlist.n].y := y;
        end;
chess_sqr_brook_k,                     {black rook}
chess_sqr_bqueen_k: begin              {black queen}
        blist.n := blist.n + 1;
        blist.cov[blist.n].x := x;
        blist.cov[blist.n].y := y;
        end;
chess_sqr_wking_k: begin               {white king}
        if adjacent then begin
          wlist.n := wlist.n + 1;
          wlist.cov[wlist.n].x := x;
          wlist.cov[wlist.n].y := y;
          end;
        end;
chess_sqr_bking_k: begin               {black king}
        if adjacent then begin
          blist.n := blist.n + 1;
          blist.cov[blist.n].x := x;
          blist.cov[blist.n].y := y;
          end;
        end;
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_bknight_k: ;                 {black knight}
      end;                             {end of which piece cases}
    exit;
    end;                               {back to check out this new square}

  x := cx;                             {first square in +Y direction}
  y := cy + 1;
  adjacent := true;                    {init to this square is adjacent to original}
  while y <= 7 do begin                {follow row to edge of board}
    case pos.sq[y, x].piece of         {what piece is on this square ?}
chess_sqr_empty_k: begin               {empty square}
        y := y + 1;                    {make coordinates of neyt square}
        adjacent := false;             {no longer adjacent to original square}
        next;
        end;
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wqueen_k: begin              {white queen}
        wlist.n := wlist.n + 1;
        wlist.cov[wlist.n].x := x;
        wlist.cov[wlist.n].y := y;
        end;
chess_sqr_brook_k,                     {black rook}
chess_sqr_bqueen_k: begin              {black queen}
        blist.n := blist.n + 1;
        blist.cov[blist.n].x := x;
        blist.cov[blist.n].y := y;
        end;
chess_sqr_wking_k: begin               {white king}
        if adjacent then begin
          wlist.n := wlist.n + 1;
          wlist.cov[wlist.n].x := x;
          wlist.cov[wlist.n].y := y;
          end;
        end;
chess_sqr_bking_k: begin               {black king}
        if adjacent then begin
          blist.n := blist.n + 1;
          blist.cov[blist.n].x := x;
          blist.cov[blist.n].y := y;
          end;
        end;
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_bknight_k: ;                 {black knight}
      end;                             {end of which piece cases}
    exit;
    end;                               {back to check out this new square}

  x := cx;                             {first square in -Y direction}
  y := cy - 1;
  adjacent := true;                    {init to this square is adjacent to original}
  while y >= 0 do begin                {follow row to edge of board}
    case pos.sq[y, x].piece of         {what piece is on this square ?}
chess_sqr_empty_k: begin               {empty square}
        y := y - 1;                    {make coordinates of neyt square}
        adjacent := false;             {no longer adjacent to original square}
        next;
        end;
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wqueen_k: begin              {white queen}
        wlist.n := wlist.n + 1;
        wlist.cov[wlist.n].x := x;
        wlist.cov[wlist.n].y := y;
        end;
chess_sqr_brook_k,                     {black rook}
chess_sqr_bqueen_k: begin              {black queen}
        blist.n := blist.n + 1;
        blist.cov[blist.n].x := x;
        blist.cov[blist.n].y := y;
        end;
chess_sqr_wking_k: begin               {white king}
        if adjacent then begin
          wlist.n := wlist.n + 1;
          wlist.cov[wlist.n].x := x;
          wlist.cov[wlist.n].y := y;
          end;
        end;
chess_sqr_bking_k: begin               {black king}
        if adjacent then begin
          blist.n := blist.n + 1;
          blist.cov[blist.n].x := x;
          blist.cov[blist.n].y := y;
          end;
        end;
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_bknight_k: ;                 {black knight}
      end;                             {end of which piece cases}
    exit;
    end;                               {back to check out this new square}
{
*   Check for a knight in any of the places a knight could attack from.
}
  x := cx + 2;
  y := cy + 1;
  if (x <= 7) and (y <= 7) then begin
    case pos.sq[y, x].piece of         {what piece is on this square ?}
chess_sqr_wknight_k: begin             {white knight}
        wlist.n := wlist.n + 1;
        wlist.cov[wlist.n].x := x;
        wlist.cov[wlist.n].y := y;
        end;
chess_sqr_bknight_k: begin             {black knight}
        blist.n := blist.n + 1;
        blist.cov[blist.n].x := x;
        blist.cov[blist.n].y := y;
        end;
      end;
    end;

  x := cx + 1;
  y := cy + 2;
  if (x <= 7) and (y <= 7) then begin
    case pos.sq[y, x].piece of         {what piece is on this square ?}
chess_sqr_wknight_k: begin             {white knight}
        wlist.n := wlist.n + 1;
        wlist.cov[wlist.n].x := x;
        wlist.cov[wlist.n].y := y;
        end;
chess_sqr_bknight_k: begin             {black knight}
        blist.n := blist.n + 1;
        blist.cov[blist.n].x := x;
        blist.cov[blist.n].y := y;
        end;
      end;
    end;

  x := cx - 1;
  y := cy + 2;
  if (x >= 0) and (y <= 7) then begin
    case pos.sq[y, x].piece of         {what piece is on this square ?}
chess_sqr_wknight_k: begin             {white knight}
        wlist.n := wlist.n + 1;
        wlist.cov[wlist.n].x := x;
        wlist.cov[wlist.n].y := y;
        end;
chess_sqr_bknight_k: begin             {black knight}
        blist.n := blist.n + 1;
        blist.cov[blist.n].x := x;
        blist.cov[blist.n].y := y;
        end;
      end;
    end;

  x := cx - 2;
  y := cy + 1;
  if (x >= 0) and (y <= 7) then begin
    case pos.sq[y, x].piece of         {what piece is on this square ?}
chess_sqr_wknight_k: begin             {white knight}
        wlist.n := wlist.n + 1;
        wlist.cov[wlist.n].x := x;
        wlist.cov[wlist.n].y := y;
        end;
chess_sqr_bknight_k: begin             {black knight}
        blist.n := blist.n + 1;
        blist.cov[blist.n].x := x;
        blist.cov[blist.n].y := y;
        end;
      end;
    end;

  x := cx - 2;
  y := cy - 1;
  if (x >= 0) and (y >= 0) then begin
    case pos.sq[y, x].piece of         {what piece is on this square ?}
chess_sqr_wknight_k: begin             {white knight}
        wlist.n := wlist.n + 1;
        wlist.cov[wlist.n].x := x;
        wlist.cov[wlist.n].y := y;
        end;
chess_sqr_bknight_k: begin             {black knight}
        blist.n := blist.n + 1;
        blist.cov[blist.n].x := x;
        blist.cov[blist.n].y := y;
        end;
      end;
    end;

  x := cx - 1;
  y := cy - 2;
  if (x >= 0) and (y >= 0) then begin
    case pos.sq[y, x].piece of         {what piece is on this square ?}
chess_sqr_wknight_k: begin             {white knight}
        wlist.n := wlist.n + 1;
        wlist.cov[wlist.n].x := x;
        wlist.cov[wlist.n].y := y;
        end;
chess_sqr_bknight_k: begin             {black knight}
        blist.n := blist.n + 1;
        blist.cov[blist.n].x := x;
        blist.cov[blist.n].y := y;
        end;
      end;
    end;

  x := cx + 1;
  y := cy - 2;
  if (x <= 7) and (y >= 0) then begin
    case pos.sq[y, x].piece of         {what piece is on this square ?}
chess_sqr_wknight_k: begin             {white knight}
        wlist.n := wlist.n + 1;
        wlist.cov[wlist.n].x := x;
        wlist.cov[wlist.n].y := y;
        end;
chess_sqr_bknight_k: begin             {black knight}
        blist.n := blist.n + 1;
        blist.cov[blist.n].x := x;
        blist.cov[blist.n].y := y;
        end;
      end;
    end;

  x := cx + 2;
  y := cy - 1;
  if (x <= 7) and (y >= 0) then begin
    case pos.sq[y, x].piece of         {what piece is on this square ?}
chess_sqr_wknight_k: begin             {white knight}
        wlist.n := wlist.n + 1;
        wlist.cov[wlist.n].x := x;
        wlist.cov[wlist.n].y := y;
        end;
chess_sqr_bknight_k: begin             {black knight}
        blist.n := blist.n + 1;
        blist.cov[blist.n].x := x;
        blist.cov[blist.n].y := y;
        end;
      end;
    end;
  end;
