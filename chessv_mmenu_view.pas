module chessv_mmenu_view;
define chessv_mmenu_view;
%include 'chessv2.ins.pas';
{
*************************************************************************
*
*   Function CHESSV_MMENU_VIEW (ULX, ULY)
*
*   The main menu VIEW option has just been selected.  This routine is
*   called from inside the main menu event handler.  The main menu event
*   handler will return with the function return value.
*
*   ULX,ULY is the preferred upper left corner within the root drawing
*   window of any subordinate menu.
}
function chessv_mmenu_view (           {perform main menu VIEW operation}
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

  chessv_mmenu_view := gui_evhan_did_k; {init to all events processed}

  tp := tparm;                         {make copy of official text control params}
  tp.lspace := 1.0;
  rend_set.text_parms^ (tp);

  gui_menu_create (menu, win_root);    {create our main menu}
  gui_mmsg_init (                      {init for reading menu entries from message}
    mmsg, 'chessv_prog', 'menu_view', nil, 0);
  while gui_mmsg_next (mmsg, name, shcut, iid) do begin {once for each entry}
    gui_menu_ent_add (menu, name, shcut, iid); {add this entry to menu}
    case iid of                        {special handling for some menu entries}
0:    begin                            {view from white side}
        if view_white then begin       {already set this way ?}
          menu.last_p^.flags :=        {make entry not selectable}
            menu.last_p^.flags - [gui_entflag_selectable_k];
          end;
        end;
1:    begin                            {view from black side}
        if not view_white then begin   {already set this way ?}
          menu.last_p^.flags :=        {make entry not selectable}
            menu.last_p^.flags - [gui_entflag_selectable_k];
          end;
        end;
2:    begin                            {moves history}
        if info_disp = info_hist_k then begin {already set this way ?}
          menu.last_p^.flags :=        {make entry not selectable}
            menu.last_p^.flags - [gui_entflag_selectable_k];
          end;
        end;
3:    begin                            {computer moves evaluation}
        if info_disp = info_compeval_k then begin {already set this way ?}
          menu.last_p^.flags :=        {make entry not selectable}
            menu.last_p^.flags - [gui_entflag_selectable_k];
          end;
        end;
      end;                             {end of special handling menu entry cases}
    end;                               {back to add next entry to the menu}
  gui_mmsg_close (mmsg);               {done reading menu entries message}

  gui_menu_place (menu, ulx - 2, uly); {set menu location within parent window}

  if not gui_menu_select (menu, iid, sel_p) then begin {menu cancelled ?}
    chessv_mmenu_view := menu.evhan;   {pass back how events were handled}
    return;
    end;
  gui_menu_delete (menu);              {delete and erase the menu}

  case iid of                          {which menu entry was selected ?}
{
*   View the board from the white side.
}
0:  begin
      view_white := true;
      gui_win_draw_all (win_play);
      end;
{
*   View the board from the black side.
}
1:  begin
      view_white := false;
      gui_win_draw_all (win_play);
      end;
{
*   Show moves history in info window.
}
2:  begin
      info_disp := info_hist_k;
      gui_win_draw_all (win_info);
      end;
{
*   Show computer move evaluations in info window.
}
3:  begin
      info_disp := info_compeval_k;
      gui_win_draw_all (win_info);
      end;

    end;                               {end of selected menu entry cases}
  end;
