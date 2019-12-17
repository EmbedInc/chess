{   This module contains the default move evaluator that comes with the CHESS
*   library.  CHESS_EVAL_OPEN is the only public entry point to the move
*   evaluator.  Applications using the CHESS library can provide other move
*   evaluators by supplying CHESS_EVAL_OPEN before linking in the CHESS library.
}
module chess_eval;
define chess_eval_open;
%include 'chess2.ins.pas';

const
{
*   Default move evaluator parameters.
}
  moves_look_k = 2;                    {max moves to look ahead}
  val_pawn_k = 100;                    {fixed value of pieces}
  val_bishop_k = 270;
  val_knight_k = 300;
  val_rook_k = 450;
  val_queen_k = 800;
  val_check_k = 20;                    {value of having other king in check}
  val_covk_k = 15;                     {added val of sqr covered around other king}
  val_cov_k = 10;                      {value of covering an empty square}
  val_push_k = 8;                      {value of pawn one square more forwards}

type
  priv_t = record                      {private data for each move evaluator use}
    hmove_look: integer32;             {number of half-moves to look ahead}
    val_pawn: sys_int_machine_t;       {fixed value of pieces}
    val_knight: sys_int_machine_t;
    val_bishop: sys_int_machine_t;
    val_rook: sys_int_machine_t;
    val_queen: sys_int_machine_t;
    val_check: sys_int_machine_t;      {value of having other king in check}
    val_covk: sys_int_machine_t;       {added val of sqr covered around other king}
    val_cov: sys_int_machine_t;        {value of covering an empty square}
    val_push: sys_int_machine_t;       {value of pawn one square more forwards}
    end;
  priv_p_t = ^priv_t;

  cval_t = array[1..16] of sys_int_machine_t; {list of piece values covering square}

function eval_move (                   {evaluate a candidate move}
  in out  eval: chess_eval_t;          {context for this move evaluator use}
  in      pos: chess_pos_t;            {board position after the move}
  in      whmove: boolean)             {TRUE if it is now white's move}
  :sys_int_machine_t;                  {range CHESS_EVAL_xxx_K, high good for white}
  val_param; forward; internal;

function eval_pos (                    {evaluate a chess board position}
  in      priv: priv_t;                {private state for this use of move evaluator}
  in      pos: chess_pos_t;            {position to evaluate}
  in      whmove: boolean)             {it is now white's move}
  :sys_int_machine_t;                  {range CHESS_EVAL_xxx_K, high good for white}
  val_param; forward; internal;

function wtake (
  in      wcval: univ cval_t;          {list of white covering piece values}
  in      nw: sys_int_machine_t;       {number of entries in WCVAL}
  in      bcval: univ cval_t;          {list of black covering piece values}
  in      nb: sys_int_machine_t;       {number of entries in BCVAL}
  in      vonsq: sys_int_machine_t)    {value of piece on disputed square}
  :sys_int_machine_t;                  {overall value from white's point of view}
  val_param; forward; internal;

function btake (
  in      wcval: univ cval_t;          {list of white covering piece values}
  in      nw: sys_int_machine_t;       {number of entries in WCVAL}
  in      bcval: univ cval_t;          {list of black covering piece values}
  in      nb: sys_int_machine_t;       {number of entries in BCVAL}
  in      vonsq: sys_int_machine_t)    {value of piece on disputed square}
  :sys_int_machine_t;                  {overall value from white's point of view}
  val_param; forward; internal;
{
********************************************************************************
*
*   Subroutine CHESS_EVAL_OPEN (EVAL, STAT)
*
*   Open a new use of this move evaluator.  EVAL is the context for this use of
*   the move evaluator.  It has already been initialized to default or empty
*   values.  At a minimum, this routine must install a pointer to the move
*   evaluator function into EVAL.EVAL_MOVE_P.
}
procedure chess_eval_open (            {init implementation-specific in EVAL info}
  in out  eval: chess_eval_t;          {EVAL structure to add implementation info to}
  out     stat: sys_err_t);            {completion status code}
  val_param;

var
  priv_p: priv_p_t;                    {pointer to our private state}

begin
{
*   Set up our private state.
}
  chess_eval_malloc (                  {allocate mem for our private state}
    eval, sizeof(priv_p^), priv_p);
  eval.priv_p := priv_p;               {save pointer to private state}

  priv_p^.hmove_look := moves_look_k;  {init private state}
  priv_p^.val_pawn := val_pawn_k;
  priv_p^.val_knight := val_knight_k;
  priv_p^.val_bishop := val_bishop_k;
  priv_p^.val_rook := val_rook_k;
  priv_p^.val_queen := val_queen_k;
  priv_p^.val_check := val_check_k;
  priv_p^.val_covk := val_covk_k;
  priv_p^.val_cov := val_cov_k;
  priv_p^.val_push := val_push_k;
{
*   Set up the list of tweakable parameters.
}
  chess_eval_addparm (eval, chess_eval_parmtyp_int_k,
    'Moves look ahead');
  eval.last_p^.int_min := 0;           {min allowable value}
  eval.last_p^.int_max := 10;          {max allowable value}
  eval.last_p^.int_val_p := addr(priv_p^.hmove_look); {point to stored value}

  chess_eval_addparm (eval, chess_eval_parmtyp_int_k,
    'Pawn');
  eval.last_p^.int_min := -5000;       {min allowable value}
  eval.last_p^.int_max := 5000;        {max allowable value}
  eval.last_p^.int_val_p := addr(priv_p^.val_pawn); {point to stored value}

  chess_eval_addparm (eval, chess_eval_parmtyp_int_k,
    'Knight');
  eval.last_p^.int_min := -5000;       {min allowable value}
  eval.last_p^.int_max := 5000;        {max allowable value}
  eval.last_p^.int_val_p := addr(priv_p^.val_knight); {point to stored value}

  chess_eval_addparm (eval, chess_eval_parmtyp_int_k,
    'Bishop');
  eval.last_p^.int_min := -5000;       {min allowable value}
  eval.last_p^.int_max := 5000;        {max allowable value}
  eval.last_p^.int_val_p := addr(priv_p^.val_bishop); {point to stored value}

  chess_eval_addparm (eval, chess_eval_parmtyp_int_k,
    'Rook');
  eval.last_p^.int_min := -5000;       {min allowable value}
  eval.last_p^.int_max := 5000;        {max allowable value}
  eval.last_p^.int_val_p := addr(priv_p^.val_rook); {point to stored value}

  chess_eval_addparm (eval, chess_eval_parmtyp_int_k,
    'Queen');
  eval.last_p^.int_min := -5000;       {min allowable value}
  eval.last_p^.int_max := 5000;        {max allowable value}
  eval.last_p^.int_val_p := addr(priv_p^.val_queen); {point to stored value}

  chess_eval_addparm (eval, chess_eval_parmtyp_int_k,
    'CHECK');
  eval.last_p^.int_min := -5000;       {min allowable value}
  eval.last_p^.int_max := 5000;        {max allowable value}
  eval.last_p^.int_val_p := addr(priv_p^.val_check); {point to stored value}

  chess_eval_addparm (eval, chess_eval_parmtyp_int_k,
    'COVK');
  eval.last_p^.int_min := -5000;       {min allowable value}
  eval.last_p^.int_max := 5000;        {max allowable value}
  eval.last_p^.int_val_p := addr(priv_p^.val_covk); {point to stored value}

  chess_eval_addparm (eval, chess_eval_parmtyp_int_k,
    'COV');
  eval.last_p^.int_min := -5000;       {min allowable value}
  eval.last_p^.int_max := 5000;        {max allowable value}
  eval.last_p^.int_val_p := addr(priv_p^.val_cov); {point to stored value}

  chess_eval_addparm (eval, chess_eval_parmtyp_int_k,
    'PUSH');
  eval.last_p^.int_min := -5000;       {min allowable value}
  eval.last_p^.int_max := 5000;        {max allowable value}
  eval.last_p^.int_val_p := addr(priv_p^.val_push); {point to stored value}
{
*   Install our private routines.
}
  eval.eval_move_p := univ_ptr(addr(eval_move)); {install move evaluator routine}
  end;
{
********************************************************************************
*
*   Local function EVAL2 (PRIV, POS, WHMOVE, LEV)
*
*   Evaluates move recursively.  POS, WHMOVE, and function value are same as for
*   EVAL_MOVE.  LEV is the recursion level, which must be 0 for the top level
*   call.  This routine calls itself recursively for each half-move.  PRIV is
*   the private state for this use of the move generator.
}
function eval2 (                       {evaluate a candidate move}
  in      priv: priv_t;                {private state for this use of move evaluator}
  in      pos: chess_pos_t;            {board position after the move}
  in      whmove: boolean;             {it is now white's move}
  in      lev: sys_int_machine_t)      {recursive nesting level, 0 for top call}
  :sys_int_machine_t;                  {range CHESS_EVAL_xxx_K, high good for white}
  val_param; internal;

var
  pos_p: chess_pos_p_t;                {pointer to a previous position in this game}
  x, y: sys_int_machine_t;             {coordinate of current square}
  st: chess_move_t;                    {legal move generator state}
  bestval: sys_int_machine_t;          {our value for best move found}
  nmove: sys_int_machine_t;            {number of moves}
  pos2: chess_pos_t;                   {position after subordinate move}

label
  not_same;

begin
{
*   Check for too many moves without a capture or pawn promotion.  If so, it is
*   a stalemate.
}
  if pos.nsame > 50 then begin         {too many moves without capture or promotion ?}
    eval2 := 0;
    return;
    end;
{
*   Go back thru the chain of moves looking for reasons this move results in a
*   stalemate.  If the same position has occurred previously, then we report
*   0 to have it scored as a stalemate.  Actually it isn't a stalemate until the
*   same position has occurred three times (two previous times), but there is no
*   point in having the algorithm go thru the intermediate duplicate position
*   just to avoid it the third time if a stalemate is undesirable.
}
  pos_p := addr(pos);                  {init to last position checked for duplicate}
  while true do begin
    if pos_p^.nsame <= 1 then exit;    {pieces change before here, can't have dups ?}
    pos_p := pos_p^.prev_p;            {point to previous position}
    if pos_p = nil then exit;          {hit end of chain ?}
    for y := 0 to 7 do begin           {scan all the squares}
      for x := 0 to 7 do begin
        if pos_p^.sq[y, x].piece <> pos.sq[y, x].piece then goto not_same;
        end;
      end;
    eval2 := 0;                        {return evaluation for stalemate}
    return;
not_same:                              {jump to here if positions are different}
    end;                               {back to check next previous position}
{
*   Check recursion level for the number of half moves deep meets the look
*   ahead setting.  If so, return the static board position evaluation
*   instead of creating any additional sub-moves.
}
  if lev >= priv.hmove_look then begin {at max recursion level ?}
    eval2 := eval_pos (priv, pos, whmove); {evaluate board position directly}
    return;
    end;
{
*   This move will be evaluated by recusively evaluating each of the
*   possible moves for whoever's turn it is.
}
  if whmove
    then begin
{
*   It is white's turn to move.  The best move for white is the one with
*   the highest evaluation.
}
  chess_move_init (addr(pos), true, st); {init move generator}
  if not st.king then begin            {king already lost ?}
    eval2 := chess_eval_min_k;
    return;
    end;
  bestval := chess_eval_min_k;         {init value of best move so far}
  nmove := 0;                          {init number of legal moves found}

  while chess_move (st, pos2) do begin {once for each legal move}
    nmove := nmove + 1;                {count one more legal move found}
    bestval :=                         {update with valuation of this move}
      max(bestval, eval2(priv, pos2, false, lev + 1));
    if bestval = chess_eval_max_k then begin {already know we can win ?}
      eval2 := chess_eval_max_k - lev;
      return;
      end;
    end;                               {back to check next legal move}

  if nmove = 0 then begin              {there are no legal moves ?}
    if chess_cover (pos, st.kx, st.ky, false) then begin {in check ?}
      eval2 := chess_eval_min_k;       {check mate}
      return;
      end;
    bestval := 0;                      {this position is a draw}
    end;

      end                              {end of white's turn to move case}
    else begin
{
*   It is black's turn to move.  The best move for black is the one with
*   the lowest evaluation.
}
  chess_move_init (addr(pos), false, st); {init move generator}
  if not st.king then begin            {king already lost ?}
    eval2 := chess_eval_max_k;
    return;
    end;
  bestval := chess_eval_max_k;         {init value of best move so far}
  nmove := 0;                          {init number of legal moves found}

  while chess_move (st, pos2) do begin {once for each legal move}
    nmove := nmove + 1;                {count one more legal move found}
    bestval :=                         {update with valuation of this move}
      min(bestval, eval2(priv, pos2, true, lev + 1));
    if bestval = chess_eval_min_k then begin {already know we can win ?}
      eval2 := chess_eval_min_k + lev;
      return;
      end;
    end;                               {back to check next legal move}

  if nmove = 0 then begin              {there are no legal moves ?}
    if chess_cover (pos, st.kx, st.ky, true) then begin {in check ?}
      eval2 := chess_eval_max_k;       {check mate}
      return;
      end;
    bestval := 0;                      {this position is a draw}
    end;

      end                              {end of black's turn to move case}
    ;                                  {end of whose turn cases}
{
*   All next legal moves have been examined, and BESTVAL is the value
*   resulting from the best move.  NMOVE is the number of legal moves
*   found.
}
  eval2 := bestval;
  end;
{
********************************************************************************
*
*   Function EVAL_MOVE (EVAL, POS, WHMOVE)
*
*   Evaluate the move ending in the position described by POS, assuming it is
*   now white's move when WHMOVE is TRUE, and black's move when FALSE.  The
*   return value is from white's point of view, with higher values meaning that
*   white has a better opportunity of winning the game.  The return value will
*   always be in the range from CHESS_EVAL_MIN_K to CHESS_EVAL_MAX_K.  The value
*   CHESS_EVAL_MIN_K means that black has won the game, CHESS_EVAL_MAX_K that
*   white has won the game.  The return value of 0 indicates the board position
*   is a tie, meaning it favors neither white nor black.
*
*   Other than the min, max, and 0 values described above, the caller should
*   make no assumption about the range of possible return values.  For example,
*   one implementation of this routine might return values from -1,000 to
*   +1,000, while another from -10,000 to +10,000.  However, the min and max
*   values are always reserved for a definite win or loss.
}
function eval_move (                   {evaluate a candidate move}
  in out  eval: chess_eval_t;          {context for this move evaluator use}
  in      pos: chess_pos_t;            {board position after the move}
  in      whmove: boolean)             {TRUE if it is now white's move}
  :sys_int_machine_t;                  {range CHESS_EVAL_xxx_K, high good for white}
  val_param; internal;

var
  priv_p: priv_p_t;                    {pointer to our private data this eval use}

begin
  priv_p := eval.priv_p;               {get pointer to private data for this use}

  eval_move := eval2 (                 {evaluate the move recursively}
    priv_p^,                           {private state for this move evaluator use}
    pos,                               {board position after the move}
    whmove,                            {TRUE if now white's turn}
    0);                                {nested recursion level}
  end;
{
********************************************************************************
*
*   Local function WTAKE (WCVAL, NW, BCVAL, NB, VONSQ)
*
*   Returns the value for the situation where a list of pieces from both sides
*   are covering a square.  WCVAL and NW is the list of white pieces and BCVAL
*   and NB is the list of black pieces.  WCVAL and BCVAL contain the positive
*   values (not negative for black) of the covering pieces sorted in order of
*   lowest to highest value.  VONSQ is the signed (negative for black) value of
*   the piece on the disputed square
*
*   It is white's move and VONSQ is representing a black piece.  NW is at least
*   1.
*
*   This function calls itself recursively to resolve the true value from
*   white's point of view.  Note that the returned value is always bounded by the
*   value of the piece on the square (piece not taken) and 0 (piece taken with
*   nothing gained in return).
}
function wtake (
  in      wcval: univ cval_t;          {list of white covering piece values}
  in      nw: sys_int_machine_t;       {number of entries in WCVAL}
  in      bcval: univ cval_t;          {list of black covering piece values}
  in      nb: sys_int_machine_t;       {number of entries in BCVAL}
  in      vonsq: sys_int_machine_t)    {value of piece on disputed square}
  :sys_int_machine_t;                  {overall value from white's point of view}
  val_param; internal;

var
  val: sys_int_machine_t;              {scratch value}

begin
  if nb <= 0 then begin                {no black coverage left ?}
    wtake := 0;                        {we can take piece without losing anything}
    return;
    end;

  val :=                               {value of our piece after opponent response}
    btake (wcval[2], nw-1, bcval, nb, wcval[1]);
  val := val - wcval[1];               {overall value if we take the piece}
  wtake := max(val, vonsq);            {we won't take if lose more than what taking}
  end;
{
********************************************************************************
*
*   Local function BTAKE (WCVAL, NW, BCVAL, NB, VONSQ)
*
*   Returns the value for the situation where a list of pieces from both sides
*   are covering a square.  WCVAL and NW is the list of white pieces and BCVAL
*   and NB is the list of black pieces.  WCVAL and BCVAL contain the positive
*   values (not negative for black) of the covering pieces sorted in order of
*   lowest to highest value.  VONSQ is the signed (negative for black) value of
*   the piece on the disputed square
*
*   It is black's move and VONSQ is representing a white piece.  NB is at least
*   1.
*
*   This function calls itself recursively to resolve the true value from
*   white's point of view.  Note that the returned value is always bounded by
*   the value of the piece on the square (piece not taken) and 0 (piece taken
*   with nothing gained in return).
}
function btake (
  in      wcval: univ cval_t;          {list of white covering piece values}
  in      nw: sys_int_machine_t;       {number of entries in WCVAL}
  in      bcval: univ cval_t;          {list of black covering piece values}
  in      nb: sys_int_machine_t;       {number of entries in BCVAL}
  in      vonsq: sys_int_machine_t)    {value of piece on disputed square}
  :sys_int_machine_t;                  {overall value from white's point of view}
  val_param; internal;

var
  val: sys_int_machine_t;              {scratch value}

begin
  if nw <= 0 then begin                {no white coverage left ?}
    btake := 0;                        {we can take piece without losing anything}
    return;
    end;

  val :=                               {value of our piece after opponent response}
    wtake (wcval, nw, bcval[2], nb-1, -bcval[1]);
  val := val + bcval[1];               {overall value if we take the piece}
  btake := min(val, vonsq);            {we won't take if lose more than what taking}
  end;
{
********************************************************************************
*
*   Function EVAL_POS (PRIV, POS, WHMOVE)
*
*   Evaluate the chess board position described by POS, assuming it is now
*   white's move when WHMOVE is TRUE, and black's move when FALSE.  The return
*   value is from white's point of view, with higher values meaning that white
*   has a better opportunity of winning the game.  The return value will always
*   be in the range from CHESS_EVAL_MIN_K to CHESS_EVAL_MAX_K.  The value
*   CHESS_EVAL_MIN_K means that black has won the game, CHESS_EVAL_MAX_K that
*   white has won the game.  The return value of 0 means the board position is a
*   tie, meaning it favors neither white nor black.
*
*   Other than the min, max, and 0 values described above, the caller should
*   make no assumption about the range of possible return values.  For example,
*   one implementation of this routine might return values from -1,000 to
*   +1,000, while another from -10,000 to +10,000.  However, the min and max
*   values are always reserved for a definite win or loss.
}
function eval_pos (                    {evaluate chess board position}
  in      priv: priv_t;                {private state for this use of move evaluator}
  in      pos: chess_pos_t;            {position to evaluate}
  in      whmove: boolean)             {it is now white's move}
  :sys_int_machine_t;                  {range CHESS_EVAL_xxx_K, high good for white}
  val_param; internal;

var
  kwx, kwy: sys_int_machine_t;         {coordinates of white king}
  kbx, kby: sys_int_machine_t;         {coordinates of black king}
  dx, dy: sys_int_machine_t;           {board square displacement}
  x, y: sys_int_machine_t;             {current square coordinates}
  val: sys_int_machine_t;              {current accumulated value}
  wcov, bcov: chess_covlist_t;         {list of pieces covering a square}
  wcval, bcval: cval_t;                {piece values covering a square}
  i, j, k: sys_int_machine_t;          {scratch integers and loop counters}
  vonsq: sys_int_machine_t;            {value of piece on disputed square}
  nearwk, nearbk: boolean;             {in square adjacent to a king}
  onwk, onbk: boolean;                 {on king square}

label
  sqr_empty, own_none, own_white, own_black, next_square;

begin
{
*   Find the two kings.
}
  kwx := -1;                           {init to white king not yet found}
  kbx := -1;                           {init to black king not yet found}

  for y := 0 to 7 do begin             {up the rows}
    for x := 0 to 7 do begin           {accross this row}
      case pos.sq[y, x].piece of
chess_sqr_wking_k: begin
          kwx := x;
          kwy := y;
          end;
chess_sqr_bking_k: begin
          kbx := x;
          kby := y;
          end;
        end;
      end;
    end;

  if kwx = -1 then begin               {white king missing, assume game lost ?}
    eval_pos := chess_eval_min_k;
    return;
    end;

  if kbx = -1 then begin               {black king missing, assume game won ?}
    eval_pos := chess_eval_max_k;
    return;
    end;
{
*   Loop thru each board square.  For each square, add in the value of the
*   piece on that square.  The pieces for the side not moving next are
*   sometimes downgraded, depending on the coverage from the side moving
*   next.  This is not done for both sides, since the side moving next
*   has an opportunity to move a piece away, interpose a piece, etc.
*
*   The white king is at KWX,KWY and the black king at KBX,KBY.
}
  val := 0;                            {init accumulated value}

  for y := 0 to 7 do begin             {up the rows}
    for x := 0 to 7 do begin           {accross this row}
      dx := abs(x - kwx);              {make offset from white king}
      dy := abs(y - kwy);
      nearwk := false;                 {init to not near white king}
      onwk := false;
      if (dx <= 1) and (dy <= 1) then begin {near white king}
        onwk := (dx = 0) and (dy = 0); {on white king square ?}
        nearwk := not onwk;            {just near, not on white king ?}
        end;

      dx := abs(x - kbx);              {make offset from black king}
      dy := abs(y - kby);
      nearbk := false;                 {init to not near black king}
      onbk := false;
      if (dx <= 1) and (dy <= 1) then begin {near black king}
        onbk := (dx = 0) and (dy = 0); {on black king square ?}
        nearbk := not onbk;            {just near, not on black king ?}
        end;
{
*   NEARWK, ONWK, NEARBK, and ONBK all set.  NEARWK is true if this square
*   (X,Y) is near the white king, and ONWK is true if this is the square
*   the white king is on.  Both NEARWK and ONWK are never true at the same
*   time.  NEARBK and ONBK work the same for the black king.
}
      chess_cover_list (               {get lists of pieces covering this square}
        pos, x, y, wcov, bcov);

      if bcov.n > 0 then begin         {black is covering this square ?}
        if onwk then begin             {on white king square and king in check ?}
          val := val - priv.val_check;
          goto next_square;
          end;
        if nearwk then val := val - priv.val_covk; {near the white king ?}
        end;

      if wcov.n = 0
        then begin                     {white is not covering this square at all}
          if bcov.n = 0 then goto own_none; {neither side owns this square}
          goto own_black;              {black owns this square}
          end
        else begin                     {white is covering this square}
          if onbk then begin           {on black king square and king in check ?}
            val := val + priv.val_check;
            goto next_square;
            end;
          if nearbk then val := val + priv.val_covk; {near the black king ?}
          if bcov.n = 0 then goto own_white; {white owns this square ?}
{
*   Both sides are covering this square to some extent, and neither king is
*   on this square.
*
*   Init VONSQ to the value of the piece on the square.  Apply full
*   credit for the piece if it belongs to the color moving next.
}
  case pos.sq[y, x].piece of           {init value of piece on disputed square}
chess_sqr_wpawn_k:   vonsq :=  priv.val_pawn + (y - 1) * priv.val_push; {white pawn}
chess_sqr_wrook_k:   vonsq :=  priv.val_rook; {white rook}
chess_sqr_wknight_k: vonsq :=  priv.val_knight; {white knight}
chess_sqr_wbishop_k: vonsq :=  priv.val_bishop; {white bishop}
chess_sqr_wqueen_k:  vonsq :=  priv.val_queen; {white queen}
chess_sqr_bpawn_k:   vonsq := -priv.val_pawn - (6 - y) * priv.val_push; {black pawn}
chess_sqr_brook_k:   vonsq := -priv.val_rook; {black rook}
chess_sqr_bknight_k: vonsq := -priv.val_knight; {black knight}
chess_sqr_bbishop_k: vonsq := -priv.val_bishop; {black bishop}
chess_sqr_bqueen_k:  vonsq := -priv.val_queen; {black queen}
otherwise                              {disputed square is empty}
    vonsq := 0;
    goto sqr_empty;                    {skip ahead if disputed square is empty}
    end;

  if whmove
    then begin                         {white is moving next}
      if vonsq > 0 then begin          {a white piece is on the square ?}
        val := val + vonsq;
        goto next_square;
        end;
      end
    else begin                         {black is moving next}
      if vonsq < 0 then begin          {a black piece is on the square ?}
        val := val + vonsq;
        goto next_square;
        end;
      end
    ;
sqr_empty:                             {skip to here on disputed square is empty}
{
*   Build the WCVAL and BCVAL lists from the WCOV and BCOV lists.  The
*   xCOV lists indicate the coordinate of pieces covering this square.
*   The xCVAL lists indicate the value of the covering pieces.
}
  for i := 1 to wcov.n do begin        {once for each white covering piece}
    case pos.sq[wcov.cov[i].y, wcov.cov[i].x].piece of {what type of piece ?}
chess_sqr_wpawn_k: wcval[i] := priv.val_pawn + wcov.cov[i].y * priv.val_push;
chess_sqr_wrook_k: wcval[i] := priv.val_rook;
chess_sqr_wknight_k: wcval[i] := priv.val_knight;
chess_sqr_wbishop_k: wcval[i] := priv.val_bishop;
chess_sqr_wqueen_k: wcval[i] := priv.val_queen;
otherwise
      wcval[i] := 30000;               {assume covered by king}
      end;
    end;

  for i := 1 to bcov.n do begin        {once for each black covering piece}
    case pos.sq[bcov.cov[i].y, bcov.cov[i].x].piece of {what type of piece ?}
chess_sqr_bpawn_k: bcval[i] := priv.val_pawn + (7 - bcov.cov[i].y) * priv.val_push;
chess_sqr_brook_k: bcval[i] := priv.val_rook;
chess_sqr_bknight_k: bcval[i] := priv.val_knight;
chess_sqr_bbishop_k: bcval[i] := priv.val_bishop;
chess_sqr_bqueen_k: bcval[i] := priv.val_queen;
otherwise
      bcval[i] := 30000;               {assume covered by king}
      end;
    end;
{
*   Sort the xCVAL coverage lists in order of lowest to highest valued
*   covering piece.
}
  for i := 1 to wcov.n-1 do begin      {outer sort loop}
    for j := i + 1 to wcov.n do begin  {inner sort loop}
      if wcval[j] < wcval[i] then begin {I and J entries are out of order ?}
        k := wcval[i];                 {flip the I and J entries}
        wcval[i] := wcval[j];
        wcval[j] := k;
        end;
      end;
    end;

  for i := 1 to bcov.n-1 do begin      {outer sort loop}
    for j := i + 1 to bcov.n do begin  {inner sort loop}
      if bcval[j] < bcval[i] then begin {I and J entries are out of order ?}
        k := bcval[i];                 {flip the I and J entries}
        bcval[i] := bcval[j];
        bcval[j] := k;
        end;
      end;
    end;
{
*   Handle the case of the disputed square is empty.
}
  if vonsq = 0 then begin
    for i := 1 to wcov.n do begin      {loop thru all the white covering pieces}
      if
          (i > bcov.n) or else         {no more black covering pieces ?}
          (wcval[i] < bcval[i])        {white's coverage is stronger ?}
          then begin
        val := val + priv.val_cov;
        goto next_square;
        end;
      if bcval[i] < wcval[i] then begin {black's coverage is stronger ?}
        val := val - priv.val_cov;
        goto next_square;
        end;
      end;                             {back to compare next layer of coverage}
    if bcov.n > wcov.n then begin      {still black covering pieces left ?}
      val := val - priv.val_cov;
      goto next_square;
      end;
    goto next_square;                  {equally covered, neither side credited}
    end;
{
*   Find the effective value of the piece on the disputed square.  This value
*   is bounded by 0 (piece taken with nothing in return) and the piece value
*   (piece not taken).
*
*   The piece on the disputed square is not of the moving color.
}
  if whmove
    then begin                         {it is white's move}
      val := val + wtake (wcval, wcov.n, bcval, bcov.n, vonsq);
      end
    else begin                         {it is black's move}
      val := val + btake (wcval, wcov.n, bcval, bcov.n, vonsq);
      end
    ;
  goto next_square;

          end                          {end of white covering square case}
        ;                              {end of white covering cases}
{
*   Neither side is covering this square.
}
own_none:
  case pos.sq[y, x].piece of           {what piece is on this square ?}
chess_sqr_wpawn_k:   val := val + priv.val_pawn + (y - 1) * priv.val_push; {white pawn}
chess_sqr_wrook_k:   val := val + priv.val_rook; {white rook}
chess_sqr_wknight_k: val := val + priv.val_knight; {white knight}
chess_sqr_wbishop_k: val := val + priv.val_bishop; {white bishop}
chess_sqr_wqueen_k:  val := val + priv.val_queen; {white queen}
chess_sqr_bpawn_k:   val := val - priv.val_pawn - (6 - y) * priv.val_push; {black pawn}
chess_sqr_brook_k:   val := val - priv.val_rook; {black rook}
chess_sqr_bknight_k: val := val - priv.val_knight; {black knight}
chess_sqr_bbishop_k: val := val - priv.val_bishop; {black bishop}
chess_sqr_bqueen_k:  val := val - priv.val_queen; {black queen}
    end;
  goto next_square;
{
*   White is exclusively covering this square.
}
own_white:
  if whmove
    then begin                         {white will move next}
      case pos.sq[y, x].piece of       {what piece is on this square ?}
chess_sqr_empty_k:   val := val + priv.val_cov; {empty square}
chess_sqr_wpawn_k:   val := val + priv.val_pawn + (y - 1) * priv.val_push; {white pawn}
chess_sqr_wrook_k:   val := val + priv.val_rook; {white rook}
chess_sqr_wknight_k: val := val + priv.val_knight; {white knight}
chess_sqr_wbishop_k: val := val + priv.val_bishop; {white bishop}
chess_sqr_wqueen_k:  val := val + priv.val_queen; {white queen}
        end;
      end
    else begin                         {black will move next}
      case pos.sq[y, x].piece of       {what piece is on this square ?}
chess_sqr_wpawn_k:   val := val + priv.val_pawn + (y - 1) * priv.val_push; {white pawn}
chess_sqr_wrook_k:   val := val + priv.val_rook; {white rook}
chess_sqr_wknight_k: val := val + priv.val_knight; {white knight}
chess_sqr_wbishop_k: val := val + priv.val_bishop; {white bishop}
chess_sqr_wqueen_k:  val := val + priv.val_queen; {white queen}
chess_sqr_bpawn_k:   val := val - priv.val_pawn - (6 - y) * priv.val_push; {black pawn}
chess_sqr_brook_k:   val := val - priv.val_rook; {black rook}
chess_sqr_bknight_k: val := val - priv.val_knight; {black knight}
chess_sqr_bbishop_k: val := val - priv.val_bishop; {black bishop}
chess_sqr_bqueen_k:  val := val - priv.val_queen; {black queen}
        end;
      end
    ;
  goto next_square;
{
*   Black is exclusively covering this square.
}
own_black:
  if whmove
    then begin                         {white will move next}
      case pos.sq[y, x].piece of       {what piece is on this square ?}
chess_sqr_wpawn_k:   val := val + priv.val_pawn + (y - 1) * priv.val_push; {white pawn}
chess_sqr_wrook_k:   val := val + priv.val_rook; {white rook}
chess_sqr_wknight_k: val := val + priv.val_knight; {white knight}
chess_sqr_wbishop_k: val := val + priv.val_bishop; {white bishop}
chess_sqr_wqueen_k:  val := val + priv.val_queen; {white queen}
chess_sqr_bpawn_k:   val := val - priv.val_pawn - (6 - y) * priv.val_push; {black pawn}
chess_sqr_brook_k:   val := val - priv.val_rook; {black rook}
chess_sqr_bknight_k: val := val - priv.val_knight; {black knight}
chess_sqr_bbishop_k: val := val - priv.val_bishop; {black bishop}
chess_sqr_bqueen_k:  val := val - priv.val_queen; {black queen}
        end;
      end
    else begin                         {black will move next}
      case pos.sq[y, x].piece of       {what piece is on this square ?}
chess_sqr_bpawn_k:   val := val - priv.val_pawn - (6 - y) * priv.val_push; {black pawn}
chess_sqr_brook_k:   val := val - priv.val_rook; {black rook}
chess_sqr_bknight_k: val := val - priv.val_knight; {black knight}
chess_sqr_bbishop_k: val := val - priv.val_bishop; {black bishop}
chess_sqr_bqueen_k:  val := val - priv.val_queen; {black queen}
        end;
      end
    ;

next_square:                           {jump here on done with this square}
      end;                             {back for next square accross in this row}
    end;                               {back for next row up}

  eval_pos := val;
  return;
  end;
