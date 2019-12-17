module chessv_win_root;
define chessv_win_root_init;
%include 'chessv2.ins.pas';
{
*************************************************************************
*
*   Subroutine CHESSV_WIN_ROOT_DRAW (WIN, APP_P)
}
procedure chessv_win_root_draw (       {drawing routine for root window}
  in out  win: gui_win_t;              {window to draw}
  in      app_p: univ_ptr);            {pointer to arbitrary application data}
  val_param; internal;

begin
  rend_set.rgb^ (0.0, 0.0, 0.0);       {draw bar just below main menu}
  rend_set.cpnt_2d^ (0.0, y_bar1);
  rend_prim.rect_2d^ (win_root.rect.dx, y_bar2 - y_bar1);

  rend_set.cpnt_2d^ (x_bar1, y_main1); {draw bar between play and info area}
  rend_prim.rect_2d^ (x_bar2 - x_bar1, y_main2 - y_main1);

  rend_set.cpnt_2d^ (0.0, y_stat2);    {draw bar between status and main area}
  rend_prim.rect_2d^ (win_root.rect.dx, y_main1 - y_stat2);
  end;
{
*************************************************************************
*
*   Subroutine CHESSV_WIN_ROOT_INIT
*
*   Initialize (create) the root GUI window and its contents.
}
procedure chessv_win_root_init;        {create and init root GUI window}

begin
  gui_win_root (win_root);             {create the root GUI window}

  gui_win_set_draw (                   {set drawing routine for root window}
    win_root, univ_ptr(addr(chessv_win_root_draw)));

  chessv_mmenu_init;                   {init main menu}
{
*   Init main play area window.
}
  gui_win_child (                      {create new GUI window}
    win_play,                          {new window}
    win_root,                          {parent window}
    0.0, y_main1,                      {lower left corner within parent}
    x_bar1, y_main2 - y_main1);        {displacement to upper right corner}

  chessv_win_play_init;                {initialize main draw window and it contents}
{
*   Init info area window.
}
  gui_win_child (                      {create new GUI window}
    win_info,                          {new window}
    win_root,                          {parent window}
    x_bar2, y_main1,                   {lower left corner within parent}
    win_root.rect.dx - x_bar2, y_main2 - y_main1); {displacement to upper right}

  chessv_win_info_init;                {initialize main draw window and it contents}
{
*   Init status bar window.
}
  gui_win_child (                      {create new GUI window}
    win_stat,                          {new window}
    win_root,                          {parent window}
    0.0, y_stat1,                      {lower left corner within parent}
    win_root.rect.dx, y_stat2 - y_stat1); {displacement to upper right corner}

  chessv_win_stat_init;                {initialize main draw window and it contents}
  end;
