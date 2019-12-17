module chessv_mmenu_action;
define chessv_mmenu_action;
%include 'chessv2.ins.pas';
{
*************************************************************************
*
*   Function CHESSV_MMENU_ACTION (ULX, ULY)
*
*   The main menu ACTION option has just been selected.  This routine is
*   called from inside the main menu event handler.  The main menu event
*   handler will return with the function return value.
*
*   ULX,ULY is the preferred upper left corner within the root drawing
*   window of any subordinate menu.
}
function chessv_mmenu_action (         {perform main menu ACTION operation}
  in      ulx, uly: real)              {preferred sub menu UL in root window}
  :gui_evhan_k_t;
  val_param;

var
  tp: rend_text_parms_t;               {local copy of text control parameters}
  menu: gui_menu_t;                    {our top level menu}
  mmsg: gui_mmsg_t;                    {menu entries message object}
  name: string_var132_t;               {menu entry name}
  shcut: string_index_t;               {index of shortcut key within entry name}
  iid: sys_int_machine_t;              {integer menu entry ID}
  sel_p: gui_menent_p_t;               {pointer to selected menu entry}

begin
  name.max := size_char(name.str);     {init local var string}

  chessv_mmenu_action := gui_evhan_did_k; {init to all events processed}

  tp := tparm;                         {make copy of official text control params}
  tp.lspace := 1.0;
  rend_set.text_parms^ (tp);

  gui_menu_create (menu, win_root);    {create our main menu}
  gui_mmsg_init (                      {init for reading menu entries from message}
    mmsg, 'chessv_prog', 'menu_action', nil, 0);
  while gui_mmsg_next (mmsg, name, shcut, iid) do begin {once for each entry}
    gui_menu_ent_add (menu, name, shcut, iid); {add this entry to menu}
    case iid of                        {special handling for some menu entries}
0:    begin                            {PLAY}
        if mode = mode_play_k then begin {already set this way ?}
          menu.last_p^.flags :=        {make entry not selectable}
            menu.last_p^.flags - [gui_entflag_selectable_k];
          end;
        end;
1:    begin                            {PAUSE}
        if mode = mode_pause_k then begin {already set this way ?}
          menu.last_p^.flags :=        {make entry not selectable}
            menu.last_p^.flags - [gui_entflag_selectable_k];
          end;
        end;
2:    begin                            {EDIT}
        menu.last_p^.flags :=          {not implemented yet}
          menu.last_p^.flags - [gui_entflag_selectable_k];
        end;
      end;                             {end of special handling menu entry cases}
    end;                               {back to add next entry to the menu}
  gui_mmsg_close (mmsg);               {done reading menu entries message}

  gui_menu_place (menu, ulx - 2, uly); {set menu location within parent window}

  if not gui_menu_select (menu, iid, sel_p) then begin {menu cancelled ?}
    chessv_mmenu_action := menu.evhan; {pass back how events were handled}
    return;
    end;
  gui_menu_delete (menu);              {delete and erase the menu}

  case iid of                          {which menu entry was selected ?}
{
*   PLAY
}
0:  begin
      chessv_setmode (mode_play_k);
      end;
{
*   PAUSE
}
1:  begin
      chessv_setmode (mode_pause_k);
      end;
{
*   EDIT
}
2:  begin
      chessv_setmode (mode_edit_k);
      end;
{
*   RESTART
}
3: begin
      hist_p := hist_start_p;          {go to first history list entry}
      chessv_hist_get;                 {load position from new curr hist entry}
      chessv_hist_trunc;               {truncate history list after current position}
      mode := mode_pause_k;            {set mode to game is paused}
      chessv_event_move;               {have curr player make move, if appropriate}
      end;
{
*   RESET
}
4: begin
      chessv_pos_start (pos);          {reset to the game starting position}
      move_fx := 0;
      move_fy := 0;
      move_tx := 0;
      move_ty := 0;
      lastmove := false;               {reset to no last move info available}
      whmove := false;                 {reset to it is black's move}
      nlmove := 0;                     {empty list of contemplated moves}
      mode := mode_pause_k;            {reset overall program mode}
      umove := false;                  {reset to not user's move}
      chessv_hist_init;                {reset history list to current position}
      chessv_event_nextmove;           {have the next player move, if appropriate}
      chessv_event_lmoves;             {indicate list of computer moves changed}
      end;

    end;                               {end of selected menu entry cases}
  end;
