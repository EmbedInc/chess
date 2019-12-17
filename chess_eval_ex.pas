{   This module contains an example custom move evaluator for the CHESS
*   library.  The CHESS library built in move evaluator can be replaced
*   by linking in a module containing CHESS_EVAL_OPEN before linking
*   in the CHESS library.
*
*   This move evaluator is not intended to be useful for playing chess,
*   but only to serve as an example of how to create your own custom
*   move evaluator.
*
*   A custom version of the CHESSV_W executable using this move evaluator
*   can be built with the accompanying BUILE_CHESSV script.
}
module chess_eval;
define chess_eval_open;
%include '(cog)lib/sys.ins.pas';
%include '(cog)lib/util.ins.pas';
%include '(cog)lib/string.ins.pas';
%include '(cog)lib/file.ins.pas';
%include '(cog)lib/chess.ins.pas';

type
  priv_t = record                      {private data for each move evaluator use}
    val_pawn: integer32;               {value of each of the pieces}
    val_knight: integer32;
    val_bishop: integer32;
    val_rook: integer32;
    val_queen: integer32;
    end;
  priv_p_t = ^priv_t;

function eval_move (                   {evaluate a candidate move}
  in out  eval: chess_eval_t;          {context for this move evaluator use}
  in      pos: chess_pos_t;            {board position after the move}
  in      whmove: boolean)             {TRUE if it is now white's move}
  :sys_int_machine_t;                  {range CHESS_EVAL_xxx_K, high good for white}
  val_param; forward; internal;
{
*************************************************************************
*
*   Subroutine CHESS_EVAL_OPEN (EVAL, STAT)
*
*   Open a new use of this move evaluator.  EVAL is the context for this
*   use of the move evaluator.  It has already been initialized to default
*   or empty values.
*
*   EVAL is of data type CHESS_EVAL_T, which is defined in CHESS.INS.PAS.
*   The fields of EVAL are:
*
*     MEM_P  -  Pointer to a private memory context.  MEM_P has already
*       been set and should not be altered.  It can be used to allocate
*       dynamic memory that will automatically be deallocated when this
*       move evaluator context is closed.  The subroutine CHESS_EVAL_MALLOC
*       is a convenience wrapper for allocating memory from this context
*       that can not be individually deallocated, meaning it persists
*       until this move evaluator context is closed.
*
*     PARM_P  -  Points to the start of the parameters chain.  These
*       parameters provide a means for the move evaluator to export
*       an arbitrary set of adjustable parameters to the application.
*       PARM_P should not be touched.  Use the CHESS_EVAL_ADDPARM
*       routine to add parameters to the list.  The list has been
*       initialized to empty.
*
*     LAST_P  -  Points to the last parameter in the parameters chain.
*       This will point to the newly created parameter descriptor after
*       a call to CHESS_EVAL_ADDPARM.  This pointer will likely need
*       be used after a parameter is created to finish filling in its
*       values.  The parameters list has been initialized to empty.
*
*     EVAL_MOVE_P  -  Pointer to the routine to call to evaluate a
*       chess board position.  This has been initialized to NIL, and
*       must be filled in by this routine.
*
*     CLOSE_P  -  Pointer to a routine that will be called before this
*       move evaluator context is closed.  This pointer has been
*       initialized to NIL, and should be left that way if this move
*       evaluator has not private close routine.  The private close
*       routine is called before the memory context pointed to by
*       MEM_P is deallocated.  The purpose of a close routine is to
*       release any resources that may have been allocated by the
*       move evaluator.  Note that a close routine is not needed to
*       deallocate any memory that was allocated from the memory
*       context at MEM_P.  This will be done automatically after the
*       private close routine returns.
*
*     PRIV_P  -  Pointer to any private state that the move evaluator
*       may require.  This has been initialized to NIL, and will be
*       otherwise ignored by the rest of the system.
*
*   STAT is a Cognivision completion status code.  It can be used to
*   pass an error status back to the caller.  STAT has been initialized
*   to indicate no error, so it can be ignored if desired.
*
*   The minimum requirement for CHESS_EVAL_OPEN is that it must write
*   the address of the move evaluator routine into EVAL.EVAL_MOVE_P.
*   CHESS_EVAL_OPEN may also allocate private memory, create named
*   parameters, and install a private close routine.
}
procedure chess_eval_open (            {init implementation-specific in EVAL info}
  in out  eval: chess_eval_t;          {EVAL structure to add implementation info to}
  out     stat: sys_err_t);            {completion status code}
  val_param;

var
  priv_p: priv_p_t;                    {pointer to our private state}

begin
{
*   Create private state, and save a pointe to it in EVAL.
}
  chess_eval_malloc (                  {allocate mem for our private state}
    eval, sizeof(priv_p^), priv_p);
  eval.priv_p := priv_p;               {save pointer to private state}

  priv_p^.val_pawn := 100;             {init private state values}
  priv_p^.val_knight := 260;
  priv_p^.val_bishop := 300;
  priv_p^.val_rook := 450;
  priv_p^.val_queen := 800;
{
*   Create named parameters that the application can ask the user to
*   adjust.
}
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
{
*   Install our private routines.  This implementation does not have a
*   private close routine.
}
  eval.eval_move_p := univ_ptr(addr(eval_move)); {install move evaluator routine}
  end;
{
*************************************************************************
*
*   Function EVAL_MOVE (EVAL, POS, WHMOVE)
*
*   Evaluate the move ending in the position described by POS, assuming it is
*   now white's move when WHMOVE is TRUE, and black's move when FALSE.  The
*   return value is from white's point of view, with higher values meaning
*   that white has a better opportunity of winning the game.  The return
*   value must always be in the range from CHESS_EVAL_MIN_K to
*   CHESS_EVAL_MAX_K.  The value CHESS_EVAL_MIN_K means that black has
*   won the game, CHESS_EVAL_MAX_K that white has won the game.  The
*   return value of 0 indicates the board position is a tie, meaning it
*   favors neither white nor black.
*
*   Other than the min, max, and 0 values described above, the caller
*   should make no assumption about the range of possible return
*   values.  For example, one implementation of this routine might
*   return values from -1,000 to +1,000, while another from -10,000 to
*   +10,000.  However, the min and max values are always reserved for
*   a definite win or loss.
*
*   This a "dumb" move evaluator that only serves as a source code example.
*   It blindly rates each board position soley by the value of the pieces
*   each side has on the board.
}
function eval_move (                   {evaluate a candidate move}
  in out  eval: chess_eval_t;          {context for this move evaluator use}
  in      pos: chess_pos_t;            {board position after the move}
  in      whmove: boolean)             {TRUE if it is now white's move}
  :sys_int_machine_t;                  {range CHESS_EVAL_xxx_K, high good for white}
  val_param; internal;

var
  ix, iy: sys_int_machine_t;           {0-7 chess square index}
  val: sys_int_machine_t;              {running evaluation}
  priv_p: priv_p_t;                    {pointer to our private data this eval use}

begin
  priv_p := eval.priv_p;               {get pointer to private data for this use}
  val := 0;                            {init evaluation to 0}

  for iy := 0 to 7 do begin            {up the rows from white to black}
    for ix := 0 to 7 do begin          {from white's left to right accross this row}
      case pos[iy, ix].piece of        {what is on this square, if anything ?}
chess_sqr_wpawn_k: val := val + priv_p^.val_pawn;
chess_sqr_wrook_k: val := val + priv_p^.val_rook;
chess_sqr_wknight_k: val := val + priv_p^.val_knight;
chess_sqr_wbishop_k: val := val + priv_p^.val_bishop;
chess_sqr_wqueen_k: val := val + priv_p^.val_queen;
chess_sqr_bpawn_k: val := val - priv_p^.val_pawn;
chess_sqr_brook_k: val := val - priv_p^.val_rook;
chess_sqr_bknight_k: val := val - priv_p^.val_knight;
chess_sqr_bbishop_k: val := val - priv_p^.val_bishop;
chess_sqr_bqueen_k: val := val - priv_p^.val_queen;
        end;                           {end of square content cases}
      end;                             {back for next square accross this row}
    end;                               {back for next row}

  eval_move := val;                    {pass back final evaluation}
  end;
