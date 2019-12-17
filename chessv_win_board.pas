module chessv_win_board;
define chessv_win_board_init;
define chessv_sqr_coor;
define chessv_sqr_coorp;
define chessv_coor_sqr;
define chessv_coorp_sqr;
%include 'chessv2.ins.pas';

const
  wh_red = 0.77;                       {color for white chess board square}
  wh_grn = 0.77;
  wh_blu = 0.72;
  bl_red = 0.50;                       {color for black chess board square}
  bl_grn = 0.40;
  bl_blu = 0.40;
{
*************************************************************************
*
*   Subroutine CHESSV_SQR_COORP (SQX, SQY, PX, PY)
*
*   Finds the PLAY window coordinate of the center of a chess square.
*   SQX,SQY is the 0,0 to 7,7 chess square coordinate, although it can be
*   outside this range to indicate "squares" off the chess board.
}
procedure chessv_sqr_coorp (           {make PLAY window coor of chess square center}
  in      sqx, sqy: sys_int_machine_t; {chess square coor, 0-7 if within board}
  out     px, py: real);               {PLAY window coor of chess square center}
  val_param;

var
  ix, iy: sys_int_machine_t;           {0-7 square coor from bottom of window}

begin
  if view_white
    then begin                         {viewing board from white's point of view}
      ix := sqx;
      iy := sqy;
      end
    else begin                         {viewing board from black's point of view}
      ix := 7 - sqx;
      iy := 7 - sqy;
      end
    ;

  px := (ix + 0.5) * dsquare + win_board.rect.x;
  py := (iy + 0.5) * dsquare + win_board.rect.y;
  end;
{
*************************************************************************
*
*   Subroutine CHESSV_SQR_COOR (SQX, SQY, RX, RY)
*
*   Finds the RENDlib coordinate of the center of a chess square.  SQX,SQY
*   is the 0,0 to 7,7 chess square coordinate, although it can be outside
*   this range to indicate "squares" off the chess board.
}
procedure chessv_sqr_coor (            {make RENDlib coor of chess square center}
  in      sqx, sqy: sys_int_machine_t; {chess square coor, 0-7 if within board}
  out     rx, ry: real);               {RENDlib coor of chess square center}
  val_param;

var
  ix, iy: sys_int_machine_t;           {0-7 square coor from bottom of window}

begin
  if view_white
    then begin                         {viewing board from white's point of view}
      ix := sqx;
      iy := sqy;
      end
    else begin                         {viewing board from black's point of view}
      ix := 7 - sqx;
      iy := 7 - sqy;
      end
    ;

  rx := (ix + 0.5) * dsquare + win_board.pos.x;
  ry := win_board.pos.y + win_board.rect.dy - (iy + 0.5) * dsquare;
  end;
{
*************************************************************************
*
*   Subroutine CHESSV_COORP_SQR (PX, PY, SQX, SQY)
*
*   Finds the chess square containing the PLAY window coordinates RX,RY.
*   SQX,SQY is returned the 0-7 chess square coordinates.  Note that
*   SQX,SQY will be outside the 0-7 range for coordinates outside the
*   chess board.
}
procedure chessv_coorp_sqr (           {find chess square from PLAY window coor}
  in      px, py: real;                {PLAY window coordinate}
  out     sqx, sqy: sys_int_machine_t); {chess square coor, 0-7 if within board}
  val_param;

var
  x, y: real;                          {coordinate within BOARD window}

begin
  x := px - win_board.rect.x;          {make coordinate assuming white view}
  y := py - win_board.rect.y;

  sqx := roundown (x / dsquare);
  sqy := roundown (y / dsquare);

  if not view_white then begin         {board being viewed from black side ?}
    sqx := 7 - sqx;
    sqy := 7 - sqy;
    end;
  end;
{
*************************************************************************
*
*   Subroutine CHESSV_COOR_SQR (RX, RY, SQX, SQY)
*
*   Finds the chess square containing the RENDlib coordinates RX,RY.
*   SQX,SQY is returned the 0-7 chess square coordinates.  Note that
*   SQX,SQY will be outside the 0-7 range for coordinates outside the
*   chess board.
}
procedure chessv_coor_sqr (            {find chess square containing a coordinate}
  in      rx, ry: real;                {RENDlib raw device coordinate}
  out     sqx, sqy: sys_int_machine_t); {chess square coor, 0-7 if within board}
  val_param;

var
  x, y: real;                          {coordinate within BOARD window}

begin
  x := rx - win_board.pos.x;           {make coordinate assuming white view}
  y := win_board.pos.y + win_board.rect.dy - ry;

  sqx := roundown (x / dsquare);
  sqy := roundown (y / dsquare);

  if not view_white then begin         {board being viewed from black side ?}
    sqx := 7 - sqx;
    sqy := 7 - sqy;
    end;
  end;
{
*************************************************************************
*
*   Local subroutine SQPOS (X, Y, LLX, LLY)
*
*   Find the lower left corner of a chess square.  X,Y is the chess square
*   in the 0-7 CHESS library cordinates.  LLX,LLY is returned the lower
*   left corner of the chess square within the WIN_BOARD window.
}
procedure sqpos (                      {find lower left corner of a chess square}
  in      x, y: sys_int_machine_t;     {CHESS library 0-7 coordinates of square}
  out     llx, lly: real);             {window coordinates of lower left corner}
  val_param; internal;

var
  ix, iy: sys_int_machine_t;           {0-7 coordinates from bottom of screen}

begin
  if view_white
    then begin                         {viewing board from white's point of view}
      ix := x;
      iy := y;
      end
    else begin                         {viewing board from black's point of view}
      ix := 7 - x;
      iy := 7 - y;
      end
    ;

  llx := dsquare * ix;                 {pass back coordinate within window}
  lly := dsquare * iy;
  end;
{
*************************************************************************
*
*   Subroutine CHESSV_WIN_BOARD_DRAW (WIN, APP_P)
}
procedure chessv_win_board_draw (      {drawing routine for board window}
  in out  win: gui_win_t;              {window to draw}
  in      app_p: univ_ptr);            {pointer to arbitrary application data}
  val_param; internal;

var
  ix, iy: sys_int_machine_t;           {chess square coordinate}
  llx, lly: real;                      {lower left coordinate of chess square}
  xb, yb, ofs: vect_2d_t;              {2D transform for curr square 0,0 to 1,1}
  xbo, ybo, ofso: vect_2d_t;           {saved original 2D transform}
  vp: rend_vect_parms_t;               {temporary vector control parameters}
  x1, y1, x2, y2: real;                {scratch coordinates}
  dsh: real;                           {1/2 DSQUARE}
  white: boolean;                      {TRUE if this is a white square}

begin
  dsh := dsquare * 0.5;
{
*   Clear all the squares to their background color.
}
  for iy := 0 to 7 do begin            {up the rows}
    for ix := 0 to 7 do begin          {accross this row}
      sqpos (ix, iy, llx, lly);        {find window coor of this square}
      if not gui_win_clip (win_board, llx, llx + dsquare, lly, lly + dsquare)
        then next;                     {this square completely clipped off ?}
      white := odd(ix + iy);           {TRUE if this is a white square}
      if white
        then begin                     {this is a white square}
          rend_set.rgb^ (wh_red, wh_grn, wh_blu);
          end
        else begin                     {this is a black square}
          rend_set.rgb^ (bl_red, bl_grn, bl_blu);
          end
        ;
      rend_prim.clear_cwind^;          {draw the background color for this square}
      end;                             {back for next square in this row}
    end;                               {back for next row in board}
{
*   Draw the line showing the last move, if any.
}
  if lastmove then begin               {there is a last move to show ?}
    discard( gui_win_clip (win,        {enable drawing in the whole window}
      0.0, win.rect.dx, 0.0, win.rect.dy) );
    vp := vparm;                       {init local copy of vector parameters}
    vp.poly_level := rend_space_2d_k;
    vp.start_style.style := rend_end_style_rect_k;
    vp.end_style.style := rend_end_style_rect_k;
    vp.subpixel := true;

    sqpos (move_fx, move_fy, llx, lly);
    x1 := llx + dsh;
    y1 := lly + dsh;
    sqpos (move_tx, move_ty, llx, lly);
    x2 := llx + dsh;
    y2 := lly + dsh;

    rend_set.rgb^ (0.25, 0.25, 0.25);
    vp.width := dsquare * 0.07;
    rend_set.vect_parms^ (vp);
    rend_set.cpnt_2d^ (x1, y1);
    rend_prim.vect_2d^ (x2, y2);

    rend_set.rgb^ (1.0, 0.35, 0.35);
    vp.width := dsquare * 0.04;
    rend_set.vect_parms^ (vp);
    rend_set.cpnt_2d^ (x1, y1);
    rend_prim.vect_2d^ (x2, y2);

    rend_set.vect_parms^ (vparm);      {restore vector drawing parameters}
    end;
{
*   Draw the pieces onto the squares.
}
  rend_get.xform_2d^ (xbo, ybo, ofso); {save current 2D transform}

  xb.x := xbo.x * dsquare;             {set static fields for chess square xform}
  xb.y := xbo.y * dsquare;
  yb.x := ybo.x * dsquare;
  yb.y := ybo.y * dsquare;

  for iy := 0 to 7 do begin            {up the rows}
    for ix := 0 to 7 do begin          {accross this row}
      sqpos (ix, iy, llx, lly);        {find window coor of this square}
      if not gui_win_clip (win_board, llx, llx + dsquare, lly, lly + dsquare)
        then next;                     {this square completely clipped off ?}
      ofs.x := llx * xbo.x + lly * ybo.x + ofso.x;
      ofs.y := llx * xbo.y + lly * ybo.y + ofso.y;
      rend_set.xform_2d^ (xb, yb, ofs); {set xform for square from 0,0 to 1,1}
      chessv_piece_draw (pos.sq[iy, ix]); {draw chess piece on this square}
      end;                             {back for next square in this row}
    end;                               {back for next row in board}

  rend_set.xform_2d^ (xbo, ybo, ofso); {restore original 2D transform}
  end;
{
*************************************************************************
*
*   Subroutine CHESSV_WIN_BOARD_INIT
*
*   Initialize the contents of the board window, WIN_BOARD.  The
*   window has already been created.
}
procedure chessv_win_board_init;       {init contents of chess board window}

begin
  gui_win_set_draw (                   {set drawing routine for this window}
    win_board, univ_ptr(addr(chessv_win_board_draw)));
  end;
