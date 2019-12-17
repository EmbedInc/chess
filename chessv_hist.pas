{   Routines that manipulate the history list.
}
module chessv_util;
define chessv_hist_init;
define chessv_hist_add;
define chessv_hist_set;
define chessv_hist_get;
define chessv_hist_trunc;
%include 'chessv2.ins.pas';
{
********************************************************************************
*
*   Subroutine CHESSV_HIST_INIT
*
*   Init the history list with the current position.
}
procedure chessv_hist_init;            {init history list from current position}

begin
  if mem_hist_p <> nil then begin      {old history list memory exists ?}
    util_mem_context_del (mem_hist_p); {deallocate all old history list memory}
    end;
  util_mem_context_get (               {make mem context for new history list}
    util_top_mem_context, mem_hist_p);

  hist_start_p := nil;                 {indicate history list is empty}
  hist_p := nil;
  hist_free_p := nil;                  {init to no free unused list entries}
  chessv_hist_add;                     {add current position to history list}
  end;
{
********************************************************************************
*
*   Subroutine CHESSV_HIST_ADD
*
*   Add the current board position as the next history list entry.
}
procedure chessv_hist_add;             {add current position to history list}

var
  ent_p: hist_ent_p_t;                 {pointer to new history list entry}

begin
  if hist_free_p = nil
    then begin                         {no previously allocated free entries avail}
      util_mem_grab (                  {allocate memory for new history list entry}
        sizeof(ent_p^), mem_hist_p^, false, ent_p);
      end
    else begin                         {there is a free list entry available}
      ent_p := hist_free_p;            {re-use first entry on free list}
      hist_free_p := ent_p^.next_p;    {remove this entry from the free list}
      end
    ;

  if hist_p = nil
    then begin                         {there is no previous entry to link from}
      hist_start_p := ent_p;           {save pointer to start of history list}
      end
    else begin                         {adding to end of existing chain}
      hist_p^.next_p := ent_p;         {link to new entry from previous entry}
      end
    ;
  ent_p^.prev_p := hist_p;             {link back to previous list entry}
  ent_p^.next_p := nil;                {this new entry is now the end of the list}
  hist_p := ent_p;                     {make the new entry current}
  chessv_hist_set;                     {fill in the new entry}
  end;
{
********************************************************************************
*
*   Subroutine CHESSV_HIST_SET
*
*   Set the contents of the current history entry from the current board
*   position.  All history entries after the current one, if any, will
*   be truncated from the list.
}
procedure chessv_hist_set;             {set curr history entry from curr position}

begin
  hist_p^.pos := pos;                  {save board position here}
  if hist_p^.prev_p = nil
    then hist_p^.pos.prev_p := nil
    else hist_p^.pos.prev_p := addr(hist_p^.prev_p^.pos);
  pos.prev_p := hist_p^.pos.prev_p;    {fix up local position copy to same past hist}
  hist_p^.fx := move_fx;               {save last move from/to coordinates}
  hist_p^.fy := move_fy;
  hist_p^.tx := move_tx;
  hist_p^.ty := move_ty;
  hist_p^.lastmove := lastmove;        {indicate whether last move coor valid}
  hist_p^.whmove := whmove;            {indicate who's move it is now}

  nlmove_lhist := nlmove;              {save num computer moves at last hist entry}
  chessv_hist_trunc;                   {remove all later history list entries}
  end;
{
********************************************************************************
*
*   Subroutine CHESSV_HIST_GET
*
*   Get the current chess position from the current history list entry.
}
procedure chessv_hist_get;             {get current position from curr hist entry}

begin
  pos := hist_p^.pos;                  {get board position}
  move_fx := hist_p^.fx;               {get last move from/to coordinates}
  move_fy := hist_p^.fy;
  move_tx := hist_p^.tx;
  move_ty := hist_p^.ty;
  lastmove := hist_p^.lastmove;        {get whether last move coordinates valid}
  whmove := hist_p^.whmove;            {get who's move it is now}

  if hist_p^.next_p = nil
    then begin                         {now at last entry in history list}
      nlmove := nlmove_lhist;          {restore number of computer move evals}
      chessv_event_lmoves;             {indicate computer moves list changed}
      end
    else begin                         {not at last history list entry}
      if nlmove <> 0 then begin        {changing computer moves list ?}
        nlmove := 0;                   {no computer move evaluations available here}
        chessv_event_lmoves;           {indicate computer moves list changed}
        end;
      end
    ;

  chessv_event_newpos;                 {push event to indicate new board position}
  end;
{
********************************************************************************
*
*   Subroutine CHESSV_HIST_TRUNC
*
*   Truncate the history list at the current position.  All history list
*   entries after the current, if any, will be placed on the free chain.
*
*   This routine always generates an event that causes the history list
*   to be redrawn, whether anything was truncated or not.
}
procedure chessv_hist_trunc;           {truncate history list after curr position}

var
  ent_p: hist_ent_p_t;                 {pointer to curr history list entry}
  next_p: hist_ent_p_t;                {pointer to next history list entry}

begin
  ent_p := hist_p^.next_p;             {init to first entry to truncate}

  while ent_p <> nil do begin          {once for each entry to add to free list}
    next_p := ent_p^.next_p;           {save pointer to next entry to process}
    ent_p^.next_p := hist_free_p;      {link this entry to front of free chain}
    hist_free_p := ent_p;
    ent_p := next_p;                   {advance to next entry to process}
    end;                               {back to move this entry to free chain}
  hist_p^.next_p := nil;               {current entry is now at end of chain}

  chessv_event_newhist;                {push event for changed history list}
  end;
