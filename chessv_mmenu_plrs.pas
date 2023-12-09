module chessv_mmenu_plrs;
define chessv_mmenu_plrs;
%include 'chessv2.ins.pas';
{
********************************************************************************
*
*   Function CHESSV_MMENU_PLRS (ULX, ULY, ABTREE)
*
*   The main menu PLAYERS option has just been selected.  This routine is called
*   from inside the main menu event handler.  The main menu event handler will
*   return with the function return value.
*
*   ULX,ULY is the preferred upper left corner within the root drawing window of
*   any subordinate menu.
*
*   ABTREE is returned TRUE unless it is known that the whole menu tree should
*   not be aborted.
}
function chessv_mmenu_plrs (           {perform main menu PLAYERS operation}
  in      ulx, uly: real;              {preferred sub menu UL in root window}
  out     abtree: boolean)             {abort the whole menu tree}
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
  pl: player_k_t;                      {type of selected player}
  menu2: gui_menu_t;                   {second level menu}
  white: boolean;                      {indicates selected player}

label
  loop_main;

begin
  name.max := size_char(name.str);     {init local var string}

  chessv_mmenu_plrs := gui_evhan_did_k; {init to all events processed}
  abtree := true;                      {init to abort whole menu tree when done}

  tp := tparm;                         {make copy of official text control params}
  tp.lspace := 1.0;                    {adjust to how needed in menus}
  rend_set.text_parms^ (tp);

  gui_menu_create (menu, win_root);    {create our main menu}
  gui_mmsg_init (                      {init for reading menu entries from message}
    mmsg, 'chessv_prog', 'menu_players', nil, 0);
  while gui_mmsg_next (mmsg, name, shcut, iid) do begin {once for each entry}
    gui_menu_ent_add (menu, name, shcut, iid); {add this entry to menu}
    end;                               {back to add next entry to the menu}
  gui_mmsg_close (mmsg);               {done reading menu entries message}

  gui_menu_place (menu, ulx - 2, uly); {set menu location within parent window}

loop_main:                             {back here for new select from our top menu}
  if not gui_menu_select (menu, iid, sel_p) then begin {menu cancelled ?}
    chessv_mmenu_plrs := menu.evhan;   {pass back how events were handled}
    abtree := iid = gui_mensel_cancel_k; {abort whole menu tree on user cancel}
    return;
    end;
  case iid of
0:  begin
      white := true;
      pl := playerw;
      end;
1:  begin
      white := false;
      pl := playerb;
      end;
otherwise
    gui_menu_delete (menu);            {delete and erase the menu}
    return;
    end;
{
*   The black or white player has been selected.  WHITE is true if white
*   was selected, and false if black selected.  PL is set to the current
*   type of the selected player.
}
  gui_menu_create (menu2, win_root);   {create submenu}
  menu2.flags := menu2.flags + [
    gui_menflag_pickdel_k];            {delete on pick, not just cancel}
  gui_mmsg_init (                      {init for reading menu entries from message}
    mmsg, 'chessv_prog', 'menu_playtype', nil, 0);
  while gui_mmsg_next (mmsg, name, shcut, iid) do begin {once for each entry}
    gui_menu_ent_add (menu2, name, shcut, iid); {add this entry to menu}
    case iid of
0:    begin                            {user}
        if pl = player_user_k then begin
          menu2.last_p^.flags :=       {make entry not selectable}
            menu2.last_p^.flags - [gui_entflag_selectable_k];
          end;
        end;
1:    begin                            {computer}
        if pl = player_comp_k then begin
          menu2.last_p^.flags :=       {make entry not selectable}
            menu2.last_p^.flags - [gui_entflag_selectable_k];
          end;
        end;
2:    begin                            {server}
        menu2.last_p^.flags :=         {not implemented yet}
          menu2.last_p^.flags - [gui_entflag_selectable_k];
        end;
3:    begin                            {client}
        menu2.last_p^.flags :=         {not implemented yet}
          menu2.last_p^.flags - [gui_entflag_selectable_k];
        end;
      end;
    end;                               {back to add next entry to the menu}
  gui_mmsg_close (mmsg);               {done reading menu entries message}
  gui_menu_place (menu2,               {set location of new menu}
    menu.win.rect.x + sel_p^.xr,
    menu.win.rect.y + sel_p^.yt + 2.0);

  discard( gui_menu_select (menu2, iid, sel_p) ); {get menu selection result into IID}
  if iid = gui_mensel_prev_k then begin {user wants back to previous menu ?}
    goto loop_main;
    end;

  gui_menu_delete (menu);              {delete and erase parent menu}
  case iid of                          {which menu entry was selected ?}
0:  begin                              {user}
      pl := player_user_k;
      end;
1:  begin                              {computer}
      pl := player_comp_k;
      end;
2:  begin                              {server}
      pl := player_server_k;
      end;
3:  begin                              {client}
      pl := player_client_k;
      end;
otherwise                              {any other abort reason not already handled}
    abtree := true;
    return;
    end;                               {end of submenu selection cases}
  if white
    then playerw := pl
    else playerb := pl;
  chessv_setmode (mode_pause_k);
  chessv_event_move;
  end;
