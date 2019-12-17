module chessv_piece_draw;
define chessv_piece_draw;
%include 'chessv2.ins.pas';

const
  maxvert = 22;                        {max verticies a polygon can have}
  sqrr = 0.0125;                       {"radius" of pawn jump two symbol square}
  sqrd = sqrr * 2.0;                   {"diameter" of pawn jump two symbol square}

type
  poly_t = record                      {polygon definition}
    n: sys_int_machine_t;              {number of verticies}
    v: array[1..maxvert] of vect_2d_t; {the verticies}
    end;
{
*************************************************************************
*
*   Local subroutine ADD_VERT (POLY, X, Y)
*
*   Add another vertex to the polygon.
}
procedure add_vert (                   {add vertex to polygon}
  in out  poly: poly_t;                {polygon definition to add vertex to}
  in      x, y: real);                 {vertex coordinate}
  val_param; internal;

begin
  if poly.n >= maxvert then return;    {no room for another vertex ?}

  poly.n := poly.n + 1;                {count one more vertex}
  poly.v[poly.n].x := x;
  poly.v[poly.n].y := y;
  end;
{
*************************************************************************
*
*   Local subroutine DISC (X, Y, R)
*
*   Draw a filled disc of radius R around the point X, Y.
}
procedure disc (
  in    x, y: real;
  in    r: real);
  val_param; internal;

const
  nsides = 20;                         {desired line segments per circle}

var
  poly: poly_t;                        {polygon}
  a: real;                             {angle}
  da: real;                            {angle increment}
  s, c: real;                          {since, cosine}
  i: sys_int_machine_t;                {loop counter}
  n: sys_int_machine_t;                {number of points in the circle}

begin
  poly.n := 0;
  add_vert (poly, x + r, y);           {starting vert at angle 0}

  n := min(nsides, maxvert);           {number of points in the circle}
  a := 0.0;
  da := 2 * 3.141592653 / n;
  for i := 2 to n do begin
    a := a + da;
    s := sin(a);
    c := cos(a);
    add_vert (poly, x + c * r, y + s * r);
    end;

  rend_prim.poly_2d^ (poly.n, poly.v);
  end;
{
*************************************************************************
}
procedure draw_pawn (
  in      colf, colo: rend_rgb_t);
  val_param; internal;

var
  poly: poly_t;                        {polygon}

begin
  rend_set.rgb^ (colf.red, colf.grn, colf.blu);

  poly.n := 0;                         {base}
  add_vert (poly, 0.65, 0.1);
  add_vert (poly, 0.55, 0.45);
  add_vert (poly, 0.45, 0.45);
  add_vert (poly, 0.35, 0.1);
  rend_prim.poly_2d^ (poly.n, poly.v);

  poly.n := 0;                         {ridge}
  add_vert (poly, 0.55, 0.45);
  add_vert (poly, 0.65, 0.5);
  add_vert (poly, 0.55, 0.55);
  add_vert (poly, 0.45, 0.55);
  add_vert (poly, 0.35, 0.5);
  add_vert (poly, 0.45, 0.45);
  rend_prim.poly_2d^ (poly.n, poly.v);

  poly.n := 0;                         {above ridge to circle}
  add_vert (poly, 0.55, 0.55);
  add_vert (poly, 0.55, 0.65);
  add_vert (poly, 0.45, 0.65);
  add_vert (poly, 0.45, 0.55);
  rend_prim.poly_2d^ (poly.n, poly.v);

  disc (0.5, 0.7, 0.12);               {top circle}
  end;
{
*************************************************************************
}
procedure draw_rook (
  in      colf, colo: rend_rgb_t);
  val_param; internal;

var
  poly: poly_t;                        {polygon}

begin
  rend_set.rgb^ (colf.red, colf.grn, colf.blu);

  poly.n := 0;                         {base}
  add_vert (poly, 0.2, 0.1);
  add_vert (poly, 0.8, 0.1);
  add_vert (poly, 0.65, 0.2);
  add_vert (poly, 0.35, 0.2);
  rend_prim.poly_2d^ (poly.n, poly.v);

  poly.n := 0;                         {column}
  add_vert (poly, 0.65, 0.2);
  add_vert (poly, 0.65, 0.55);
  add_vert (poly, 0.35, 0.55);
  add_vert (poly, 0.35, 0.2);
  rend_prim.poly_2d^ (poly.n, poly.v);

  poly.n := 0;                         {just below turrets}
  add_vert (poly, 0.65, 0.55);
  add_vert (poly, 0.8, 0.65);
  add_vert (poly, 0.8, 0.7);
  add_vert (poly, 0.2, 0.7);
  add_vert (poly, 0.2, 0.65);
  add_vert (poly, 0.35, 0.55);
  rend_prim.poly_2d^ (poly.n, poly.v);

  rend_set.cpnt_2d^ (0.2, 0.7);        {left turret}
  rend_prim.rect_2d^ (0.15, 0.1);

  rend_set.cpnt_2d^ (0.45, 0.7);       {center turret}
  rend_prim.rect_2d^ (0.10, 0.1);

  rend_set.cpnt_2d^ (0.65, 0.7);       {right turret}
  rend_prim.rect_2d^ (0.15, 0.1);
  end;
{
*************************************************************************
}
procedure draw_knight (
  in      colf, colo: rend_rgb_t);
  val_param; internal;

var
  poly: poly_t;                        {polygon}

begin
  rend_set.rgb^ (colf.red, colf.grn, colf.blu);

  poly.n := 0;                         {base}
  add_vert (poly, 0.8, 0.1);
  add_vert (poly, 0.65, 0.2);
  add_vert (poly, 0.35, 0.2);
  add_vert (poly, 0.2, 0.1);
  rend_prim.poly_2d^ (poly.n, poly.v);

  poly.n := 0;                         {neck}
  add_vert (poly, 0.65, 0.1);
  add_vert (poly, 0.8, 0.6);
  add_vert (poly, 0.5, 0.6);
  add_vert (poly, 0.35, 0.2);
  rend_prim.poly_2d^ (poly.n, poly.v);

  poly.n := 0;                         {back of head}
  add_vert (poly, 0.8, 0.6);
  add_vert (poly, 0.75, 0.7);
  add_vert (poly, 0.65, 0.8);
  add_vert (poly, 0.55, 0.8);
  add_vert (poly, 0.5, 0.6);
  rend_prim.poly_2d^ (poly.n, poly.v);

  poly.n := 0;                         {front of head}
  add_vert (poly, 0.5, 0.52);
  add_vert (poly, 0.55, 0.8);
  add_vert (poly, 0.45, 0.8);
  add_vert (poly, 0.2, 0.7);
  add_vert (poly, 0.15, 0.65);
  add_vert (poly, 0.15, 0.6);
  add_vert (poly, 0.2, 0.55);
  add_vert (poly, 0.28, 0.52);
  rend_prim.poly_2d^ (poly.n, poly.v);

  poly.n := 0;                         {ear}
  add_vert (poly, 0.65, 0.8);
  add_vert (poly, 0.65, 0.9);
  add_vert (poly, 0.55, 0.8);
  rend_prim.poly_2d^ (poly.n, poly.v);
  end;
{
*************************************************************************
}
procedure draw_bishop (
  in      colf, colo: rend_rgb_t);
  val_param; internal;

var
  poly: poly_t;                        {polygon}

begin
  rend_set.rgb^ (colf.red, colf.grn, colf.blu);

  poly.n := 0;                         {base}
  add_vert (poly, 0.8, 0.1);
  add_vert (poly, 0.55, 0.2);
  add_vert (poly, 0.45, 0.2);
  add_vert (poly, 0.2, 0.1);
  rend_prim.poly_2d^ (poly.n, poly.v);

  poly.n := 0;                         {body}
  add_vert (poly, 0.550, 0.200);
  add_vert (poly, 0.575, 0.259);
  add_vert (poly, 0.601, 0.319);
  add_vert (poly, 0.623, 0.379);
  add_vert (poly, 0.638, 0.440);
  add_vert (poly, 0.640, 0.500);
  add_vert (poly, 0.629, 0.560);
  add_vert (poly, 0.606, 0.621);
  add_vert (poly, 0.576, 0.681);
  add_vert (poly, 0.539, 0.741);
  add_vert (poly, 0.500, 0.800);
  add_vert (poly, 0.461, 0.741);
  add_vert (poly, 0.424, 0.681);
  add_vert (poly, 0.394, 0.621);
  add_vert (poly, 0.371, 0.560);
  add_vert (poly, 0.360, 0.500);
  add_vert (poly, 0.362, 0.440);
  add_vert (poly, 0.377, 0.379);
  add_vert (poly, 0.399, 0.319);
  add_vert (poly, 0.425, 0.259);
  add_vert (poly, 0.450, 0.200);
  rend_prim.poly_2d^ (poly.n, poly.v);

  disc (0.5, 0.825, 0.04);
  end;
{
*************************************************************************
}
procedure draw_queen (
  in      colf, colo: rend_rgb_t);
  val_param; internal;

var
  poly: poly_t;                        {polygon}

begin
  rend_set.rgb^ (colf.red, colf.grn, colf.blu);

  disc (0.15, 0.6, 0.030);;
  poly.n := 0;                         {spike 1}
  add_vert (poly, 0.15, 0.6);
  add_vert (poly, 0.3, 0.2);
  add_vert (poly, 0.275, 0.45);
  rend_prim.poly_2d^ (poly.n, poly.v);

  disc (0.3, 0.675, 0.035);;
  poly.n := 0;                         {spike 2}
  add_vert (poly, 0.3, 0.675);
  add_vert (poly, 0.275, 0.45);
  add_vert (poly, 0.3, 0.2);
  add_vert (poly, 0.4, 0.2);
  add_vert (poly, 0.425, 0.45);
  rend_prim.poly_2d^ (poly.n, poly.v);

  disc (0.5, 0.7, 0.04);
  poly.n := 0;                         {spike 3}
  add_vert (poly, 0.5, 0.7);
  add_vert (poly, 0.425, 0.45);
  add_vert (poly, 0.4, 0.2);
  add_vert (poly, 0.6, 0.2);
  add_vert (poly, 0.575, 0.45);
  rend_prim.poly_2d^ (poly.n, poly.v);

  disc (0.7, 0.675, 0.035);;
  poly.n := 0;                         {spike 4}
  add_vert (poly, 0.7, 0.675);
  add_vert (poly, 0.575, 0.45);
  add_vert (poly, 0.6, 0.2);
  add_vert (poly, 0.7, 0.2);
  add_vert (poly, 0.725, 0.45);
  rend_prim.poly_2d^ (poly.n, poly.v);

  disc (0.85, 0.6, 0.030);;
  poly.n := 0;                         {spike 5}
  add_vert (poly, 0.85, 0.6);
  add_vert (poly, 0.725, 0.45);
  add_vert (poly, 0.7, 0.2);
  rend_prim.poly_2d^ (poly.n, poly.v);

  end;
{
*************************************************************************
}
procedure draw_king (
  in      colf, colo: rend_rgb_t);
  val_param; internal;

var
  poly: poly_t;                        {polygon}

begin
  rend_set.rgb^ (colf.red, colf.grn, colf.blu);

  poly.n := 0;
  add_vert (poly, 0.500, 0.500);
  add_vert (poly, 0.491, 0.512);
  add_vert (poly, 0.467, 0.539);
  add_vert (poly, 0.434, 0.572);
  add_vert (poly, 0.400, 0.600);
  add_vert (poly, 0.350, 0.620);
  add_vert (poly, 0.300, 0.630);
  add_vert (poly, 0.271, 0.629);
  add_vert (poly, 0.247, 0.624);
  add_vert (poly, 0.224, 0.615);
  add_vert (poly, 0.200, 0.600);
  add_vert (poly, 0.165, 0.564);
  add_vert (poly, 0.140, 0.520);
  add_vert (poly, 0.133, 0.490);
  add_vert (poly, 0.131, 0.463);
  add_vert (poly, 0.136, 0.435);
  add_vert (poly, 0.150, 0.400);
  add_vert (poly, 0.185, 0.346);
  add_vert (poly, 0.235, 0.280);
  add_vert (poly, 0.280, 0.224);
  add_vert (poly, 0.300, 0.200);
  add_vert (poly, 0.5, 0.2);
  rend_prim.poly_2d^ (poly.n, poly.v);

  poly.n := 0;
  add_vert (poly, 0.700, 0.200);
  add_vert (poly, 0.720, 0.224);
  add_vert (poly, 0.765, 0.280);
  add_vert (poly, 0.815, 0.346);
  add_vert (poly, 0.850, 0.400);
  add_vert (poly, 0.864, 0.435);
  add_vert (poly, 0.869, 0.463);
  add_vert (poly, 0.867, 0.490);
  add_vert (poly, 0.860, 0.520);
  add_vert (poly, 0.835, 0.564);
  add_vert (poly, 0.800, 0.600);
  add_vert (poly, 0.776, 0.615);
  add_vert (poly, 0.753, 0.624);
  add_vert (poly, 0.729, 0.629);
  add_vert (poly, 0.700, 0.630);
  add_vert (poly, 0.650, 0.620);
  add_vert (poly, 0.600, 0.600);
  add_vert (poly, 0.566, 0.572);
  add_vert (poly, 0.533, 0.539);
  add_vert (poly, 0.509, 0.512);
  add_vert (poly, 0.500, 0.500);
  add_vert (poly, 0.5, 0.2);
  rend_prim.poly_2d^ (poly.n, poly.v);

  rend_set.cpnt_2d^ (0.475, 0.5);      {vertical part of cross}
  rend_prim.rect_2d^ (0.05, 0.30);

  rend_set.cpnt_2d^ (0.4, 0.675);      {horizontal part of cross}
  rend_prim.rect_2d^ (0.2, 0.05);
  end;
{
*************************************************************************
*
*   Subroutine CHESSV_PIECE_DRAW (ONSQR)
*
*   Draw the indicated chess piece.  The square to draw the piece on extends
*   from 0,0 to 1,1.
}
procedure chessv_piece_draw (          {draw a chess piece into 0,0 to 1,1 square}
  in      onsqr: chess_square_t);      {ID of what is on the square to draw}
  val_param;

var
  p: chess_sqr_k_t;                    {ID of the piece on the square}
  colf, colo: rend_rgb_t;              {foreground and outline color of piece}

begin
  p := onsqr.piece;                    {get ID of the piece on the square}
  case p of                            {which color piece is it ?}
chess_sqr_wpawn_k,                     {white pawn}
chess_sqr_wrook_k,                     {white rook}
chess_sqr_wknight_k,                   {white knight}
chess_sqr_wbishop_k,                   {white bishop}
chess_sqr_wqueen_k,                    {white queen}
chess_sqr_wking_k: begin               {white king}
      colf.red := 1.0;                 {set drawing color for piece body}
      colf.grn := 1.0;
      colf.blu := 1.0;
      colo.red := 0.35;                {set outline color}
      colo.grn := 0.35;
      colo.blu := 0.35;
      end;
chess_sqr_bpawn_k,                     {black pawn}
chess_sqr_brook_k,                     {black rook}
chess_sqr_bknight_k,                   {black knight}
chess_sqr_bbishop_k,                   {black bishop}
chess_sqr_bqueen_k,                    {black queen}
chess_sqr_bking_k: begin               {black king}
      colf.red := 0.0;                 {set drawing color for piece body}
      colf.grn := 0.0;
      colf.blu := 0.0;
      colo.red := 0.75;                {set outline color}
      colo.grn := 0.75;
      colo.blu := 0.75;
      end;
otherwise                              {empty square or unrecognized piece}
    return;
    end;

  case p of                            {which type of piece is it ?}
chess_sqr_wpawn_k: draw_pawn (colf, colo); {white pawn}
chess_sqr_wrook_k: draw_rook (colf, colo); {white rook}
chess_sqr_wknight_k: draw_knight (colf, colo); {white knight}
chess_sqr_wbishop_k: draw_bishop (colf, colo); {white bishop}
chess_sqr_wqueen_k: draw_queen (colf, colo); {white queen}
chess_sqr_wking_k: draw_king (colf, colo); {white king}
chess_sqr_bpawn_k: draw_pawn (colf, colo); {black pawn}
chess_sqr_brook_k: draw_rook (colf, colo); {black rook}
chess_sqr_bknight_k: draw_knight (colf, colo); {black knight}
chess_sqr_bbishop_k: draw_bishop (colf, colo); {black bishop}
chess_sqr_bqueen_k: draw_queen (colf, colo); {black queen}
chess_sqr_bking_k: draw_king (colf, colo); {black king}
    end;
{
*   Draw symbol to indicate the piece has never been moved.  This is only
*   relevant to casteling, so this symbol is only drawn for rooks and kings.
}
  if chess_sqrflg_orig_k in onsqr.flags then begin {this piece never moved ?}
    case p of                          {what kind of piece is it ?}
chess_sqr_wrook_k,
chess_sqr_wking_k,
chess_sqr_brook_k,
chess_sqr_bking_k: begin               {case whether this piece moved before ?}
        rend_set.cpnt_2d^ (0.95 - sqrr, 0.05 - sqrr);
        rend_prim.rect_2d^ (sqrd, sqrd);
        end;                           {end of special case pieces case}
      end;                             {end of which piece cases}
    end;
{
*   Draw the symbol for a pawn that just jumped two squares.
}
  if chess_sqrflg_pawn2_k in onsqr.flags then begin {this is pawn just jumped 2 ?}
    rend_set.cpnt_2d^ (0.95 - sqrr, 0.05 - sqrr);
    rend_prim.rect_2d^ (sqrd, sqrd);
    rend_set.cpnt_2d^ (0.90 - sqrr, 0.05 - sqrr);
    rend_prim.rect_2d^ (sqrd, sqrd);
    end;
  end;
