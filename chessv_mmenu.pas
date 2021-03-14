module chessv_mmenu;
define chessv_mmenu_init;
%include 'chessv2.ins.pas';

type
  id_k_t = sys_int_machine_t (         {IDs for main menu entries}
    id_exit_k = 0,
    id_file_k = 1,
    id_view_k = 2,
    id_players_k = 3,
    id_action_k = 4,
    id_mveval_k = 5);

var
  win: gui_win_t;                      {main menu parent window}
  menu: gui_menu_t;                    {main menu object}
{
*************************************************************************
*
*   Function CHESSV_MMENU_EVHAN (WIN, APP_P)
*
*   Event handler for parent window of main menu.
}
function chessv_mmenu_evhan (          {main menu parent window event handler}
  in out  win: gui_win_t;              {window to handle events for}
  in      app_p: univ_ptr)             {application pointer, unused}
  :gui_evhan_k_t;                      {completion status}
  val_param; internal;

var
  iid: sys_int_machine_t;              {integer menu entry ID}
  sel_p: gui_menent_p_t;               {pointer to selected menu entry}
  ev: rend_event_t;                    {RENDlib event descriptor}
  ulx, uly: real;                      {UL corner of subordinate menus in main win}
  abtree: boolean;                     {abort whole menu tree}

label
  retry, leave;

begin
  abtree := true;                      {init to abort the whole menu tree when done}

retry:
  if not gui_menu_select (menu, iid, sel_p) then begin {no selection made ?}
    chessv_mmenu_evhan := menu.evhan;  {pass back event handling status}
    goto leave;
    end;
  chessv_mmenu_evhan := gui_evhan_did_k; {events were processed and handled}

  ulx := trunc(sel_p^.xl);             {set UL in main win for any subordinate menus}
  uly := y_bar1;
{
*   The user selected a menu entry.  IID is the integer ID of the menu
*   entry, and SEL_P is pointing to the selected menu entry descriptor.
}
  case id_k_t(iid) of                  {which entry was selected ?}

id_exit_k: begin                       {EXIT}
      ev.dev := rendev;                {push CLOSE USER event onto head of queue}
      ev.ev_type := rend_ev_close_user_k;
      rend_event_push (ev);
      chessv_mmenu_evhan := gui_evhan_notme_k; {indicate event pushed onto queue}
      return;
      end;

id_file_k: begin                       {FILE}
      chessv_mmenu_evhan := chessv_mmenu_file (ulx, uly, abtree);
      end;

id_view_k: begin                       {VIEW}
      chessv_mmenu_evhan := chessv_mmenu_view (ulx, uly, abtree);
      end;

id_players_k: begin                    {PLAYERS}
      chessv_mmenu_evhan := chessv_mmenu_plrs (ulx, uly, abtree);
      end;

id_action_k: begin                     {ACTION}
      chessv_mmenu_evhan := chessv_mmenu_action (ulx, uly, abtree);
      end;

id_mveval_k: begin                     {MOVE EVAL}
      chessv_mmenu_evhan := chessv_mmenu_mveval (ulx, uly, abtree);
      end;

    end;                               {end of selected menu entry cases}
  if not abtree then goto retry;

leave:
  gui_menu_clear (menu);               {clear any selected menu entries}
  end;
{
*************************************************************************
*
*   Subroutine CHESSV_MMENU_INIT
}
procedure chessv_mmenu_init;           {set up state for main menu}

var
  tp: rend_text_parms_t;               {local copy of text control parameters}
  mmsg: gui_mmsg_t;                    {menu entries message object}
  name: string_var80_t;                {menu entry name}
  shcut: string_index_t;               {menu entry shortcut key index}
  iid: sys_int_machine_t;              {integer menu entry ID}

begin
  name.max := size_char(name.str);     {init local var string}

  tp := tparm;                         {make copy of official text control params}
  tp.lspace := 1.0;
  rend_set.text_parms^ (tp);

  gui_win_child (                      {create menu parent window}
    win,                               {newly created window}
    win_root,                          {parent window of new window}
    0.0, y_men1,                       {lower left corner of new window}
    win_root.rect.dx, y_men2 - y_men1); {dispalcement from corner}
  gui_win_set_evhan (win, univ_ptr(addr(chessv_mmenu_evhan))); {set event handler}

  gui_menu_create (menu, win);         {create the main menu object}
  gui_menu_setup_top (menu);           {set up for permanent top level menu}
  menu.flags :=                        {set menu to fill parent window}
    menu.flags + [gui_menflag_fill_k];

  gui_mmsg_init (                      {init for reading menu entries message}
    mmsg, 'chessv_prog', 'menu_main', nil, 0);
  while gui_mmsg_next (mmsg, name, shcut, iid) do begin {once for each entry}
    gui_menu_ent_add (menu, name, shcut, iid);
    case iid of                        {which menu entry?  May need special handling}
5:    begin                            {MOVE EVAL}
        if eval.parm_p = nil then begin {move evaluator has no settable parms ?}
          menu.last_p^.flags :=        {make menu unselectable}
            menu.last_p^.flags - [gui_entflag_selectable_k];
          end;
        end;
      end;                             {end of MOVE EVAL menu case}
    end;                               {back to create next menu entry}

  gui_menu_drawable (menu);            {add menu to redraw list}

  rend_set.text_parms^ (tparm);        {restore official text control parameters}
  end;
