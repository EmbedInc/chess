{   Module of routines that handle move evaluators and their private contexts.
}
module chess_eval;
define chess_eval_init;
define chess_eval_close;
define chess_eval_malloc;
define chess_eval_addparm;
%include 'chess2.ins.pas';
{
********************************************************************************
*
*   Subroutine CHESS_EVAL_INIT (EVAL, STAT)
*
*   Open a new use of the move evaluator.
}
procedure chess_eval_init (            {initialize context and start move evaluator}
  out     eval: chess_eval_t;          {move evaluator context to initialize}
  out     stat: sys_err_t);            {completion status code}
  val_param;

begin
  util_mem_context_get (               {create private mem context for this eval}
    util_top_mem_context,              {parent memory context}
    eval.mem_p);                       {pointer to new private memory context}

  eval.parm_p := nil;                  {init user-visible parameters list to empty}
  eval.last_p := nil;
  eval.eval_move_p := nil;             {init to move evaluator not installed yet}
  eval.close_p := nil;                 {init to no private close routine installed}
  eval.priv_p := nil;                  {init private pointer to NIL}

  sys_error_none (stat);               {init STAT to indicate no error}
  chess_eval_open (                    {open new use of private move evaluator}
    eval,                              {context for this new move evaluator use}
    stat);                             {completion code, initialized to no error}

  if sys_error(stat) then begin        {private move evaluator open failed ?}
    util_mem_context_del (eval.mem_p); {deallocate private memory and delete context}
    return;                            {return with error from private eval open}
    end;

  if eval.eval_move_p = nil then begin {EVAL_OPEN didn't install move evaluator ?}
    sys_stat_set (chess_subsys_k, chess_stat_no_evalmov_k, stat); {indicate error}
    end;
  end;
{
********************************************************************************
*
*   Subroutine CHESS_EVAL_CLOSE (EVAL)
*
*   Close a use of a move evaluator.  EVAL is the context for the move evaluator
*   use to close.
}
procedure chess_eval_close (           {deallocate resources, close move eval use}
  in out  eval: chess_eval_t);         {context for this move evaluator use}
  val_param;

begin
  if eval.close_p <> nil then begin    {move evaluator has private CLOSE routine ?}
    eval.close_p^ (addr(eval));        {have move evaluator do its private shutdown}
    end;

  util_mem_context_del (eval.mem_p);   {dealloc mem and delete private mem context}
  end;
{
********************************************************************************
*
*   Subroutine CHESS_EVAL_MALLOC (EVAL, SIZE, ADR)
*
*   Allocate new memory that will be associated with a particular use of a
*   move evaluator.  This memory will be automatically deallocated when the
*   move evaluator use is closed.  This will be after the private CLOSE
*   routine, if any, is called.
*
*   The memory is allocated in such a way that it can not be individually
*   deallocated.  In other words, the memory will remain allocated until
*   the move generator use is closed.
}
procedure chess_eval_malloc (          {get private EVAL mem, no individual dealloc}
  in out  eval: chess_eval_t;          {context for this move evaluator use}
  in      size: sys_int_adr_t;         {amount of memory to allocate}
  out     adr: univ_ptr);              {start of new memory region}
  val_param;

begin
  util_mem_grab (size, eval.mem_p^, false, adr); {allocate the memory}
  end;
{
********************************************************************************
*
*   Subroutine CHESS_EVAL_ADDPARM (EVAL, DTYPE, NAME)
*
*   Add a new parameter to the end of the parameters list for a particular use
*   of a move evaluator.  EVAL is the context for the move evaluator use.
*   DTYPE is the data type of the new parameter.  NAME is the name or
*   description string that will be presented to the user to indentify this
*   parameter.
*
*   The memory for the new parameter descriptor will be allocated such that
*   it will be automatically released when the move evaluator use is closed.
*   The new parameter descriptor will be linked to the end of the parameters
*   chain and initialized.  EVAL.LAST_P will be left pointing to the newly
*   created parameter descriptor.
}
procedure chess_eval_addparm (         {add parm to end of evaluator parameters list}
  in out  eval: chess_eval_t;          {context for this move evaluator use}
  in      dtype: chess_eval_parmtyp_k_t; {data type of the new parameter}
  in      name: string);               {user-visible name, NULL term or blank padded}
  val_param;

var
  parm_p: chess_eval_parm_p_t;         {pointer to new parameter descriptor}

begin
  chess_eval_malloc (eval, sizeof(parm_p^), parm_p); {alloc mem for new parm info}

  if eval.last_p = nil
    then begin                         {this is the first parameter in the list}
      eval.parm_p := parm_p;           {set start of chain pointer}
      parm_p^.prev_p := nil;           {indicate this entry is at start of chain}
      end
    else begin                         {new parm is going at end of existing chain}
      eval.last_p^.next_p := parm_p;   {link to end of chain}
      parm_p^.prev_p := eval.last_p;   {link back to previous chain entry}
      end
    ;
  eval.last_p := parm_p;               {this new entry is at the end of the chain}

  parm_p^.priv := 0;                   {init private value}
  parm_p^.name.max := size_char(parm_p^.name.str); {init parameter name}
  string_vstring (parm_p^.name, name, size_char(name));
  parm_p^.dtype := dtype;              {set parameter data type}
  case dtype of                        {what data type is it ?}
chess_eval_parmtyp_int_k: begin        {integer}
      parm_p^.int_min := firstof(parm_p^.int_min);
      parm_p^.int_max := lastof(parm_p^.int_max);
      parm_p^.int_val_p := nil;
      end;
chess_eval_parmtyp_real_k: begin       {floating point}
      parm_p^.real_min := -1.0E35;
      parm_p^.real_max :=  1.0E35;
      parm_p^.real_val_p := nil;
      end;
    end;                               {end of data type cases}
  end;
