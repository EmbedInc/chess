{   Module of routines that deal with compressed position descriptors.
}
module chess_posc;
define chess_pos_posc;
define chess_posc_pos;
%include '/cognivision_links/dsee_libs/game/chess2.ins.pas';
{
*************************************************************************
*
*   Subroutine CHESS_POS_POSC (POS, POSC)
*
*   Create the compressed position descriptor POSC from the uncompressed
*   position POS.
}
procedure chess_pos_posc (             {make compressed position from uncompressed}
  in      pos: chess_pos_t;            {uncompressed position descriptor}
  out     posc: chess_posc_t);         {compressed position descriptor}
  val_param;

var
  x, y: sys_int_machine_t;             {coordinates of current square}
  ic: sys_int_machine_t;               {current index into compressed array}
  high: boolean;                       {curr square is high nibble of compressed}
  nib: sys_int_machine_t;              {compressed nibble value}
  nibh: sys_int_machine_t;             {saved compressed high nibble value}

label
  got_nib;

begin
  ic := 0;                             {init compressed array index}
  high := true;                        {init nibble within compressed array entry}
  for y := 0 to 7 do begin             {up the rows from white to black}
    for x := 0 to 7 do begin           {from white's left to right}
      if chess_sqrflg_orig_k in pos[y, x].flags then begin {piece in original pos ?}
        nib := ord(chess_sq_orig_k);
        goto got_nib;
        end;
      nib := ord(pos[y, x].piece);     {init piece ID here}
      if chess_sqrflg_pawn2_k in pos[y, x].flags then begin {pawn just jumped 2 ?}
        if nib = ord(chess_sq_wpawn_k)
          then begin                   {white pawn, just jumped 2 last move}
            nib := ord(chess_sq_wpawn2_k);
            end
          else begin                   {black pawn, just jumped 2 last move}
            nib := ord(chess_sq_bpawn2_k);
            end
          ;
        end;
got_nib:                               {NIB is all filled in}
      if high
        then begin                     {going into high nibble}
          nibh := nib;                 {save high nibble for when writing low nibble}
          high := false;               {next value goes into low nibble}
          end
        else begin                     {going into low nibble}
          posc[ic] := lshft(nibh, 4) ! nib; {merge nibble values and save}
          high := true;                {next value goes into high nibble}
          ic := ic + 1;                {next value goes into next array entry}
          end
        ;
      end;                             {back for next source square accross}
    end;                               {back for next source row up}
  end;
{
*************************************************************************
*
*   Subroutine CHESS_POSC_POS (POSC, POS)
*
*   Create the uncompressed position descriptor POS from the compressed
*   position descriptor POSC.
}
procedure chess_posc_pos (             {make uncompressed position from compressed}
  in      posc: chess_posc_t;          {compressed position descriptor}
  out     pos: chess_pos_t);           {uncompressed position descriptor}
  val_param;

var
  x, y: sys_int_machine_t;             {coordinates of current square}
  ic: sys_int_machine_t;               {current index into compressed array}
  nib: sys_int_machine_t;              {compressed nibble value}
  high: boolean;                       {curr square is high nibble of compressed}

begin
  ic := 0;                             {init compressed array index}
  high := true;                        {init nibble within compressed array entry}
  for y := 0 to 7 do begin             {up the rows from white to black}
    for x := 0 to 7 do begin           {from white's left to right}
      if high
        then begin                     {this value comes from high nibble}
          nib := rshft(posc[ic], 4);
          high := false;               {update for next time}
          end
        else begin                     {this value comes from low nibble}
          nib := posc[ic] & 15;
          high := true;                {update for next time}
          ic := ic + 1;
          end
        ;
      pos[y, x].flags := [];           {init to no modifier flags apply}
      case nib of                      {what is this nibble value ?}
ord(chess_sq_empty_k): begin           {empty, no piece on this square}
  pos[y, x].piece := chess_sqr_empty_k;
  end;
ord(chess_sq_wpawn_k): begin           {white pawn}
  pos[y, x].piece := chess_sqr_wpawn_k;
  end;
ord(chess_sq_wrook_k): begin           {white rook}
  pos[y, x].piece := chess_sqr_wrook_k;
  end;
ord(chess_sq_wknight_k): begin         {white knight}
  pos[y, x].piece := chess_sqr_wknight_k;
  end;
ord(chess_sq_wbishop_k): begin         {white bishop}
  pos[y, x].piece := chess_sqr_wbishop_k;
  end;
ord(chess_sq_wqueen_k): begin          {white queen}
  pos[y, x].piece := chess_sqr_wqueen_k;
  end;
ord(chess_sq_wking_k): begin           {white king}
  pos[y, x].piece := chess_sqr_wking_k;
  end;
ord(chess_sq_bpawn_k): begin           {black pawn}
  pos[y, x].piece := chess_sqr_bpawn_k;
  end;
ord(chess_sq_brook_k): begin           {black rook}
  pos[y, x].piece := chess_sqr_brook_k
  end;
ord(chess_sq_bknight_k): begin         {black knight}
  pos[y, x].piece := chess_sqr_bknight_k;
  end;
ord(chess_sq_bbishop_k): begin         {black bishop}
  pos[y, x].piece := chess_sqr_bbishop_k;
  end;
ord(chess_sq_bqueen_k): begin          {black queen}
  pos[y, x].piece := chess_sqr_bqueen_k;
  end;
ord(chess_sq_bking_k): begin           {black king}
  pos[y, x].piece := chess_sqr_bking_k;
  end;
ord(chess_sq_wpawn2_k): begin          {white pawn, just jumped two}
  pos[y, x].piece := chess_sqr_wpawn_k;
  pos[y, x].flags := [chess_sqrflg_pawn2_k];
  end;
ord(chess_sq_bpawn2_k): begin          {black pawn, just jumped two}
  pos[y, x].piece := chess_sqr_bpawn_k;
  pos[y, x].flags := [chess_sqrflg_pawn2_k];
  end;
ord(chess_sq_orig_k): begin            {piece unmoved from original position}
  pos[y, x].flags := [chess_sqrflg_orig_k]; {indicate piece never moved}
  case y of                            {which row is this piece on ?}
0:  begin                              {white's back row}
      case x of                        {which square in the row ?}
0:      pos[y, x].piece := chess_sqr_wrook_k;
1:      pos[y, x].piece := chess_sqr_wknight_k;
2:      pos[y, x].piece := chess_sqr_wbishop_k;
3:      pos[y, x].piece := chess_sqr_wqueen_k;
4:      pos[y, x].piece := chess_sqr_wking_k;
5:      pos[y, x].piece := chess_sqr_wbishop_k;
6:      pos[y, x].piece := chess_sqr_wknight_k;
7:      pos[y, x].piece := chess_sqr_wrook_k;
        end;
      end;
1: begin                               {white's pawn row}
      pos[y, x].piece := chess_sqr_wpawn_k;
      end;
6: begin                               {black's pawn row}
      pos[y, x].piece := chess_sqr_bpawn_k;
      end;
7: begin                               {black's back row}
      case x of                        {which square in the row ?}
0:      pos[y, x].piece := chess_sqr_brook_k;
1:      pos[y, x].piece := chess_sqr_bknight_k;
2:      pos[y, x].piece := chess_sqr_bbishop_k;
3:      pos[y, x].piece := chess_sqr_bqueen_k;
4:      pos[y, x].piece := chess_sqr_bking_k;
5:      pos[y, x].piece := chess_sqr_bbishop_k;
6:      pos[y, x].piece := chess_sqr_bknight_k;
7:      pos[y, x].piece := chess_sqr_brook_k;
        end;
      end;
otherwise
    pos[y, x].piece := chess_sqr_empty_k;
    pos[y, x].flags := [];
    end;                               {end of row cases}
  end;                                 {end of piece in original position case}
        end;                           {end of compressed square content ID cases}
      end;                             {back for next source square accross}
    end;                               {back for next source row up}
  end;
